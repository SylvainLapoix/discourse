require 'rails_helper'
require 'html_to_markdown'

describe HtmlToMarkdown do

  def html_to_markdown(html)
    HtmlToMarkdown.new(html).to_markdown
  end

  it "remove whitespaces" do
    expect(html_to_markdown(<<-HTML
      <div dir="auto">Hello,
        <div dir="auto"><br></div>
        <div dir="auto">&nbsp; &nbsp; This is the 1st paragraph.&nbsp; &nbsp; </div>
        <div dir="auto"><br></div>
        <div dir="auto">
          &nbsp; &nbsp; &nbsp; &nbsp; This is another paragraph
        </div>
      </div>
    HTML
    )).to eq("Hello,\n\nThis is the 1st paragraph.\n\nThis is another paragraph")
  end

  it "converts <strong>" do
    expect(html_to_markdown("<strong>Strong</strong>")).to eq("**Strong**")
    expect(html_to_markdown("<strong>Str*ng</strong>")).to eq("__Str*ng__")
  end

  it "converts <b>" do
    expect(html_to_markdown("<b>Bold</b>")).to eq("**Bold**")
    expect(html_to_markdown("<b>B*ld</b>")).to eq("__B*ld__")
  end

  it "converts <em>" do
    expect(html_to_markdown("<em>Emphasis</em>")).to eq("*Emphasis*")
    expect(html_to_markdown("<em>Emph*sis</em>")).to eq("_Emph*sis_")
  end

  it "converts <i>" do
    expect(html_to_markdown("<i>Italic</i>")).to eq("*Italic*")
    expect(html_to_markdown("<i>It*lic</i>")).to eq("_It*lic_")
  end

  it "converts <a>" do
    expect(html_to_markdown(%Q{<a href="https://www.discourse.org">Discourse</a>})).to eq("[Discourse](https://www.discourse.org)")
  end

  it "removes empty & invalid <a>" do
    expect(html_to_markdown(%Q{<a>Discourse</a>})).to eq("Discourse")
    expect(html_to_markdown(%Q{<a href="">Discourse</a>})).to eq("Discourse")
    expect(html_to_markdown(%Q{<a href="foo.bar">Discourse</a>})).to eq("Discourse")
  end

  HTML_WITH_IMG ||= %Q{<img src="https://www.discourse.org/logo.svg" alt="Discourse Logo">}

  it "converts <img>" do
    expect(html_to_markdown(HTML_WITH_IMG)).to eq("![Discourse Logo](https://www.discourse.org/logo.svg)")
  end

  it "keeps <img> with 'keep_img_tags'" do
    expect(HtmlToMarkdown.new(HTML_WITH_IMG, keep_img_tags: true).to_markdown).to eq(HTML_WITH_IMG)
  end

  (1..6).each do |n|
    it "converts <h#{n}>" do
      expect(html_to_markdown("<h#{n}>Header #{n}</h#{n}>")).to eq("#" * n + " Header #{n}")
    end
  end

  it "converts <br>" do
    expect(html_to_markdown("Before<br>Inside<br>After")).to eq("Before\nInside\nAfter")
  end

  it "converts <hr>" do
    expect(html_to_markdown("Before<hr>Inside<hr>After")).to eq("Before\n\n---\n\nInside\n\n---\n\nAfter")
  end

  it "converts <tt>" do
    expect(html_to_markdown("<tt>Teletype</tt>")).to eq("`Teletype`")
  end

  it "converts <code>" do
    expect(html_to_markdown("<code>Code</code>")).to eq("`Code`")
  end

  it "supports <ins>" do
    expect(html_to_markdown("This is an <ins>insertion</ins>")).to eq("This is an <ins>insertion</ins>")
  end

  it "supports <del>" do
    expect(html_to_markdown("This is a <del>deletion</del>")).to eq("This is a <del>deletion</del>")
  end

  it "supports <sub>" do
    expect(html_to_markdown("H<sub>2</sub>O")).to eq("H<sub>2</sub>O")
  end

  it "supports <sup>" do
    expect(html_to_markdown("<sup>Super Script!</sup>")).to eq("<sup>Super Script!</sup>")
  end

  it "supports <small>" do
    expect(html_to_markdown("<small>Small</small>")).to eq("<small>Small</small>")
  end

  it "supports <kbd>" do
    expect(html_to_markdown("<kbd>CTRL</kbd>+<kbd>C</kbd>")).to eq("<kbd>CTRL</kbd>+<kbd>C</kbd>")
  end

  it "supports <abbr>" do
    expect(html_to_markdown(%Q{<abbr title="Civilized Discourse Construction Kit, Inc.">CDCK</abbr>})).to eq(%Q{<abbr title="Civilized Discourse Construction Kit, Inc.">CDCK</abbr>})
  end

  it "supports <s>" do
    expect(html_to_markdown("<s>Strike Through</s>")).to eq("<s>Strike Through</s>")
  end

  it "supports <strike>" do
    expect(html_to_markdown("<strike>Strike Through</strike>")).to eq("<strike>Strike Through</strike>")
  end

  it "supports <blockquote>" do
    expect(html_to_markdown("<blockquote>Quote</blockquote>")).to eq("> Quote")
  end

  it "supports <ul>" do
    expect(html_to_markdown("<ul><li>🍏</li><li>🍐</li><li>🍌</li></ul>")).to eq("- 🍏\n- 🍐\n- 🍌")
    expect(html_to_markdown("<ul>\n<li>🍏</li>\n<li>🍐</li>\n<li>🍌</li>\n</ul>")).to eq("- 🍏\n- 🍐\n- 🍌")
  end

  it "supports <ol>" do
    expect(html_to_markdown("<ol><li>🍆</li><li>🍅</li><li>🍄</li></ol>")).to eq("1. 🍆\n1. 🍅\n1. 🍄")
  end

  it "supports <p> inside <li>" do
    expect(html_to_markdown("<ul><li><p>🍏</p></li><li><p>🍐</p></li><li><p>🍌</p></li></ul>")).to eq("- 🍏\n\n- 🍐\n\n- 🍌")
  end

  it "supports <ul> inside <ul>" do
    expect(html_to_markdown(<<-HTML
      <ul>
        <li>Fruits
            <ul>
                <li>🍏</li>
                <li>🍐</li>
                <li>🍌</li>
            </ul>
        </li>
        <li>Vegetables
            <ul>
                <li>🍆</li>
                <li>🍅</li>
                <li>🍄</li>
            </ul>
        </li>
      </ul>
    HTML
    )).to eq("- Fruits\n  - 🍏\n  - 🍐\n  - 🍌\n- Vegetables\n  - 🍆\n  - 🍅\n  - 🍄")
  end

  it "supports <pre>" do
    expect(html_to_markdown("<pre>var foo = 'bar';</pre>")).to eq("```\nvar foo = 'bar';\n```")
    expect(html_to_markdown("<pre><code>var foo = 'bar';</code></pre>")).to eq("```\nvar foo = 'bar';\n```")
    expect(html_to_markdown(%Q{<pre><code class="lang-javascript">var foo = 'bar';</code></pre>})).to eq("```javascript\nvar foo = 'bar';\n```")
  end

  it "works" do
    expect(html_to_markdown("<ul><li><p>A list item with a blockquote:</p><blockquote><p>This is a <strong>blockquote</strong><br>inside a list item.</p></blockquote></li></ul>")).to eq("- A list item with a blockquote:\n\n  > This is a **blockquote**\n  > inside a list item.")
  end

  it "supports html document" do
    expect(html_to_markdown("<html><body>Hello<div>World</div></body></html>")).to eq("Hello\nWorld")
  end

  it "handles <p>" do
    expect(html_to_markdown("<p>1st paragraph</p><p>2nd paragraph</p>")).to eq("1st paragraph\n\n2nd paragraph")
  end

  it "handles <div>" do
    expect(html_to_markdown("<div>1st div</div><div>2nd div</div>")).to eq("1st div\n\n2nd div")
  end

  it "swallows <span>" do
    expect(html_to_markdown("<span>Span</span>")).to eq("Span")
  end

  it "swallows <u>" do
    expect(html_to_markdown("<u>Underline</u>")).to eq("Underline")
  end

  it "removes <script>" do
    expect(html_to_markdown("<script>var foo = 'bar'</script>")).to eq("")
  end

  it "removes <style>" do
    expect(html_to_markdown("<style>* { margin: 0 }</style>")).to eq("")
  end

end
