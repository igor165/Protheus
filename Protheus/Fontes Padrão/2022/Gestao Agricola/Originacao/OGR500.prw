#Include 'Protheus.ch'
#INCLUDE 'TopConn.ch'
#INCLUDE 'OGR500.CH'
/*                                                                                                 
+=================================================================================================+
| Programa  : OGR500                                                                              |
| Descrição : Programa saldos de contrato em terceiros                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/03/2016                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function OGR500()
Local aArAt		:= GetArea()
Private oReport	:= Nil
Private cPerg		:= "OGR500"
Private vRetR,cNoT1,cAlT1,aAlT1,vRetT,cNoTT,cAlTT,aAlTT
		
OGRSALDOTRB("OGR500","4") // No OGR400
	
If TRepInUse()
	Pergunte(cPerg,.f.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

AGRDELETRB(cAlT1,cNoT1)
AGRDELETRB(cAlTT,cNoTT)
RestArea(aArAt)  
Return( Nil )

/*                                                                                                 
+=================================================================================================+
| Função    : ReportDef                                                                           |
| Descrição : Criação da seção                                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 24/03/2016                                                                          | 
+=================================================================================================+                                                                           |  
*/
Static Function ReportDef()
oReport	:= TReport():New(STR0001,STR0002,cPerg,{|oReport|OGRSALDOPRI(oReport,'4')},STR0002) // No OGR400
oReport:SetTotalInLine(.f.)
oReport:SetLandScape()
OGRSALDOCOL(oReport,STR0002,"4") // No OGR400
Return oReport