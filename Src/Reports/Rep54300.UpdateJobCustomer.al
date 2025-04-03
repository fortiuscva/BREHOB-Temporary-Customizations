report 54300 "BHB Update Job Customer"
{
    ApplicationArea = All;
    Caption = 'Update Job Customer';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Job; Job)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if job.Count > 1 then
                    Error('Execute only for One Job');
                if CustomerNo = '' then
                    Message('Please Select Customer No.');
            end;

            trigger OnAfterGetRecord()
            var
                SellToCustomer: Record Customer;
            begin
                if CustomerNo <> '' then begin
                    Job."Sell-to Customer No." := CustomerNo;
                    SellToCustomer.Get(Job."Sell-to Customer No.");
                    Job."Sell-to Customer Name" := SellToCustomer.Name;
                    Job."Sell-to Customer Name 2" := SellToCustomer."Name 2";
                    Job."Sell-to Phone No." := SellToCustomer."Phone No.";
                    Job."Sell-to E-Mail" := SellToCustomer."E-Mail";
                    Job."Sell-to Address" := SellToCustomer.Address;
                    Job."Sell-to Address 2" := SellToCustomer."Address 2";
                    Job."Sell-to City" := SellToCustomer.City;
                    Job."Sell-to Post Code" := SellToCustomer."Post Code";
                    Job."Sell-to County" := SellToCustomer.County;
                    Job."Sell-to Country/Region Code" := SellToCustomer."Country/Region Code";
                    Job.Reserve := SellToCustomer.Reserve;
                    UpdateSellToContact(Job);
                    if SellToCustomer."Bill-to Customer No." <> '' then
                        Job.Validate("Bill-to Customer No.", SellToCustomer."Bill-to Customer No.")
                    else
                        Job.Validate("Bill-to Customer No.", Job."Sell-to Customer No.");
                    Job.Modify();
                end;
            end;

            trigger OnPostDataItem()
            begin
                Message(('Customer update for the Job is done'));
            end;
        }

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(CustomerNo; CustomerNo)
                    {
                        TableRelation = Customer."No.";
                        ApplicationArea = all;
                    }
                }
            }
        }

    }

    protected procedure UpdateSellToContact(var Job: Record Job)
    begin
        GetCustomerContact(Job."Sell-to Customer No.", Job."Sell-to Contact No.", Job."Sell-to Contact");
    end;

    local procedure GetCustomerContact(CustomerNo: Code[20]; var ContactNo: Code[20]; var Contact: Text[100])
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Cust: Record Customer;
    begin
        if Cust.Get(CustomerNo) then begin
            if Cust."Primary Contact No." <> '' then
                ContactNo := Cust."Primary Contact No."
            else begin
                ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", CustomerNo);
                ContactBusinessRelation.SetLoadFields("Contact No.");
                if ContactBusinessRelation.FindFirst() then
                    ContactNo := ContactBusinessRelation."Contact No.";
            end;
            Contact := Cust.Contact;
        end;
    end;

    var
        CustomerNo: Code[20];
}
