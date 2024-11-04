*** Settings ***
Library           Browser
Library           JSONLibrary
Library           Collections
Library           BuiltIn
Test Teardown     Close Browser

*** Variables ***
${URL}                 https://testpages.herokuapp.com/styled/tag/dynamic-table.html
${JSON_FILE}           C:\\RobotFramework\\WebDemo\\jsonData.json
${tableDatPath}        //summary
${jsonDataInputBox}    //textarea[@id='jsondata']
${refreshTable}        //button[@id='refreshtable']
${tableData}           //table[@id='dynamictable']//tr  # Adjust this locator if needed
${DELAY}               2s  # Delay duration

*** Test Cases ***
Dynamic Table Automation Test
    [Documentation]    Test the dynamic table functionality with provided data.
    Open Browser    ${URL}
    Click    ${tableDatPath}
    Clear Text    ${jsonDataInputBox}
    Sleep    ${DELAY}  # Delay to see the cleared text
    
    # Load data from JSON file
    ${expected_data}=    Get Test Data From Json File    ${JSON_FILE}

    Insert Data Into Text Box    ${expected_data}
    Sleep    ${DELAY}  # Delay to see the inserted data
    Click    ${refreshTable}
    Sleep    ${DELAY}  # Delay to see the refreshed table
    Assert Table Data Matches    ${expected_data}

*** Keywords ***

Get Test Data From Json File
    [Arguments]    ${json_file}
    ${test_data}=    Load JSON From File    ${json_file}
    Log    Loaded data from JSON file: ${test_data}  # Log loaded data for debugging
    [Return]    ${test_data}

Insert Data Into Text Box
    [Arguments]    ${data}
    ${json_string}=    Convert List of Dictionaries to JSON String    ${data}
    Fill Text    ${jsonDataInputBox}    ${json_string}

Assert Table Data Matches
    [Arguments]    ${expected_data}
    ${actual_rows}=    Get Elements    ${tableData}
    ${row_count}=    Get Length    ${actual_rows}  # Get the length of actual rows

    FOR    ${index}    IN RANGE    1    ${row_count}  # Start from index 1 to skip the header
        ${row}=    Get From List    ${actual_rows}    ${index}
        ${columns}=    Get Elements    ${row} >> td
        ${actual_name}=    Get Text    ${columns}[0]
        ${actual_age}=    Get Text    ${columns}[1]
        ${actual_gender}=    Get Text    ${columns}[2]

        # Use Evaluate to perform the arithmetic operation on index
        ${expected_index}=    Evaluate    ${index} - 1
        ${expected_entry}=    Get From List    ${expected_data}    ${expected_index}  # Adjust index for expected data

        Should Be Equal As Strings    ${actual_name}    ${expected_entry['name']}
        Should Be Equal As Strings    ${actual_age}    ${expected_entry['age']}
        Should Be Equal As Strings    ${actual_gender}    ${expected_entry['gender']}
    END

Convert List of Dictionaries to JSON String
    [Arguments]    ${data_list}
    ${json_string}=    Evaluate    json.dumps(${data_list})    json
    [Return]    ${json_string}
