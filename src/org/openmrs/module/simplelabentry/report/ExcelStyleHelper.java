package org.openmrs.module.simplelabentry.report;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.SortedSet;
import java.util.StringTokenizer;
import java.util.TreeSet;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.util.OpenmrsUtil;

/**
 * Helper utility that you wrap around a POI HSSFWorkbook to help manage cell styles
 * 
 * This class was adapted from org.pih.StyleHelper in PIH-EMR.
 */
public class ExcelStyleHelper {

    HSSFWorkbook wb;
    Map<String,HSSFFont> fonts = new HashMap<String,HSSFFont>();
    Map<String,HSSFCellStyle> styles = new HashMap<String,HSSFCellStyle>();
    Collection<String> fontAttributeNames = new HashSet<String>();
    Collection<String> fontAttributeStarting = new ArrayList<String>();
    short dateFormat;

    public ExcelStyleHelper(HSSFWorkbook wb) {
        this.wb = wb;
        fontAttributeNames.add("bold");
        fontAttributeNames.add("italic");
        fontAttributeNames.add("underline");
        fontAttributeStarting.add("size=");
        dateFormat = wb.createDataFormat().getFormat("d-mmm-yy");
    }

    public HSSFFont getFont(String s) {
        SortedSet<String> att = new TreeSet<String>();
        for (StringTokenizer st = new StringTokenizer(s, ","); st
                .hasMoreTokens();) {
            String str = st.nextToken().trim().toLowerCase();
            if (str.equals("")) {
                continue;
            }
            att.add(str);
        }
        String descriptor = OpenmrsUtil.join(att, ",");
        if (styles.containsKey(descriptor)) {
            return (HSSFFont) fonts.get(descriptor);
        } else {
            HSSFFont font = wb.createFont();
            for (String str : att) {
                if (str.equals("bold")) {
                    font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
                } else if (str.equals("italic")) {
                    font.setItalic(true);
                } else if (str.equals("underline")) {
                    font.setUnderline(HSSFFont.U_SINGLE);
                } else if (str.startsWith("size=")) {
                    str = str.substring(5);
                    font.setFontHeightInPoints(Short.parseShort(str));
                }
            }
            fonts.put(descriptor, font);
            return font;
        }
    }
    
    /**
     * You should pass in a comma-separated string containing attributes:
     *    bold
     *    italic
     *    underline
     *    size=##
     *    wraptext
     *    border=all | bottom | top | left | right
     *    align=center | left | right | fill
     *    date
     * 
     * @param s
     * @return
     */
    public HSSFCellStyle getStyle(String s) {
        SortedSet<String> att = new TreeSet<String>();
        SortedSet<String> fontAtts = new TreeSet<String>();
        for (StringTokenizer st = new StringTokenizer(s, ","); st
                .hasMoreTokens();) {
            String str = st.nextToken().trim().toLowerCase();
            if (str.equals("")) {
                continue;
            }
            boolean isFont = false;
            if (fontAttributeNames.contains(str)) {
                isFont = true;
            } else {
                for (String fontAttributePrefix : fontAttributeStarting) {
                    if (str.startsWith(fontAttributePrefix)) {
                        isFont = true;
                        break;
                    }
                }
            }
            (isFont ? fontAtts : att).add(str);
        }
        SortedSet<String> allAtts = new TreeSet<String>();
        allAtts.addAll(att);
        allAtts.addAll(fontAtts);
        String descriptor = OpenmrsUtil.join(allAtts, ",");
        if (styles.containsKey(descriptor)) {
            return (HSSFCellStyle) styles.get(descriptor);
        } else {
            HSSFCellStyle style = wb.createCellStyle();
            if (fontAtts.size() > 0) {
                HSSFFont font = getFont(OpenmrsUtil.join(fontAtts, ","));
                style.setFont(font);
            }
            for (String str : att) {
                helper(style, str);
            }
            styles.put(descriptor, style);
            return style;
        }
    }

    public HSSFCellStyle getAugmented(HSSFCellStyle style, String s) {
        String desc = null;
        for (Map.Entry<String,HSSFCellStyle> e : styles.entrySet()) {
            if (e.getValue().equals(style)) {
                desc = e.getKey();
            }
        }
        if (desc == null) {
            throw new IllegalArgumentException(
                    "StyleHelper.getAugmented() can only take a style registered with this StyleHelper");
        }
        if (desc.equals("")) {
            desc = s;
        } else {
            desc += "," + s;
        }
        return getStyle(desc);
    }
    
    private void helper(HSSFCellStyle style, String s) {
        if (s.equals("wraptext")) {
            style.setWrapText(true);
        } else if (s.startsWith("align=")) {
            s = s.substring(6);
            if (s.equals("left")) {
                style.setAlignment(HSSFCellStyle.ALIGN_LEFT);
            } else if (s.equals("center")) {
                style.setAlignment(HSSFCellStyle.ALIGN_CENTER);
            } else if (s.equals("right")) {
                style.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
            } else if (s.equals("fill")) {
                style.setAlignment(HSSFCellStyle.ALIGN_FILL);
            }
        } else if (s.startsWith("border=")) {
            s = s.substring(7);
            if (s.equals("all")) {
                style.setBorderTop(HSSFCellStyle.BORDER_THIN);
                style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
                style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
                style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            } else if (s.equals("top")) {
                style.setBorderTop(HSSFCellStyle.BORDER_THIN);
            } else if (s.equals("bottom")) {
                style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
            } else if (s.equals("left")) {
                style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
            } else if (s.equals("right")) {
                style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            }
        } else if (s.equals("date")) {
            style.setDataFormat(dateFormat);
        }
    }

}
