import { PDFDocument, StandardFonts, rgb } from "pdf-lib";

export const buildCsvBuffer = (rows: Array<Array<string | number | null | undefined>>) => {
  const csv = rows
    .map((row) =>
      row
        .map((value) => {
          const text = value == null ? "" : String(value);
          const escaped = text.replace(/"/g, '""');
          return /[",\n]/.test(escaped) ? `"${escaped}"` : escaped;
        })
        .join(",")
    )
    .join("\n");

  return new TextEncoder().encode(csv);
};

export const buildSimplePdfBuffer = async (lines: string[]) => {
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([595.28, 841.89]);
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const boldFont = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
  const margin = 40;
  const lineHeight = 16;
  const maxWidth = page.getWidth() - margin * 2;
  let y = page.getHeight() - margin;

  const wrapLine = (text: string, size: number) => {
    const words = text.split(/\s+/).filter(Boolean);
    const wrapped: string[] = [];
    let current = "";

    for (const word of words) {
      const candidate = current ? `${current} ${word}` : word;
      const width = font.widthOfTextAtSize(candidate, size);
      if (width <= maxWidth) {
        current = candidate;
      } else {
        if (current) wrapped.push(current);
        current = word;
      }
    }

    if (current) wrapped.push(current);
    return wrapped.length ? wrapped : [text];
  };

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index] ?? "";
    const isTitle = index === 0;
    const fontSize = isTitle ? 16 : 11;
    const activeFont = isTitle ? boldFont : font;
    const wrapped = wrapLine(line, fontSize);

    for (const part of wrapped) {
      if (y < margin) break;
      page.drawText(part, {
        x: margin,
        y,
        size: fontSize,
        font: activeFont,
        color: rgb(0.12, 0.16, 0.22),
      });
      y -= isTitle ? lineHeight + 6 : lineHeight;
    }

    if (y < margin) break;
  }

  return pdfDoc.save();
};
