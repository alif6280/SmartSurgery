package com.surgery.servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.surgery.dao.PatientDAO;
import com.surgery.model.Patient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/report/patient")
public class PatientReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int patientId = Integer.parseInt(req.getParameter("id"));

        try {
            PatientDAO dao = new PatientDAO();
            Patient p = dao.getPatientById(patientId);

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                    "attachment; filename=Patient_" + p.getPatientId() + "_Risk_Report.pdf");

            Document doc = new Document(PageSize.A4);
            PdfWriter.getInstance(doc, resp.getOutputStream());
            doc.open();

            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, new BaseColor(0, 180, 140));
            Font heading   = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, new BaseColor(30, 50, 70));
            Font normal    = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, new BaseColor(60, 60, 60));
            Font small     = new Font(Font.FontFamily.HELVETICA, 9,  Font.NORMAL, new BaseColor(100, 100, 100));
            Font boldFont  = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, new BaseColor(30, 30, 30));

            // Hospital Header
            Paragraph hospital = new Paragraph("Khwaja Yunus Ali Medical College Hospital", titleFont);
            hospital.setAlignment(Element.ALIGN_CENTER);
            doc.add(hospital);

            Paragraph address = new Paragraph("Enayetpur, Sirajganj | Tel: 01716-291681", small);
            address.setAlignment(Element.ALIGN_CENTER);
            doc.add(address);

            doc.add(new Paragraph("________________________________________________", small));

            Paragraph reportHead = new Paragraph("Patient Risk Analysis Report\n",
                    new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD));
            reportHead.setAlignment(Element.ALIGN_CENTER);
            reportHead.setSpacingAfter(5);
            doc.add(reportHead);

            Paragraph genDate = new Paragraph(
                    "Generated: " + new SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new Date()), small);
            genDate.setAlignment(Element.ALIGN_CENTER);
            genDate.setSpacingAfter(15);
            doc.add(genDate);

            // Patient Info
            addSectionTitle(doc, "Patient Information", heading);
            PdfPTable infoTable = new PdfPTable(4);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(15);
            infoTable.setWidths(new float[]{1.5f, 2f, 1.5f, 2f});

            BaseColor labelBg = new BaseColor(240, 245, 250);
            BaseColor valueBg = BaseColor.WHITE;

            addInfoRow(infoTable, "Patient ID",  p.getPatientId(),
                    "Full Name",   p.getFullName(), labelBg, valueBg, boldFont, normal);
            addInfoRow(infoTable, "Age",         p.getAge() + " years",
                    "Gender",      p.getGender(), labelBg, valueBg, boldFont, normal);
            addInfoRow(infoTable, "Blood Group", p.getBloodGroup() != null ? p.getBloodGroup() : "-",
                    "Contact",     p.getContactNumber() != null ? p.getContactNumber() : "-",
                    labelBg, valueBg, boldFont, normal);
            addInfoRow(infoTable, "BMI",         p.getBmi() > 0 ? String.format("%.1f kg/m2", p.getBmi()) : "-",
                    "ASA Grade",   "Grade " + p.getAsaGrade(),
                    labelBg, valueBg, boldFont, normal);
            doc.add(infoTable);

            // Risk Analysis
            addSectionTitle(doc, "Risk Analysis", heading);
            PdfPTable riskTable = new PdfPTable(3);
            riskTable.setWidthPercentage(80);
            riskTable.setHorizontalAlignment(Element.ALIGN_CENTER);
            riskTable.setSpacingAfter(15);

            PdfPCell scoreCell = new PdfPCell();
            scoreCell.setBackgroundColor(getRiskBgColor(p.getRiskLevel()));
            scoreCell.setPadding(15);
            scoreCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            Paragraph scorePara = new Paragraph(
                    String.format("%.1f\n", p.getRiskScore()),
                    new Font(Font.FontFamily.HELVETICA, 28, Font.BOLD, getRiskTextColor(p.getRiskLevel())));
            scorePara.setAlignment(Element.ALIGN_CENTER);
            Paragraph scoreLabel = new Paragraph("Risk Score / 100", small);
            scoreLabel.setAlignment(Element.ALIGN_CENTER);
            scoreCell.addElement(scorePara);
            scoreCell.addElement(scoreLabel);
            riskTable.addCell(scoreCell);

            PdfPCell levelCell = new PdfPCell();
            levelCell.setBackgroundColor(getRiskBgColor(p.getRiskLevel()));
            levelCell.setPadding(15);
            Paragraph levelPara = new Paragraph(p.getRiskLevel() + " RISK\n",
                    new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, getRiskTextColor(p.getRiskLevel())));
            levelPara.setAlignment(Element.ALIGN_CENTER);
            Paragraph levelLabel = new Paragraph("Risk Level", small);
            levelLabel.setAlignment(Element.ALIGN_CENTER);
            levelCell.addElement(levelPara);
            levelCell.addElement(levelLabel);
            riskTable.addCell(levelCell);

            PdfPCell asaCell = new PdfPCell();
            asaCell.setBackgroundColor(new BaseColor(245, 245, 245));
            asaCell.setPadding(15);
            Paragraph asaPara = new Paragraph("Grade " + p.getAsaGrade() + "\n",
                    new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD));
            asaPara.setAlignment(Element.ALIGN_CENTER);
            Paragraph asaLabel = new Paragraph("ASA Grade", small);
            asaLabel.setAlignment(Element.ALIGN_CENTER);
            asaCell.addElement(asaPara);
            asaCell.addElement(asaLabel);
            riskTable.addCell(asaCell);
            doc.add(riskTable);

            // Comorbidities
            addSectionTitle(doc, "Comorbidities & Risk Factors", heading);
            PdfPTable condTable = new PdfPTable(5);
            condTable.setWidthPercentage(100);
            condTable.setSpacingAfter(15);
            addConditionCell(condTable, "Diabetes (DM)",  p.isHasDiabetes());
            addConditionCell(condTable, "Hypertension",   p.isHasHypertension());
            addConditionCell(condTable, "Heart Disease",  p.isHasHeartDisease());
            addConditionCell(condTable, "Kidney Disease", p.isHasKidneyDisease());
            addConditionCell(condTable, "Smoker",         p.isSmoker());
            doc.add(condTable);

            // Recommendation
            addSectionTitle(doc, "Clinical Recommendation", heading);
            String recommendation = switch (p.getRiskLevel()) {
                case "CRITICAL" -> "CRITICAL RISK: Requires immediate pre-op optimization. " +
                        "Multi-specialist team review mandatory. ICU post-op admission recommended.";
                case "HIGH" -> "HIGH RISK: Schedule urgent surgical review. " +
                        "Anaesthesia pre-assessment required. Priority OT slot allocation recommended.";
                case "MEDIUM" -> "MEDIUM RISK: Standard surgical protocol with enhanced monitoring. " +
                        "Anaesthesia consultation advised before procedure.";
                default -> "LOW RISK: Routine surgical scheduling. " +
                        "Standard pre-operative preparation is sufficient.";
            };

            PdfPTable recTable = new PdfPTable(1);
            recTable.setWidthPercentage(100);
            recTable.setSpacingAfter(15);
            PdfPCell recCell = new PdfPCell(new Phrase(recommendation,
                    new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, getRiskTextColor(p.getRiskLevel()))));
            recCell.setBackgroundColor(getRiskBgColor(p.getRiskLevel()));
            recCell.setPadding(12);
            recTable.addCell(recCell);
            doc.add(recTable);

            // Medical History
            if (p.getMedicalHistory() != null && !p.getMedicalHistory().isEmpty()) {
                addSectionTitle(doc, "Medical History", heading);
                doc.add(new Paragraph(p.getMedicalHistory(), normal));
            }

            // Allergies
            if (p.getAllergies() != null && !p.getAllergies().isEmpty()) {
                addSectionTitle(doc, "Known Allergies", heading);
                doc.add(new Paragraph(p.getAllergies(), normal));
            }

            // Footer
            doc.add(new Paragraph("\n"));
            doc.add(new Paragraph("________________________________________________", small));
            Paragraph footer = new Paragraph(
                    "This report is confidential and for authorized medical personnel only.\n" +
                            "KYAMCH — Smart Surgery Scheduling & Risk Analysis System", small);
            footer.setAlignment(Element.ALIGN_CENTER);
            doc.add(footer);

            doc.close();

        } catch (SQLException | DocumentException e) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    private void addSectionTitle(Document doc, String title, Font font) throws DocumentException {
        Paragraph p = new Paragraph(title, font);
        p.setSpacingBefore(8);
        p.setSpacingAfter(5);
        doc.add(p);
    }

    private void addInfoRow(PdfPTable table,
                            String label1, String value1, String label2, String value2,
                            BaseColor labelBg, BaseColor valueBg, Font labelFont, Font valueFont) {
        PdfPCell l1 = new PdfPCell(new Phrase(label1, labelFont));
        l1.setBackgroundColor(labelBg); l1.setPadding(6);
        PdfPCell v1 = new PdfPCell(new Phrase(value1 != null ? value1 : "-", valueFont));
        v1.setBackgroundColor(valueBg); v1.setPadding(6);
        PdfPCell l2 = new PdfPCell(new Phrase(label2, labelFont));
        l2.setBackgroundColor(labelBg); l2.setPadding(6);
        PdfPCell v2 = new PdfPCell(new Phrase(value2 != null ? value2 : "-", valueFont));
        v2.setBackgroundColor(valueBg); v2.setPadding(6);
        table.addCell(l1); table.addCell(v1);
        table.addCell(l2); table.addCell(v2);
    }

    private void addConditionCell(PdfPTable table, String name, boolean present) {
        PdfPCell cell = new PdfPCell();
        cell.setPadding(8);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBackgroundColor(present ?
                new BaseColor(255, 230, 230) : new BaseColor(230, 255, 245));
        Paragraph p = new Paragraph((present ? "YES " : "NO ") + name,
                new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD,
                        present ? new BaseColor(200, 0, 0) : new BaseColor(0, 150, 100)));
        p.setAlignment(Element.ALIGN_CENTER);
        cell.addElement(p);
        table.addCell(cell);
    }

    private BaseColor getRiskBgColor(String level) {
        return switch (level) {
            case "LOW"      -> new BaseColor(230, 255, 245);
            case "MEDIUM"   -> new BaseColor(255, 248, 225);
            case "HIGH"     -> new BaseColor(255, 235, 230);
            case "CRITICAL" -> new BaseColor(255, 220, 225);
            default         -> BaseColor.WHITE;
        };
    }

    private BaseColor getRiskTextColor(String level) {
        return switch (level) {
            case "LOW"      -> new BaseColor(0, 150, 100);
            case "MEDIUM"   -> new BaseColor(200, 120, 0);
            case "HIGH"     -> new BaseColor(200, 60, 0);
            case "CRITICAL" -> new BaseColor(200, 0, 50);
            default         -> BaseColor.BLACK;
        };
    }
}