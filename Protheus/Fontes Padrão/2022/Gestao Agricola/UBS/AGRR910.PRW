#Include 'Protheus.ch'
#include "report.ch"
#include "AGRR910.CH"
/*
############################################################################
# Função   : AGRR910                                                       #
# Descrição: Relatório das Ordens de Produção                              #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 02/09/2015                                                    #  
############################################################################
*/

						  
static cNomeTR1,cAliaTR1,aArqTem1	
static aCamPS1	:= {{"OP"     ,"C",TamSX3("NP9_OP")[1],0,"OP","@!"},{"LOCAL","C",TamSX3("D3_LOCAL")[1],0,AGRTITULO("D3_LOCAL"),"@!"},;
	                 {"QTDPRE" ,"N",12,2,AGRTITULO("C2_QUANT"),"@E 999,999,999.99"},{"PROD","C",TamSX3("B1_COD")[1]+30,0,AGRTITULO("B1_COD"),"@!"},;
	                 {"UM","C",TamSX3("B1_UM")[1],0,AGRTITULO("B1_UM"),"@!"},{"QTDPROD","N",12,2,AGRTITULO("C2_QUJE"),"@E 999,999,999.99"},;
	                 {"QTDAPRO","N",12,2,STR0007,"@E 999,999,999.99"}} 
	                 
static aCamPS2	:= {{"LOTE"    ,"C",TamSX3("D3_LOTECTL")[1],0,AGRTITULO("D3_LOTECTL"),"@!"},;
	                 {"LOCAL3"  ,"C",TamSX3("D3_LOCAL")[1],0,AGRTITULO("D3_LOCAL"),"@!"},{"DTEMISS","D",8,0,AGRTITULO("D3_EMISSAO"),"99/99/9999"},;
	                 {"USUARIO","C",15,0,AGRTITULO("NKV_USUARI"),"@!"},;
	                 {"QTDUM"   ,"N",12,2,AGRTITULO("D3_QUANT"),"@E 999,999,999.99"}    ,{"UNIUM","C",2,0,AGRTITULO("D3_UM"),"@!"},;
	                 {"QTDDOIS" ,"N",12,2,AGRTITULO("D3_QTSEGUM"),"@E 999,999,999.99"}  ,{"UNIDOIS","C",2,0,AGRTITULO("D3_SEGUM"),"@!"}}
	               
static aCamPS3	:= {{"COMPONE","C",TamSX3("B1_COD")[1],0,AGRTITULO("G1_COMP"),"@!"},{"DESCRI","C",TamSX3("B1_DESC")[1],0,AGRTITULO("B1_DESC"),"@!"},;
							  {"UM","C",TamSX3("B1_UM")[1],0,AGRTITULO("B1_UM"),"@!"},{"QTDEORI","N",12,2,STR0005,"@E 999,999,999.99"},;
							  {"QUANTCO","N",12,2,STR0006,"@E 999,999,999.99"},{"QUANTDI","N",12,2,STR0022,"@E 999,999,999.99"}}
	                 
static aCamPS5	:= {{"DB_ITEM","C",TamSX3("DB_ITEM")[1],0,AGRTITULO("DB_ITEM"),"@!"},{"DB_LOTECTL","C",TamSX3("DB_LOTECTL")[1],0,AGRTITULO("DB_LOTECTL"),"@!"},;
							 {"ENDERECO","C",TamSX3("D3_LOCALIZ")[1],0,AGRTITULO("D3_LOCALIZ"),"@!"},{"DB_QUANT","N",12,2,AGRTITULO("DB_QUANT"),"@E 999,999,999.99"}}	                 


Function AGRR910()
Local oReport
Local cPerg := AGRGRUPSX1("AGRR910")

Pergunte(cPerg,.f.)
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport:= ReportDef(cPerg)
	oReport:PrintDialog()
EndIf
Return

                                                  
/*
############################################################################
# Função   : ReportDef                                                     #
# Descrição: Montagem do relatório                                         #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 02/09/2015                                                    #  
############################################################################
*/
Static Function ReportDef(cPerg)
Local oReport,oSec1,oSec2,oSec3,oSec4,oSec5,nx
Local aCamTR1	:= {{"COMPO"  ,"C",TamSX3("B1_COD")[1],0,AGRTITULO("G1_COMP"),"@!"},{"DESCRI" ,"C",TamSX3("B1_DESC")[1],0,AGRTITULO("B1_DESC"),"@!"},;
						 {"UM"     ,"C",TamSX3("B1_UM")[1],0,AGRTITULO("B1_UM"),"@!"},{"QTDPRC" ,"N",12,2,STR0005,"@E 999,999,999.99"},;
	              {"QTDCONC","N",12,2,STR0006,"@E 999,999,999.99"},{"QUANTDI","N",12,2,STR0022,"@E 999,999,999.99"}}
      	 
If !AGRIFDICIONA("SIX","NP96",1,.f.) 
	AGRINCOMDIC("U_AGRUPD .. UPDNP9")
	Return
EndIf

Store Nil To	oReport,oSec1,oSec2,oSec3,oSec4

aRet2:= AGRCRIATRB(,aCamTR1,{"COMPO"},FunName(),.t.)
 
If !aRet2[1] // Problema na criação dos arquivos Temporário e indicou para mostrar na função
   Return
EndIf  

cNomeTR1 := aRet2[3] //Nome do arquivo temporário 
cAliaTR1 := aRet2[4] //Nome do alias do arquivo temporario
aArqTem1 := aRet2[5] //Matriz com a estrutura do arquivo temporario + label e picutre

DEFINE REPORT oReport NAME "AGRR910" TITLE STR0001+" "+STR0002 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} 
oReport:lParamPage := .F. 	//Não imprime os parametros
oReport:nFontBody 	 := 8 	//Aumenta o tamanho da fonte
	
// Seção 1  OP
DEFINE SECTION oSec1 OF oReport TITLE STR0001 TABLES "SC2","SB1","SD4","SD3" AUTO SIZE 
oSec1:SetTotalInLine(.F.)	// Define se imprime o total por linha
oSec1:SetAutoSize(.T.) 		// Define se as células serão ajustadas automaticamente na seção
oSec1:SetReadOnly(.T.) 		// Define se o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.

For nx := 1 To Len(aCamPS1)	
	DEFINE CELL NAME aCamPS1[nx,1]	OF oSec1 TITLE aCamPS1[nx,5] SIZE aCamPS1[nx,3] PICTURE aCamPS1[nx,6]
Next nx

// Seção 2 Lotes      
DEFINE SECTION oSec2 OF oReport TITLE STR0001 TABLES "SC2","SB1","SD4","SD3" AUTO SIZE 
	oSec2:SetTotalInLine(.F.)	
	oSec2:SetAutoSize(.T.) 		
	oSec2:SetReadOnly(.T.) 		
	
	For nx := 1 To Len(aCamPS2)	
		DEFINE CELL NAME aCamPS2[nx,1]	OF oSec2 TITLE aCamPS2[nx,5] SIZE aCamPS2[nx,3] PICTURE aCamPS2[nx,6]
	Next nx
	
// Seção 3 Estrutura da OP
DEFINE SECTION oSec3 OF oReport TITLE STR0003 TABLES "SC2","SB1","SD4","SD3" AUTO SIZE 
	oSec3:SetTotalInLine(.F.)	
	oSec3:SetAutoSize(.T.) 		
	oSec3:SetReadOnly(.T.) 		
	
	For nx := 1 To Len(aCamPS3)	
		DEFINE CELL NAME aCamPS3[nx,1]	OF oSec3 TITLE aCamPS3[nx,5] SIZE aCamPS3[nx,3] PICTURE aCamPS3[nx,6]
	Next nx
		
// Seção 4  Resumo de consumo
DEFINE SECTION oSec4 OF oReport TITLE STR0004 TABLES "SC2","SB1","SD4","SD3" AUTO SIZE 
	oSec4:SetTotalInLine(.F.)	
	oSec4:SetAutoSize(.T.) 		
	oSec4:SetReadOnly(.T.) 		

	For nx := 1 To Len(aArqTem1)	
		DEFINE CELL NAME aArqTem1[nx,1]	OF oSec4 TITLE aArqTem1[nx,5] SIZE aArqTem1[nx,3] PICTURE aArqTem1[nx,6]
	Next nx
	
// Seção 5 Endereçamento
DEFINE SECTION oSec5 OF oReport TITLE STR0004 TABLES "SC2","SB1","SD4","SD3" AUTO SIZE 
	oSec5:SetTotalInLine(.F.)	
	oSec5:SetAutoSize(.T.) 		
	oSec5:SetReadOnly(.T.) 		

	For nx := 1 To Len(aCamPS5)
		DEFINE CELL NAME aCamPS5[nx,1]	OF oSec5 TITLE aCamPS5[nx,5] SIZE aCamPS5[nx,3] PICTURE aCamPS5[nx,6]	
	Next nx
Return oReport
							
/*
############################################################################
# Função   : PrintReport                                                   #
# Descrição: Impressão do relatório                                        #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 02/09/2015                                                    #  
############################################################################
*/
Static Function PrintReport(oReport)
Local nx,ny,aSD3,aSD4,aSDB,lSegue,vVetTotR := {0,0}  
Local oSec1 := oReport:Section(1)
Local oSec2 := oReport:Section(2)
Local oSec3 := oReport:Section(3)
Local oSec4 := oReport:Section(4)
Local oSec5 := oReport:Section(5)

AGRAREAORDE('SC2',1)
DbSeek(Xfilial("SC2")+MV_PAR09,.T.)
oReport:SetMeter(LastRec())
While !Eof() .And. SC2->C2_FILIAL = Xfilial("SC2") .And. SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN <= MV_PAR10
	lSegue := .t.
	oReport:IncMeter()
   // Considera TSI	
	If MV_PAR11 = 2 
   	If AGRIFDBSEEK("NP9",'1'+SC2->C2_PRODUTO,6,.f.)
			lSegue := .f.
		End
	EndIf
	
	If lSegue
		AGRIFDBSEEK("SB1",SC2->C2_PRODUTO,1,.f.)
		// Testa produto,grupo e data
		If SB1->B1_COD >= MV_PAR05 .And. SB1->B1_COD <= MV_PAR06 .And. SB1->B1_GRUPO >= MV_PAR03 .And. SB1->B1_GRUPO <= MV_PAR04;
			.And. SC2->C2_EMISSAO >= MV_PAR07 .And. SC2->C2_EMISSAO <= MV_PAR08
			cOpX := Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
			cOpQ := cOpX+Space(Len(SD3->D3_OP)-Len(cOpX))
		 // Busca a estrutura
			cAliasD4 := GetNextAlias()
 			cQueryD4 := " SELECT SD4.D4_COD,SD4.D4_QTDEORI,SD4.D4_QUANT,SD4.D4_LOCAL FROM "+RetSqlName("SD4")+" SD4 "
			cQueryD4 += " WHERE SD4.D4_FILIAL = '"+Xfilial("SD4")+"'"
			cQueryD4 += " AND SD4.D4_OP = '"+cOpQ+"' AND SD4.D4_COD >= '"+MV_PAR12+"' AND SD4.D4_COD <= '"+MV_PAR13+"'"
			cQueryD4 += " AND SD4.D_E_L_E_T_ = '' "
			cQueryD4 += " Order by D4_COD "
			cQueryD4 := ChangeQuery(cQueryD4)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryD4),cAliasD4,.F.,.T.)
		
			aSC2 := {{cOpQ,SC2->C2_LOCAL,SC2->C2_QUANT,Alltrim(SC2->C2_PRODUTO)+" - "+SubStr(SB1->B1_DESC,1,30),SB1->B1_UM,0,0}}
			aSD3 := {}
			aSD4 := {}
			aSDB := {}
			                                                                                                                                                         
			DbGoTop()
			While !Eof() .And. !Empty((cAliasD4)->D4_COD)
				AGRIFDBSEEK("SB1",(cAliasD4)->D4_COD,1,.f.)
				Aadd(aSD4,{(cAliasD4)->D4_COD,SubStr(SB1->B1_DESC,1,40),SB1->B1_UM,(cAliasD4)->D4_QTDEORI,0,(cAliasD4)->D4_QTDEORI})
				AGRDBSELSKIP(cAliasD4)
			End
			ARGCLOSEAREA(cAliasD4)
				
			// Movimentação da OP
			cAliasD3 := GetNextAlias()
 			cQueryD3 := " SELECT SD3.D3_COD,SD3.D3_QUANT,SD3.D3_LOCAL,SD3.D3_CF,SD3.D3_LOTECTL,SD3.D3_LOCALIZ,SD3.D3_USUARIO,"
 			cQueryD3 += "SD3.D3_EMISSAO,SD3.D3_UM,SD3.D3_QTSEGUM,SD3.D3_SEGUM,SD3.D3_NUMSEQ,SD3.D3_DOC FROM "+RetSqlName("SD3")+" SD3 "
			cQueryD3 += " WHERE SD3.D3_FILIAL = '"+Xfilial("SD3")+"'"
			cQueryD3 += " AND SD3.D3_OP = '"+cOpQ+"'"
			cQueryD3 += " AND (SD3.D3_CF = 'RE1' OR SD3.D3_CF = 'RE0' OR SD3.D3_CF = 'PR0')"
			cQueryD3 += " AND SD3.D3_ESTORNO <> 'S'
			cQueryD3 += " AND SD3.D_E_L_E_T_ = '' "
			cQueryD3 += " Order by D3_OP,D3_LOTECTL,D3_COD,D3_EMISSAO "
			cQueryD3 := ChangeQuery(cQueryD3)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryD3),cAliasD3,.F.,.T.)
			lTemSD3 := .f.                                                                                                                                                         
			DbGoTop()
			While !Eof() .And. !Empty((cAliasD3)->D3_COD)
			  // Testa lote
		 		If (cAliasD3)->D3_LOTECTL >= MV_PAR01 .And. (cAliasD3)->D3_LOTECTL <= MV_PAR02 
					lTemSD3 := .T.
		 			If SC2->C2_PRODUTO = (cAliasD3)->D3_COD .And. (cAliasD3)->D3_CF = "PR0"
	             	aSC2[1,6] += (cAliasD3)->D3_QUANT
						aSC2[1,7] := aSC2[1,3]-aSC2[1,6]
					 
						// Gera lotes de consumo
						Aadd(aSD3,{(cAliasD3)->D3_LOTECTL,(cAliasD3)->D3_LOCAL,Stod((cAliasD3)->D3_EMISSAO),(cAliasD3)->D3_USUARIO,;
						           (cAliasD3)->D3_QUANT,(cAliasD3)->D3_UM,(cAliasD3)->D3_QTSEGUM,(cAliasD3)->D3_SEGUM})
						cOrig := "SD3"
                cTMdb := "499"
                cTipd := "D" 
						aConsSDB := AGRBUSREGIS("SDB",xFilial("SDB")+(cAliasD3)->D3_COD+(cAliasD3)->D3_LOCAL+(cAliasD3)->D3_NUMSEQ+(cAliasD3)->D3_DOC,1,.t.,.f.,;
                	"SDB->DB_FILIAL = '"+XFILIAL('SDB')+"' .And. SDB->DB_PRODUTO = '"+(cAliasD3)->D3_COD+"' .And. SDB->DB_NUMSEQ = '"+(cAliasD3)->D3_NUMSEQ+"' .And. SDB->DB_DOC = '"+(cAliasD3)->D3_DOC+"'",;
             			{{"DB_ITEM"},{"DB_LOTECTL"},{"DB_LOCALIZ"},{"DB_QUANT"}},;
             			"SDB->DB_ORIGEM = '"+cOrig+"' .And. SDB->DB_TM = '"+cTMdb+"' .And. SDB->DB_LOTECTL = '"+(cAliasD3)->D3_LOTECTL+"' .And. SDB->DB_TIPO = '"+cTipD+"' .And. SDB->DB_LOCAL = '"+(cAliasD3)->D3_LOCAL+"'","M")
  		                         
						For ny := 1 To Len(aConsSDB[2])
							Aadd(aSDB,{aConsSDB[2,ny,1],aConsSDB[2,ny,2],aConsSDB[2,ny,3],aConsSDB[2,ny,4]}) 
			  			Next ny           
			  		Else
						// Gera itens da estrutura
						nPosi := aScan(aSD4,{|x| Alltrim(x[1]) == Alltrim((cAliasD3)->D3_COD)})
 				 		If nPosi > 0
						   aSD4[nPosi,5] += (cAliasD3)->D3_QUANT //4]
						   aSD4[nPosi,6] := aSD4[nPosi,4]-aSD4[nPosi,5]
						EndIf   
					EndIf
				EndIf	  
				AGRDBSELSKIP(cAliasD3)
			End 
			ARGCLOSEAREA(cAliasD3)
		
			ARGSETIFARQUI(cAliaTR1)
					
			oSec1:Init()
			For nx := 1 To Len(aSC2)
				For ny := 1 To Len(aCamPS1)
 					oSec1:Cell(aCamPS1[ny,1]):SetValue(aSC2[nx,ny])
 					If Valtype(aSC2[nx,ny]) = "N" 			   
 					 	oSec1:Cell(aCamPS1[ny,1]):SetHeaderAlign("RIGHT")
 					EndIf
				Next ny	
				oSec1:PrintLine()
			Next nx	
			oSec1:Finish() 
		
			If !Empty(aSD3)
				oReport:Skipline(1)
		  		oReport:PrintText(STR0001)
				oReport:Skipline(1)
			
				oSec2:Init()
				For nx := 1 To Len(aSD3)
					For ny := 1 To Len(aCamPS2)
 						oSec2:Cell(aCamPS2[ny,1]):SetValue(aSD3[nx,ny])
 						If Valtype(aSD3[nx,ny]) = "N" 			   
 					 		oSec2:Cell(aCamPS2[ny,1]):SetHeaderAlign("RIGHT")
	 					EndIf 	
					Next ny	
					oSec2:PrintLine()
				Next nx	
				oSec2:Finish() 
		   EndIf
		   
			oSec5:Init()
			For nx := 1 To Len(aSDB)
				For ny := 1 To Len(aCamPS5)
 					oSec5:Cell(aCamPS5[ny,1]):SetValue(aSDB[nx,ny])
 					If Valtype(aSDB[nx,ny]) = "N" 			   
	 				 	oSec5:Cell(aCamPS5[ny,1]):SetHeaderAlign("RIGHT")
 					EndIf 	
				Next ny	
				oSec5:PrintLine()
			Next nx	
			oSec5:Finish() 
		  	
			oSec3:Init()
			For ny := 1 To Len(aSD4)
				For nx := 1 To Len(aCamPS3)
					oSec3:Cell(aCamPS3[nx,1]):SetValue(aSD4[ny,nx])
					If Valtype(aSD4[ny,nx]) = "N" 			   
 					 	oSec3:Cell(aCamPS3[nx,1]):SetHeaderAlign("RIGHT")
 					EndIf
 				Next nx
				oSec3:PrintLine()
				// Resumo
				If !AGRIFSEETRB(cAliaTR1,aSD4[ny,1],1,.F.)
					AGRTRAVAREG(cAliaTR1,.T.)
					(cAliaTR1)->COMPO  := aSD4[ny,1]
					AGRIFDBSEEK("SB1",(cAliaTR1)->COMPO,1,.f.)
					(cAliaTR1)->DESCRI := SubStr(SB1->B1_DESC,1,40)
					(cAliaTR1)->UM     := SB1->B1_UM
				Else
					AGRTRAVAREG(cAliaTR1,.f.)
				EndIf	
				(cAliaTR1)->QTDPRC  += aSD4[ny,4]
				(cAliaTR1)->QTDCONC += aSD4[ny,5]
				(cAliaTR1)->QUANTDI := (cAliaTR1)->QTDPRC - (cAliaTR1)->QTDCONC
				AGRDESTRAREG(cAliaTR1)
			Next nx	
			oSec3:Finish() 
			oReport:Skipline(1)
		EndIf
	EndIf		
	AGRDBSELSKIP("SC2")
End
   
ARGSETIFARQUI(cAliaTR1)
If reccount() > 0
	oReport:Skipline(1)
	oReport:PrtLeft(STR0004)
	oReport:Skipline(1)
EndIf

While !oReport:Cancel() .And. (cAliaTR1)->(!Eof())
	oSec4:Init()
	For ny := 1 To Len(aArqTem1)
		cVald := "(cAliaTR1)->"+aArqTem1[ny,1]		
		oSec4:Cell(aArqTem1[ny,1]):SetValue(&cVald)
		oSec4:Cell(aArqTem1[ny,1]):SetPicture(aArqTem1[ny,6])
		If Valtype(&cVald) = "N" 			   
			oSec4:Cell(aArqTem1[ny,1]):SetHeaderAlign("RIGHT")
		EndIf
 	Next ny
 	oSec4:PrintLine()
 	vVetTotR[1] += (cAliaTR1)->QTDPRC
	vVetTotR[2] += (cAliaTR1)->QTDCONC 
	(cAliaTR1)->(dbSkip())
End
oSec4:Finish()
AGRDELETRB(cAliaTR1,cNomeTR1)

If MV_PAR14 = 2
	oReport:PrtRight("_______________"+Space(40))
	oReport:PrtRight("_______________"+Space(21))
	oReport:PrtRight("_______________"+Space(4))
	oReport:Skipline(1)
	oReport:PrtRight(TransForm(vVetTotR[1]            ,'@E 999,999,999,999.99')+Space(40))
	oReport:PrtRight(TransForm(vVetTotR[2]            ,'@E 999,999,999,999.99')+Space(21))
	oReport:PrtRight(TransForm(vVetTotR[1]-vVetTotR[2],'@E 999,999,999,999.99')+Space(4))
EndIf  
Return