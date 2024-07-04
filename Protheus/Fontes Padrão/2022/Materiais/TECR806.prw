#Include 'Protheus.ch'
#Include "report.ch"
#Include 'Topconn.ch'
#Include "TECR806.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECR806
@description	Impressão do Checklist
@sample	 	TECR806() 
@param		Nenhum
@return		Nil
@author		filipe.goncalves
@since		24/06/2016
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECR806()
Local aArea := GetArea()	//Guarda a area atual
Local oReport	
Local oSection1
Local oSection2
Local oSection3

Private cPerg := "TECR806"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Tipo - 1-Entrada/2-Saída/3-Ambos                            ³
//³ MV_PAR02 : Contrato De ?                                               ³
//³ MV_PAR02 : Contrato Até ?                                              ³
//³ MV_PAR04 : Produto TFI De ?	                                           ³
//³ MV_PAR05 : Produto TFI Até ?                                           ³
//³ MV_PAR06 : Local De ?	                                               ³ 
//³ MV_PAR07 : Local Até ?	                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
Pergunte(cPerg, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a criacao do objeto oReport  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "TECR806" TITLE STR0001 PARAMETER "TECR806" ACTION {|oReport| PrintReport(oReport,cPerg)} //"Impressão do CheckList"
	oReport:SetLandscape() //Escolher o padrão de Impressao como Paisagem 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao1 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SECTION oSection1 OF oReport TITLE STR0002 //"Dados CheckList"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao1  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE CELL NAME "TWD_TIPO"		OF oSection1 TITLE STR0005 ALIAS "TWD"
		DEFINE CELL NAME "TFI_CONTRT"	OF oSection1 ALIAS "TFI"
		DEFINE CELL NAME "ABS_DESCRI"	OF oSection1 ALIAS "ABS"
		DEFINE CELL NAME "TFI_PRODUT" 	OF oSection1 ALIAS "TFI"
		DEFINE CELL NAME "TEW_TIPO"		OF oSection1 TITLE STR0006 ALIAS "TEW"
		DEFINE CELL NAME "TEW_NUMPED" 	OF oSection1 ALIAS "TEW"
		DEFINE CELL NAME "TFJ_TPFRET" 	OF oSection1 ALIAS "TFJ"
		DEFINE CELL NAME "A1_COD" 		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_LOJA" 		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_NOME" 		OF oSection1 ALIAS "SA1"         
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao2 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DEFINE SECTION oSection2 OF oSection1 TITLE STR0003 TABLE "TEW", "SB5", "SA1", "TFJ" LEFT MARGIN 5 //"Equipamentos" 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao2  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE CELL NAME "TEW_CODEQU"	OF oSection2 ALIAS "TEW"  	    
		DEFINE CELL NAME "TEW_BAATD"	OF oSection2 ALIAS "TEW"     
		DEFINE CELL NAME "B5_CEME"		OF oSection2 TITLE STR0007 ALIAS "SB5"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a secao3 do relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	DEFINE SECTION oSection3 OF oSection2 TITLE STR0004 TABLE "TWF", "TWC" LEFT MARGIN 10 //"Itens Checklist"	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as celulas que irao aparecer na secao3  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		DEFINE CELL NAME "TWF_ITEM"		OF oSection3 ALIAS "TWF"  
		DEFINE CELL NAME "TWF_EXEC"		OF oSection3 ALIAS "TWF"
		DEFINE CELL NAME "TWD_DESCIT"	OF oSection3 ALIAS "TWD"
	
oReport:PrintDialog()

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Gestão de serviços º Data ³  27/06/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Selecao dos itens a serem impressos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGATEC                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport,cPerg)
Local oSection1 	:= oReport:Section(1)						//Define como seção Pai
Local oSection2     := oReport:Section(1):Section(1)			//Define a secao Filha 
Local oSection3     := oReport:Section(1):Section(1):Section(1)	//Define a secao Neta 
Local oFont1     	:= TFont():New("Times New Roman",9,12 ,.T.,.F.,5,.T.,5,.T.,.F.) 
Local cAlias 		:= GetNextAlias()
Local cChave1		:= ""
Local cChave2		:= ""
Local cWhere	:= ""

Pergunte( cPerg , .F. )

If MV_PAR01 == 1
	cWhere += "AND (TWD.TWD_TIPO = '1' OR TWD.TWD_TIPO = '3')"
ElseIf MV_PAR01 == 2
	cWhere += "AND (TWD.TWD_TIPO = '2' OR TWD.TWD_TIPO = '3')"
EndIf

cWhere	:= '%' + cWhere + '%'

MakeSqlExp(cPerg)
	
BEGIN REPORT QUERY oSection1
	BEGIN REPORT QUERY oSection2
		BEGIN REPORT QUERY oSection3

			BeginSql alias cAlias

				Select TWD.TWD_TIPO, TFI.TFI_CONTRT, ABS.ABS_DESCRI, TEW.TEW_TIPO, TFI.TFI_PRODUT, SB5.B5_CEME, TEW.TEW_NUMPED, 
				       SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, TFJ.TFJ_TPFRET, TEW.TEW_CODEQU, TEW.TEW_BAATD, SB5.B5_CEME, 
				       TWF.TWF_ITEM, TWF.TWF_EXEC, TWD.TWD_DESCIT
				  From %Table:TWF% TWF 
				       INNER JOIN %Table:TWC% TWC ON TWC.%NotDel%
				                                 AND TWC.TWC_FILIAL = %xfilial:TWC%
				                                 AND TWC.TWC_CODIGO = TWF.TWF_CODTWC
				       INNER JOIN %Table:TWD% TWD ON TWD.%NotDel%
				                                 AND TWD.TWD_FILIAL = %xfilial:TWD%
				                                 AND TWD.TWD_CODTWC = TWC.TWC_CODIGO
				                                 AND TWD.TWD_ITEM = TWF.TWF_ITEM
				       INNER JOIN %Table:TEW% TEW ON TEW.%NotDel%
				                                 AND TEW.TEW_FILIAL = %xfilial:TEW%
				                                 AND TEW.TEW_CODMV = TWF.TWF_CODTEW
				       INNER JOIN %Table:TFI% TFI ON TFI.%NotDel%
				                                 AND TFI.TFI_FILIAL = %xfilial:TFI%
				                                 AND TFI.TFI_COD = TWF.TWF_CODTFI
				       INNER JOIN %Table:TFL% TFL ON TFL.%NotDel%
				                                 AND TFL.TFL_FILIAL = %xfilial:TFL%
				                                 AND TFL.TFL_CODIGO = TFI.TFI_CODPAI
				       INNER JOIN %Table:TFJ% TFJ ON TFJ.%NotDel%
				                                 AND TFJ.TFJ_FILIAL = %xfilial:TFJ%
				                                 AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
				       INNER JOIN %Table:SB5% SB5 ON SB5.%NotDel%
				                                 AND SB5.B5_FILIAL = %xfilial:SB5%
				                                 AND SB5.B5_COD = TFI.TFI_PRODUT
				       INNER JOIN %Table:SA1% SA1 ON SA1.%NotDel%
				                                 AND SA1.A1_FILIAL = %xfilial:SA1%
				                                 AND SA1.A1_COD = TFJ.TFJ_CODENT
				                                 AND SA1.A1_LOJA = TFJ.TFJ_LOJA 
				       INNER JOIN %Table:ABS% ABS ON ABS.%NotDel%
				                                 AND ABS.ABS_FILIAL = %xfilial:ABS%
				                                 AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
				 Where TWF.TWF_FILIAL = %xfilial:TWF% 
				   AND TWF.%NotDel% 
				   AND TFJ.%NotDel%
				       %Exp:cWhere%
				   AND TFI.TFI_CONTRT >= %Exp:MV_PAR02% 
				   AND TFI.TFI_CONTRT <= %Exp:MV_PAR03% 
				   AND TFI.TFI_PRODUT >= %Exp:MV_PAR04% 
				   AND TFI.TFI_PRODUT <= %Exp:MV_PAR05% 
				   AND TFI.TFI_LOCAL >= %Exp:MV_PAR06% 
				   AND TFI.TFI_LOCAL <= %Exp:MV_PAR07%
				 ORDER BY TWD.TWD_TIPO, TEW.TEW_CODEQU, TWF.TWF_ITEM

			EndSql

		END REPORT QUERY oSection3
	END REPORT QUERY oSection2
END REPORT QUERY oSection1

dbSelectArea(cAlias)
While !oReport:Cancel() .And. !(cAlias)->(Eof())
	oSection1:Init()
	oSection1:PrintLine()
	cChave1	:= (cAlias)->TWD_TIPO
	While !oReport:Cancel() .And. !(cAlias)->(Eof()) .AND. cChave1	== (cAlias)->TWD_TIPO
		oSection2:Init()
		oSection2:PrintLine()
		cChave2	:= (cAlias)->TWD_TIPO + (cAlias)->TEW_CODEQU 
		oSection3:Init()
		While !oReport:Cancel() .And. !(cAlias)->(Eof()) .AND. cChave2	== (cAlias)->TWD_TIPO + (cAlias)->TEW_CODEQU
			oSection3:PrintLine()
			(cAlias)->(dbSkip())
		EndDo
		oSection3:Finish()
		oSection2:Finish()
	EndDo
	oSection1:Finish()
EndDo
(cAlias)->(DbCloseArea())
Return Nil