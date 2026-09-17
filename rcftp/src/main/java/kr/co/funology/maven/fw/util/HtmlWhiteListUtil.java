package kr.co.funology.maven.fw.util;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Cleaner;
import org.jsoup.safety.Safelist;

public class HtmlWhiteListUtil {
  public static String filter(String input) {  
    input = StrUtil.nvl(input);
    Safelist safelist = Safelist.basicWithImages();
    safelist.addTags("a", "div", "p", "span", "ul", "ol", "li", "br", "img", "table", "tbody", "tr", "td", "th", "span", "u", "strong", "em", "font");
    safelist.addAttributes("a", "href");
    safelist.addAttributes("img", "src", "alt", "style", "width", "height");
    safelist.addAttributes("table", "style", "width", "border");
    safelist.addAttributes("tr", "style");
    safelist.addAttributes("td", "style");
    safelist.addAttributes("th", "style");
    safelist.addAttributes("div", "style");
    safelist.addAttributes("p", "style");
    safelist.addAttributes("span", "style");
    safelist.addAttributes("font", "style");
    Document dirtyDoc = Jsoup.parse(input);
    Cleaner cleaner = new Cleaner(safelist);
    Document cleanDoc = cleaner.clean(dirtyDoc);
    return cleanDoc.body().html();
  }
}
