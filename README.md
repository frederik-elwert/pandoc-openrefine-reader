# pandoc-openrefine-reader

[OpenRefine] is able to export the edit history of a project as a JSON file. But this information is not human-readable, making it unsuitable for documentation purposes.

This project provides a [Custom Reader] for [Pandoc] that allows to read OpenRefine history files and creates documentation from them.

Note: The reader is currently incomplete and does not include all relevant information for all OpenRefine operations. It’s mainly a proof of concept. Patches welcome!

The output can be any format that Pandoc can write. Two output formats are recommended:

```bash
pandoc -f openrefine.lua -so example_history.html example_history.json
```

This creates an HTML file directly from the history JSON file. Some custom CSS is automatically included.

Alternatively, one can also create a Markdown file:

```bash
pandoc -f openrefine.lua -so example_history.html example_history.json
```

The Markdown file can then be amended with additional explanation of the input and the transformation steps, creating a notebook-like document that can then later be converted into HTML or any other output format.
