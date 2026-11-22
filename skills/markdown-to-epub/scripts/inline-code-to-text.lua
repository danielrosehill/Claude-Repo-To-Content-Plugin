-- Inline code (paths, IDs, slugs) becomes italic body text in the EPUB.
-- Reader apps often ignore the book's CSS for <code> and switch to monospace mid-sentence.
function Code(el) return pandoc.Emph({pandoc.Str(el.text)}) end
