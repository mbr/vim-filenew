python << endpython
import uuid
import vim
import os

def find_templates(ft):
    search_path = vim.eval('&runtimepath').split(',')

    for path in (os.path.join(base, 'filenew') for base in search_path):
        if os.path.exists(path):
            for fn in os.listdir(path):
                yield os.path.join(path, fn)


def get_current_buffer_id():
    if not int(vim.eval('exists("b:filenew_id")')):
        filenew_id = str(uuid.uuid4())
        vim.command('let b:filenew_id="%s"' % filenew_id)

    return vim.eval('b:filenew_id')


def get_buffer_by_id(id):
    for buf in vim.buffers:
        buf_id = vim.eval('getbufvar(%d, "filenew_id")' % buf.number)

        if buf_id == id:
            return buf


class TemplateSelectWindow(object):
    instances = {}
    MAGIC_START = '###vim-file-new'
    MAGIC_END = '###'

    def __init__(self, ft):
        self.ft = ft
        self.update_templates()

    def is_open(self):
        pass

    def on_select_template(self):
        modified = int(vim.eval('&modified'))
        lineno, _ = vim.current.window.cursor
        fn = self.filelist[lineno-1]

        buf = get_buffer_by_id(self.target_id)

        # switch buffer
        vim.command('buf %d' % buf.number)

        empty_buffer = len(buf) == 1 and '' == buf[0]

        vim.command('r %s' % fn)

        # remove leading blank line
        if empty_buffer:
            del buf[0]

        # check if we need to remove the current line
        if self.MAGIC_START in vim.current.line:
            del vim.current.line

        # not modified
        if not modified:
            self._set_options('nomodified')

        # close window
        vim.command('wincmd c')

    def open(self):
        # mark original buffer with unique id
        self.target_id = get_current_buffer_id()
        vim.command('let b:filenew_id="%s"' % self.target_id)

        self.filelist = [fn for fn in sorted(self.templates.iterkeys()) if fn.endswith(self.ft)]

        num_templates = len(self.filelist)
        vim.command('%dsplit SelectTemplate' % num_templates)
        self.instances[get_current_buffer_id()] = self

        for fn in self.filelist:
            vim.current.buffer.append('%s: %s' % (os.path.basename(fn), self.templates[fn]))

        self._set_options('bufhidden=wipe', 'buftype=nofile', 'noswapfile', 'nowrap',
                          'nonumber', 'nolist', 'nocursorline', 'nospell', 'nobuflisted',
                          'noinsertmode', 'noundofile', 'cursorline')

        # remove top line
        del vim.current.buffer[0]

        self._set_options('nomodifiable')

        vim.command('map <buffer> <Enter> :py %s.buf_on_select_template()<cr>' % \
                    self.__class__.__name__)

    def update_templates(self):
        self.templates = {}
        for fn in find_templates(self.ft):
            desc = 'No description.'

            # open and look for tag
            with open(fn, 'rU') as f:
                contents = []

                first_line = f.readline()
                if self.MAGIC_START in first_line:
                    desc = first_line[first_line.index(self.MAGIC_START)+len(self.MAGIC_START):]

                    if self.MAGIC_END in desc:
                        desc = desc[:desc.index(self.MAGIC_END)]

                    desc = desc.strip()

                self.templates[fn] = desc

    def _set_options(self, *opts):
        for opt in opts:
            vim.command('setlocal %s' % opt)

    @classmethod
    def buf_on_select_template(cls):
        #win = cls.instances()
        win = cls.instances[vim.eval('b:filenew_id')]
        win.on_select_template()

    @classmethod
    def buf_on_new_file(cls):
        ft = vim.eval('&filetype')

        win = TemplateSelectWindow(ft)
        win.open()
endpython
