from scrapy.conf import settings
from scrapy.contrib.exporter import CsvItemExporter


class CsvOptionRespectingItemExporter(CsvItemExporter):

    def __init__(self, *args, **kwargs):
        delimiter = settings.get('CSV_DELIMITER', ',')
        kwargs['delimiter'] = delimiter
        super(CsvOptionRespectingItemExporter, self).__init__(*args, **kwargs)
