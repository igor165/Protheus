#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEW010.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEW017  ³ Autor ³ Totvs                      ³ Data ³ 08/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Workflow FLUIG - Subsidio			                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                 ³                                            ³±±
±±³              ³        ³                 ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEW017()
WF Solicitação Subsidio - TIPO V(Portal)

@author Flavio S. Correa
@since 10/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GPEW017()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
VIEW Subsidio
@author Flavio S. Correa
@since 10/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 		:= FWLoadModel("GPEW011")
	Local oView 		:= FWFormView():New()	
	Local nI			:= 1
	Local nPos			:= 0
	Local oStructRH3 	:= FWFormStruct(2, "RH3")
	Local oStruct 		:= FWFormViewStruct():New()
	Local oStructApr 	:= FWFormViewStruct():New()
	Local aStr			:= {"RI1_FILIAL","RI1_MAT","TMP_NOME","RI1_TABELA","TMP_NMCURS","TMP_NMINST","TMP_CONTAT","TMP_TELEFO","RI1_DINIPG","RI1_DFIMPG","TMP_VLRMEN","TMP_QTDEPA" }
	Local aFields 		:= {}
	
	//array com os campos de acordo com o tipo de solicitação.
	//Cada array desse é usado numa view.
	//Exemplo : Essa view é de ação salarial(tipo 7) então estou utilizando o array aStr7 na variavel aStr
	
/*
	Local aStrT0		:={	"QG_CIC"    , "QG_CURRIC" , "QG_NOME"   ,"TMP_VAGA"  ,"TMP_DESC"  ,"TMP_TEST"  ,"TMP_NOTA"  ,"TMP_SITUAC"}
	Local aStrT3		:={	"RBT_FILIAL","RBT_CODMOV","RBT_DEPTO" ,"TMP_DDEPTO","RBT_CC"    ,"TMP_DCC"   ,"RBT_FUNCAO","TMP_DFUNCA","RBT_CARGO" ,;
							"TMP_DCARGO","RBT_PROCES","RBT_REMUNE","RBT_TPOSTO","RBT_TPCONT","RBT_QTDMOV","RBT_JUSTIF","RBT_TIPOR" ,;
							"RBT_CODPOS","TMP_NOVACO"}
	Local aStrT4		:={ "RE_FILIALD","RE_MATD","RE_EMPP","RE_FILIALP","RE_MATP","TMP_NOME","RE_CCP","TMP_DCCP","RE_DEPTOP",;
							"TMP_DDEPTOP","RE_PROCESSOP","TMP_DPROCP","RE_POSTOP"}
	Local aStrT5		:={	"RBT_DEPTO","RBT_CODPOS","TMP_TIPO","TMP_FILIAL","TMP_MAT"}
	Local aStrT6		:= {"RA_FILIAL","RA_MAT","RA_NOME","RX_COD","RX_TXT","TMP_NOVAC" }
	Local aStrT7		:= {"RB7_FILIAL","RB7_MAT","TMP_NOME","RB7_TPALT","RB7_FUNCAO","RB7_CARGO","RB7_PERCEN","RB7_SALARI","RB7_CATEG"}
	Local aStrT8		:={	"RF0_FILIAL","RF0_MAT","TMP_NOME","RF0_DTPREI","RF0_DTPREF","RF0_HORINI","RF0_HORFIM","RF0_CODABO",;
							"RF0_HORTAB","TMP_ABOND"}
	Local aStrT9		:={ "TMP_VAGA","TMP_DESC" }
	Local aStrTA		:={	"RA3_FILIAL","RA3_MAT","TMP_NOME","RA3_CALEND","RA3_CURSO","RA3_TURMA","RA3_DATA"}
	Local aStrTB		:={	"R8_FILIAL","R8_MAT","TMP_NOME","R8_DATAINI","R8_DATAFIM","R8_DURACAO","TMP_ABONO","TMP_1P13SL"}
	
	Local aStrTH		:={"QG_CIC"   ,"QG_CURRIC" ,"QG_NOME" ,"TMP_VAGA"  ,"TMP_DESC"  ,"TMP_TEST" ,"TMP_NOTA"  ,"TMP_SITUAC" }
	Local aStrTV		:={"RI1_FILIAL","RI1_MAT","TMP_NOME","RI1_TABELA","TMP_NMCURS","TMP_NMINST","TMP_CONTAT","TMP_TELEFO","RI1_DINIPG","RI1_DFIMPG","TMP_VLRMEN","TMP_QTDEPA" }
*/	

	//campos RH3
	W011Str( 2,@oStructRH3 ,"RH3" )
	
		//Campos RH4
	W011Str(2,@oStruct ,"RH4" )
	
	//Campos de aprovacao
	W011Str(2,@oStructApr ,"APR" )


	oStructRH3:RemoveField("RH3_FILIAL")	
	oStructRH3:RemoveField("RH3_VISAO")
	oStructRH3:RemoveField("RH3_NVLINI")
	oStructRH3:RemoveField("RH3_FILINI")
	oStructRH3:RemoveField("RH3_MATINI")
	oStructRH3:RemoveField("RH3_NVLAPR")
	oStructRH3:RemoveField("RH3_FILAPR")
	oStructRH3:RemoveField("RH3_MATAPR")
	oStructRH3:RemoveField("RH3_WFID")
	oStructRH3:RemoveField("RH3_IDENT")
	oStructRH3:RemoveField("RH3_KEYINI")
	oStructRH3:RemoveField("RH3_ORIGEM")
	oStructRH3:RemoveField("RH3_STATUS")
	oStructRH3:RemoveField("RH3_TIPO")
	oStructRH3:RemoveField("RH3_DTATEN")
	oStructRH3:RemoveField("RH3_TPDESC")
	oStructRH3:RemoveField("RH3_FLUIG")
		
	oStruct:RemoveField("RH4_FILIAL")
	aFields := aclone(oStruct:GetFields())
	For nI := 1 To Len(aFields)	
		If (nPos := aScan(aStr,{|x| Alltrim(x) == alltrim(aFields[nI][1])})) == 0
			//Remove campos que não sao referente ao tipo da solicitação
			oStruct:RemoveField(aFields[nI][1])
		Else                                                            
			//acerta a ordem dos campos de acordo com o tipo de solicitação
			oStruct:SetProperty(aFields[nI][1],MVC_VIEW_ORDEM,nPos)
		EndIf
	Next nI

	oView:SetModel(oModel)
	oView:AddField("GPEW011_RH3", oStructRH3)   
	oView:AddField("GPEW011_RH", oStruct)   
	oView:AddField("GPEW011_APR", oStructApr)   

	oView:CreateHorizontalBox("TOP", 40)
	oView:CreateHorizontalBox("MEIO", 40)
	oView:CreateHorizontalBox("BOTTOM", 20)
	
	oView:SetOwnerView("GPEW011_RH3", "TOP")
	oView:SetOwnerView("GPEW011_RH", "MEIO")
	oView:SetOwnerView("GPEW011_APR", "BOTTOM")
	
	oView:SetCloseOnOk({ || .T. }) //Fecha tela apos commit
	
	oModel:SetDescription(STR0035)
	
Return oView


