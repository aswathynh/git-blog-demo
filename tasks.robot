*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Robocloud.Items
Library             XML
Library             RPA.Desktop.Windows
Library             RPA.Desktop
Library             Screenshot
Library             RPA.FileSystem
Library             RPA.Archive


*** Variables ***
${orders}
${row}


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website

    Get orders

    ${orders}=    Read table from CSV    orders.csv

    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    10x    0.2s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}
        ${screenshot}=    Take a screenshot of the robot    ${row}
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}
        Wait Until Keyword Succeeds    10x    0.2s    Order another robot
    END

    Create a ZIP file of the receipts    ${row}


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True

Close the annoying modal
    Click Element If Visible    css:div.alert-buttons

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite= true

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath://input[@placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    address    ${row}[Address]

 Preview the robot
    Wait And Click Button    preview

 Submit the order
    Click Element If Visible    order
    Click Element If Visible    order
    Click Element If Visible    order
    Click Element If Visible    order
    Click Element If Visible    order
    Click Element If Visible    order

Order another robot
    Click Button    order-another

Store the receipt as a PDF file
    [Arguments]    ${row}
    ${OrderReceipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${OrderReceipt_html}    ${OUTPUT_DIR}${/}${row}[Order number].pdf

Take a screenshot of the robot
    [Arguments]    ${row}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}picture${row}[Order number].png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}    ${row}
    Open Pdf    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    ${image_file}=    Create List    ${OUTPUT_DIR}${/}picture${row}[Order number].png
    Add Files To PDF    ${image_file}    ${OUTPUT_DIR}${/}${row}[Order number].pdf    append=True
    Close Pdf    ${pdf}

Create a ZIP file of the receipts
    [Arguments]    ${row}
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}${row}[Order number].zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    ...    ${zip_file_name}
