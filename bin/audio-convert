#!/usr/bin/python2
# coding: utf-8
"""Audio file converter

Converts between several audio formats -- currently Wave, MP3, FLAC, Ogg Vorbis,
APE (Monkey's Audio) and WMA. Relies on external utilities like lame, oggenc,
ffmpeg.
"""

# TODO: Need to improve documentation

from __future__ import print_function
from subprocess import Popen, PIPE
import os.path
import sys
#import termios, tty, signal

OUTPUT_SAME = True

################################################################################################

class Format(object):
   INVALID = -1
   WAVE = 1
   FLAC = 2
   OGG  = 3
   MP3  = 4
   APE  = 5
   WMA  = 6

   exts = {WAVE: 'wav', FLAC: 'flac', OGG: 'ogg', MP3: 'mp3', APE: 'ape', WMA: 'wma'}
   strings = {WAVE: 'wav', FLAC: 'flac', OGG: 'ogg', MP3: 'mp3', APE: 'ape', WMA: 'wma'}

   @staticmethod
   def from_string(s):
      if s == 'wav':
         return Format.WAVE
      elif s == 'flac':
         return Format.FLAC
      elif s == 'ogg':
         return Format.OGG
      elif s == 'mp3':
         return Format.MP3
      elif s == 'ape':
         return Format.APE
      elif s == 'wma':
         return Format.WMA
      else:
         return Format.INVALID

   @staticmethod
   def from_ext(ext):
      return Format.from_string(ext[1:])

   @staticmethod
   def ext(format):
      return Format.exts.get(format, None)

   @staticmethod
   def to_str(format):
      return Format.strings.get(format, None)

################################################################################################

class AudioCodec(object):
   @staticmethod
   def chain(codecs, input_file, output_file, metadata={}, settings={}):
      if not codecs:
         raise ValueError, 'invalid codec chain'
      if not isinstance(codecs, list) and not isinstance(codecs, tuple):
         if issubclass(codecs, AudioCodec):
            codecs = [codecs]
         else:
            raise ValueError, 'invalid codec chain'

      if len(codecs) > 1:
         first = codecs[0]
         mid = codecs[1:-1]
         last = codecs[-1]

         p = first.run(input_file, PIPE)
         for codec in mid:
            p = codec.run(p.stdout, PIPE)
         p = last.run(p.stdout, output_file, metadata, settings)
         p.wait()
         return (p.returncode == 0)
      else:
         p = codecs[0].run(input_file, output_file, metadata, settings)
         p.wait()
         return (p.returncode == 0)

# ----------------------------------------------------------------------------------------------

class OggDecoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}):
      args = ['oggdec', '-Q',
         '-o', '-' if output_file == PIPE else output_file,
         '-' if isinstance(input_file, file) else input_file]

      return Popen(args, stdout=PIPE)

class OggEncoder(AudioCodec):
   @classmethod
   def build_metadata_args(cls, metadata):
      args = []
      for k, v in metadata.iteritems():
         if k == 'title':
            add_function = lambda x: ['-t', x]
         elif k == 'artist':
            add_function = lambda x: ['-a', x]
         elif k == 'album':
            add_function = lambda x: ['-l', x]
         elif k == 'year':
            add_function = lambda x: ['-d', x]
         elif k == 'track':
            add_function = lambda x: ['-N', x]
         elif k == 'comment':
            add_function = lambda x: ['-c', 'COMMENT=%s' % x]
         else:
            add_function = lambda x: ['-c', '%s=%s' % (k, x)]

         if not isinstance(v, list): v = [v]
         for x in v:
            args += add_function(x)
      return args

   @classmethod
   def run(cls, input_file, output_file, metadata={}, settings={}):
      args = ['oggenc', '-Q',
         '-o', '-' if output_file == PIPE else output_file,
         '-' if isinstance(input_file, file) else input_file]
      if metadata:
         args += cls.build_metadata_args(metadata)
      if settings.has_key('quality'):
         args += ['-q', settings['quality']]
      if settings.has_key('bitrate'):
         args += ['-b', settings['bitrate']]

      return Popen(args, stdout=PIPE)

# ----------------------------------------------------------------------------------------------

class Mp3Decoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}):
      args = ['lame', '--silent', '--decode',
         '-' if isinstance(input_file, file) else input_file,
         '-' if output_file == PIPE else output_file]

      return Popen(args, stdout=PIPE)

class Mp3Encoder(AudioCodec):
   @classmethod
   def build_metadata_args(cls, metadata):
      args = []
      for k, v in metadata.iteritems():
         if k == 'title':
            add_function = lambda x: ['--tt', x]
         elif k == 'artist':
            add_function = lambda x: ['--ta', x]
         elif k == 'album':
            add_function = lambda x: ['--tl', x]
         elif k == 'year':
            add_function = lambda x: ['--ty', x]
         elif k == 'track':
            add_function = lambda x: ['--tn', x]
         elif k == 'comment':
            add_function = lambda x: ['--tc', x]
         else:
            add_function = lambda x: []

         if not isinstance(v, list): v = [v]
         for x in v:
            args += add_function(x)
      return args

   @classmethod
   def run(cls, input_file, output_file, metadata={}, settings={}):
      args = ['lame', '-S']
      if metadata:
         if not settings.get('no-id3v2', False):
            #args.append('--add-id3v2')
            args.append('--id3v2-only')
         else:
            args.append('--id3v1-only')
         args += cls.build_metadata_args(metadata)

      if settings.has_key('quality'):
         args += ['-q', settings['quality']]
      if settings.has_key('bitrate'):
         args += ['-b', settings['bitrate']]
      if settings.has_key('vbr'):
         args += ['--vbr-new', '-V', settings['vbr']]

      args += [
         '-' if isinstance(input_file, file) else input_file,
         '-' if output_file == PIPE else output_file]

      fds = {'stdout': PIPE}
      if input_file == PIPE or isinstance(input_file, file):
         fds['stdin'] = input_file

      return Popen(args, **fds)

# ----------------------------------------------------------------------------------------------

class FlacDecoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}):
      args = ['flac', '-s', '-d']
      if output_file == PIPE:
         args.append('-c')
      else:
         args += ['-o', output_file]
      args.append('-' if isinstance(input_file, file) else input_file)

      return Popen(args, stdout=PIPE)

class FlacEncoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}, settings={}):
      args = ['flac', '-s']
      if output_file == PIPE:
         args.append('-c')
      else:
         args += ['-o', output_file]
      if settings.get('overwrite', False):
         args.append('-f')

      if metadata: # FLAC uses same comment spec as Vorbis
         args += OggEncoder.build_metadata_args(metadata)

      args.append('-' if isinstance(input_file, file) else input_file)

      return Popen(args, stdout=PIPE)

# ----------------------------------------------------------------------------------------------

class ApeDecoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}):
      if isinstance(input_file, file):
         raise TypeError, 'APE decoder does not support pipe input'
      args = ['mac', input_file,
         '-' if output_file == PIPE else output_file,
         '-d']

      return Popen(args, stdout=PIPE)

# ----------------------------------------------------------------------------------------------

class FFMpegDecoder(AudioCodec):
   @classmethod
   def run(cls, input_file, output_file, metadata={}):
      args = ['ffmpeg',
         '-i', '-' if isinstance(input_file, file) else input_file]
      if output_file == PIPE:
         args += ['-f', 'wav', '-']
      else:
         args.append(output_file)

      return Popen(args, stdout=PIPE)


################################################################################################

class MetadataExtractor(object):
   pass

class VorbisMetadataExtractor(MetadataExtractor):
   @classmethod
   def run(cls, input_file):
      args = ['vorbiscomment', '-l', input_file]
      proc = Popen(args, stdout=PIPE)
      data, err = proc.communicate()
      if proc.returncode == 0:
         return parse_vorbis_comment(data)

class FlacMetadataExtractor(MetadataExtractor):
   @classmethod
   def run(cls, input_file):
      args = ['metaflac', '--export-tags-to=-', input_file]
      proc = Popen(args, stdout=PIPE)
      data, err = proc.communicate()
      if proc.returncode == 0:
         return parse_vorbis_comment(data)


################################################################################################

class AudioConverterException(Exception):
   def __str__(self):
      return self.msg

class FileFormatException(AudioConverterException):
   def __init__(self, msg):
      self.msg = msg

################################################################################################

def ask_overwrite(file_name):
   print("File '%s' exists. Overwrite?" % file_name, end='')
   sys.stdout.flush()

   ans = raw_input().lower()
   return (ans == 'y' or ans == 'yes')


class FileConverter(object):
   def __init__(self, output_dir, output_format, settings={}, prefix=''):
      self.output_dir = output_dir
      self.output_format = Format.from_string(output_format)
      self.output_file = None
      self.output_prefix = prefix
      self.settings = settings
      self.metadata = {}

   def set_metadata(self, metadata):
      self.metadata = metadata

   def convert(self, input_file):
      file_dir, file_name = os.path.split(input_file)
      file_base, ext = os.path.splitext(file_name)
      if not ext:
         raise FileFormatException, 'file has no extension. Filetype detection not implemented yet.'

      input_format = Format.from_ext(ext)
      if self.output_file:
         output_file = self.output_file
      else:
         if self.output_dir == OUTPUT_SAME:
            output_dir = file_dir
         else:
            output_dir = self.output_dir
         output_file = os.path.join(output_dir, '{}{}.{}'.format(self.output_prefix, file_base, Format.ext(self.output_format)))

      codecs = self._get_converter(input_format, self.output_format)
      print("\033[0;33mConverting \033[1m%s\033[0;33m...\033[39m " % input_file, end='')
      sys.stdout.flush()

      if not self.settings.get('overwrite', False) and os.path.exists(output_file):
         if not ask_overwrite(output_file):
            return

      input_meta = self._get_metadata(input_format, input_file)
      input_meta.update(self.metadata)

      if AudioCodec.chain(codecs, input_file, output_file, input_meta, self.settings):
         print("\r\033[0;32mConverted \033[1m%s\033[0;32m.\033[39m     " % input_file)
      else:
         print("\r\033[0;31mError converting \033[1m%s\033[0;39m       " % input_file)

   def set_output_file(self, output_file):
      self.output_file = output_file

   def _get_converter(self, input_format, output_format):
      #if input_format == output_format:
      #   raise FileFormatException, 'format conversion from %s to %s not supported' \
      #      % (Format.to_str(input_format), Format.to_str(output_format))

      if input_format == Format.WAVE:
         if output_format == Format.FLAC:
            return FlacEncoder
         elif output_format == Format.OGG:
            return OggEncoder
         elif output_format == Format.MP3:
            return Mp3Encoder

      if input_format == Format.FLAC:
         if output_format == Format.OGG:
            return OggEncoder
         elif output_format == Format.MP3:
            return [FlacDecoder, Mp3Encoder]

      if input_format == Format.MP3:
         if output_format == Format.WAVE:
            return Mp3Decoder
         elif output_format == Format.MP3:
            return Mp3Encoder
         elif output_format == Format.FLAC:
            return [Mp3Decoder, FlacEncoder]
         elif output_format == Format.OGG:
            return [Mp3Decoder, OggEncoder]

      if input_format == Format.OGG:
         if output_format == Format.WAVE:
            return OggDecoder
         elif output_format == Format.FLAC:
            return [OggDecoder, FlacEncoder]
         elif output_format == Format.MP3:
            return [OggDecoder, Mp3Encoder]

      if input_format == Format.APE:
         if output_format == Format.WAVE:
            return ApeDecoder
         elif output_format == Format.FLAC:
            return [ApeDecoder, FlacEncoder]
         elif output_format == Format.OGG:
            return [ApeDecoder, OggEncoder]
         elif output_format == Format.MP3:
            return [ApeDecoder, Mp3Encoder]

      if input_format == Format.WMA:
         if output_format == Format.WAVE:
            return FFMpegDecoder
         elif output_format == Format.MP3:
            return [FFMpegDecoder, Mp3Encoder]
         elif output_format == Format.FLAC:
            return [FFMpegDecoder, FlacEncoder]
         elif output_format == Format.OGG:
            return [FFMpegDecoder, OggEncoder]

      raise FileFormatException, 'format conversion from %s to %s not supported' \
         % (Format.to_str(input_format), Format.to_str(output_format))

   # TODO: implement this
   def _get_metadata(self, input_format, input_file):
      if input_format == Format.FLAC:
         return FlacMetadataExtractor.run(input_file)
      elif input_format == Format.OGG:
         return VorbisMetadataExtractor.run(input_file)
      else:
         return {}


################################################################################################

class Metadata(object):
   def __init__(self, init={}):
      self.tags = init

   def get(self, tag, default=None):
      return self.tags.get(tag, default)

   def has(self, tag):
      return self.tags.has_key(tag)

   def set(self, tag, value):
      self.tags[tag] = value

   def keys(self):
      return self.tags.keys()

   def append(self, tag, value):
      if not self.tags.has_key(tag):
         self.tags[tag] = [value]
      else:
         cur = self.tags[tag]
         if isinstance(cur, list):
            cur.append(value)
         else:
            self.tags[tag] = [cur, value]

   def update(self, other):
      self.tags.update(other.tags)

   def __repr__(self):
      return 'Metadata(%s)' % repr(self.tags)


def parse_vorbis_comment(s):
   metadata = {}
   for line in s.split('\n'):
      if not line: continue
      pos = line.find('=')
      if pos == -1:
         print('Error: invalid comment: %s' % line, file=sys.stderr)
         continue
      tag = line[:pos].lower()
      data = line[pos+1:]

      if tag == 'date':
         tag = 'year'
      elif tag == 'tracknumber':
         tag = 'track'

      v = metadata.get(tag, [])
      metadata[tag] = v + [data]

   return metadata

################################################################################################

if __name__ == "__main__":
   import argparse

   class MyHelpFormatter(argparse.HelpFormatter):
      def __init__(self, prog, indent_increment=2, max_help_position=37, width=None):
         super(MyHelpFormatter, self).__init__(prog, indent_increment, max_help_position, width)

   class MetadataStore(argparse.Action):
      def __call__(self, parser, namespace, values, option_string=None):
         if hasattr(namespace, 'metadata'):
            metadata = namespace.metadata
         else:
            metadata = Metadata()
            namespace.metadata = metadata

         if option_string == '--tag':
            tag, value = values
            metadata.append(tag, value)
         else:
            tag = self.dest
            metadata.append(tag, values)


   parser = argparse.ArgumentParser(formatter_class=MyHelpFormatter,
      usage='%(prog)s [options] input_file [input_file ...]',
      description='Converts audio files between different formats.')

   group1 = parser.add_argument_group('Output file selection')
   group1.add_argument('-o', '--output', dest='output_file', metavar='FILE',
      help='writes output to FILE (when there is only one file to convert)')
   group1.add_argument('-f', '--output-format', dest='output_format', metavar='FORMAT',
      help='selects output format (valid choices: wav, flac, ogg, mp3)')
   group1.add_argument('-O', '--output-dir', dest='output_dir', default='', metavar='DIR',
      help='writes output files in directory DIR')
   group1.add_argument('-Os', '--output-same', dest='output_dir', action='store_const', const=OUTPUT_SAME,
      help='writes output files to same directory as corresponding input files')
   group1.add_argument('-P', '--output-prefix', dest='output_prefix', default='', metavar='PREFIX',
      help='adds PREFIX to output filenames')
   group1.add_argument('-y', '--overwrite', dest='overwrite', action='store_true', default=False,
      help='overwrite existing files without confirmation')

   group2 = parser.add_argument_group('Metadata', argument_default=argparse.SUPPRESS)
   group2.add_argument('-tt', '--title', dest='title', metavar='TITLE', action=MetadataStore,
      help='writes title tag to output file')
   group2.add_argument('-ta', '--artist', dest='artist', metavar='ARTIST', action=MetadataStore,
      help='writes artist tag to output file')
   group2.add_argument('-tl', '--album', dest='album', metavar='ALBUM', action=MetadataStore,
      help='writes album tag to output file')
   group2.add_argument('-tn', '--track', dest='track', metavar='NUMBER', action=MetadataStore,
      help='writes track number tag to output file')
   group2.add_argument('-ty', '--year', dest='year', metavar='YEAR', action=MetadataStore,
      help='writes year tag to output file')
   group2.add_argument('-tc', '--comment', dest='comment', metavar='COMMENT', action=MetadataStore,
      help='writes comment tag to output file')
   group2.add_argument('--tag', nargs=2, dest=None, metavar=('TAG', 'VALUE'), action=MetadataStore,
      help='writes custom tag to output file')

   group3 = parser.add_argument_group('Encoding options', argument_default=argparse.SUPPRESS)
   group3.add_argument('-b', '--bitrate', dest='bitrate', metavar='BITRATE',
      help='selects bitrate (in kb/s) for encoded file (ogg, mp3)')
   group3.add_argument('-q', '--quality', dest='quality', metavar='QUALITY',
      help='selects quality for encoded file (ogg, mp3)')
   group3.add_argument('-v', '--vbr', dest='vbr', metavar='MODE',
      help='selects VBR mode (mp3)')

   parser.add_argument('inputs', nargs='+', help=argparse.SUPPRESS)

   args = parser.parse_args()

   settings = {'overwrite': args.overwrite}
   if hasattr(args, 'bitrate'): settings['bitrate'] = args.bitrate
   if hasattr(args, 'quality'): settings['quality'] = args.quality
   if hasattr(args, 'vbr'): settings['vbr'] = args.vbr

   converter = FileConverter(args.output_dir, args.output_format, settings, prefix=args.output_prefix)

   if len(args.inputs) == 1 and args.output_file:
      converter.set_output_file(args.output_file)

   if hasattr(args, 'metadata'):
      converter.set_metadata(args.metadata.tags)

   for input_file in args.inputs:
      try:
         converter.convert(input_file)
      except AudioConverterException, e:
         print('error:', e)
