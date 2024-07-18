import asyncio
import logging

from telethon.tl.types import Message

logger = logging.getLogger(__name__)


class PostgreStorePatch:
    def __init__(self):
        self.msg_ocr_handlers = []

    def run_msg_ocr_handlers(self, data):
        msg: Message
        text: str
        for msg, text in data:
            for handler in self.msg_ocr_handlers:
                asyncio.create_task(handler(msg, text))

    def add_msg_ocr_handler(self, handler):
        self.msg_ocr_handlers.append(handler)
