#!/usr/bin/env python
import os
import config as cfg
import openpyxl

#wb=openpyxl.load_workbook("template.xlsx")
wb=openpyxl.load_workbook("application_usage-"+cfg.suffix+".xlsx")

def rename_sheet(label):
    #wb_sheet = wb.get_sheet_by_name(label)
    wb_sheet = wb[label]
    wb_sheet.title = label+' '+cfg.wslabel

sheets=["Queue First Job", "Core Summary", "Project Usage", "Project Stakeholder", "Project Status", "Personal Status", "Storage Summary", "Storage by Fileset", "Storage By Org", "Active Users", "By Cores CPU", "Applications CPU", "User Walltime CPU", "Project CPU", "Org HighLevel CPU", "Org Breakdown CPU", "Largest Jobs CPU", "By Cores GPU", "Applications GPU", "User Walltime GPU", "Project GPU", "Org HighLevel GPU", "Org Breakdown GPU", "Largest Jobs GPU", "ApplicationsDGX", "User DGX", "Projects DGX", "Org Breakdown DGX"]

for sheet in sheets:
    rename_sheet(sheet)

wb.save("application_usage-"+cfg.suffix+".xlsx")
