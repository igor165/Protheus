#include "protheus.ch"
#include "report.ch"
#include "OGR750.ch"
 
Function OGR750()
Local oReport
Local oNJJ
Local oSC5
Local oSC6
 
Pergunte("OGR750",.F.)
 
DEFINE REPORT oReport NAME "OGR750" TITLE STR0001 PARAMETER "OGR750" ACTION {|oReport| PrintReport(oReport)}
 
    DEFINE SECTION oNJJ OF oReport TITLE STR0002 TABLES "SA1" //TOTAL IN COLUMN //PAGE HEADER
    oNJJ:SetPageBreak()
 
        DEFINE CELL NAME "NJ_FILIAL"  OF oNJJ ALIAS "NJJ"       
        DEFINE CELL NAME "NJJ_CODROM" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_TIPO"   OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_PLACA"  OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_STSPES" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_PESO1"  OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_MODPS1" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_DATPS1" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_HORPS1" OF oNJJ ALIAS "NJJ"  
        DEFINE CELL NAME "NJJ_PESO2"  OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_MODPS2" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_DATPS2" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_HORPS2" OF oNJJ ALIAS "NJJ"
        DEFINE CELL NAME "NJJ_PSLIQU" OF oNJJ ALIAS "NJJ"

oReport:PrintDialog()
Return
 
Static Function PrintReport(oReport)
#IFDEF TOP
    Local cAlias := GetNextAlias()
 
    MakeSqlExp("OGR750")
     
    BEGIN REPORT QUERY oReport:Section(1)
     
    BeginSql alias cAlias
        SELECT 
            NJJ.*         
        FROM 
            %table:NJJ% NJJ         
        WHERE 
            NJJ.NJJ_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
            NJJ.NJJ_DATA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
            NJJ.NJJ_CODROM BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND  
            NJJ.NJJ_TIPO = %Exp:mv_par07% AND
            NJJ.%notDel%       
         
        ORDER BY NJJ_CODROM
    EndSql
     
    END REPORT QUERY oReport:Section(1)
    oReport:Section(1):Print()
#ENDIF
Return