#INCLUDE "HSPAHA93.ch"
#INCLUDE "protheus.CH"
#INCLUDE "topconn.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA93  º Autor ³ Marcelo Jose       º Data ³  09/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE ENDERECOS DO SAME-SPP                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo jose³09/02/06³xxxxxx³ Foram refeitas as rotinas, substituido o ³±±
±±³            ³        ³      ³ axCadastro por mBrowse, e suas respecti- ³±±
±±³            ³        ³      ³ vas validacoes de inclusao e exclusao.   ³±±
±±³            ³        ³      ³ inclusao da rotina HS_GeMult,  HS_VALPAS ³±±
±±³Eduardo A.  ³02/06/06³100129³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HSPAHA93()
 Private cCadastro := STR0001   //"Cadastro de Enderecos"
 Private cPerg     := "HSPA93" 
 Private cDelFunc  := "HS_VEA93()" /* tudo OK (validacao) para exclusao*/
 Private aRotina   := MenuDef()
 dbSelectArea("GSD")
 dbSetOrder(1)
 mBrowse( 6,1,22,75,"GSD")
Return(Nil)        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±     HS_A93 Funcao que trata a INCLUSAO                                  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_A93(cAlias, nReg, nOpc)
 Local nOpcA := 0
 If nOpc == 3
  nOpcA := axInclui("GSD",, 3,,,, "HS_VIA93()") 
 EndIf                            
Return(nOpcA)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±     HS_VIA93 VALIDA INCLUSAO                                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_VIA93()
 Local lvai := .T. 
 If Inclui
  
  If DBSeek(xFilial("GSD") + M->GSD_CODEND )
   HS_MsgInf(STR0002, STR0004, STR0010)   //"Endereço já cadastrado."###"Atencao"###"Validação da Confirmação dos Dados"
   lvai := .F.
  EndIf
  
 	If Empty(M->GSD_TIPEND) .And. lvai
 		HS_MsgInf(STR0011, STR0004, STR0010) //"Selecione o Tipo de Endereço."###"Atenção"###"Validação da Confirmação dos Dados"
 		lvai := .F.
 	EndIf

		If (M->GSD_ENDTIP = "2") .And. lvai
			If Empty(M->GSD_TERMIN)
				HS_MsgInf(STR0009, STR0004, STR0010) //"O Controle selecionado é do tipo Terminação, portanto o campo Terminações deve ser preenchido."###"Atenção"###"Validação da Confirmação dos Dados"
	 		lvai := .F.
			EndIf
		EndIf
 
 EndIf 
Return( lvai )

Function HS_AltA93(cAlias, nReg, nOpc)
 Local nOpcA := 0
 If nOpc == 4
  nOpcA := axAltera("GSD",, 4,,,, "HS_VEA93(.F.)") 
 EndIf                            
Return(nOpcA)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±     HS_VEA93 VALIDA EXCLUSAO                                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_VEA93(lDel)
 Local lvai := .T.,  _sAlias := Alias()
 
 Default lDel := .T.
 
 If GSD->GSD_ENDTIP # "1" /* MultiProntuario ou Terminacao */
 	dbSelectArea("GSB")
 	dbSetOrder(2)
 	If DBSeek( xFilial("GSB") + GSD->GSD_CODEND ) .And. IIf(lDel, .T., M->GSD_EATIVO  == "1") /* Ocupado e Ativo = Nao*/
  	HS_MsgInf(STR0003, STR0004, STR0012) //"Este Endereço possui relacionamento entre Endereço x Prontuário, portanto não pode ser excluído ou desativado"###"Atenção"###"Validação da Exclusão/Desativação"
  	lvai := .F.         
 	EndIf       
 Else
 	If GSD->GSD_STATUS == "1" .And. IIf(lDel, .T., M->GSD_EATIVO  == "1") /* Ocupado e Ativo = Nao*/
 		HS_MsgInf(STR0013, STR0004, STR0012) //"Esta pasta esta com o Status Ocupado, portando não pode ser excluída ou desativada."###"Atenção"###"Validação da Exclusão/Desativação"
 		lvai := .F.
 	EndIf
 EndIf
 
 dbSelectArea(_sAlias)
 dbSetOrder(1)
 
 If lvai .And. lDel
  RecLock("GSD", .F.,.T.)
  DBDelete()
  MsUnLock()
 EndIf

Return( lvai )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±     HS_GEMULT - GERA ENDERECOS AUTOMATICOS PARA PASTAS                  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_GeraE()
 Local nMaiorReg := 0 , nCtaFor := 0, nLenCod := 0
 Local cSql := ""

 GeraSX1( cPerg )
 If !Pergunte(cPerg,.T.)
 	return( Nil )
 EndIf         

 If MsgYesNo(STR0007 + ALLTRIM(STR(MV_PAR01,6,0)) + STR0008)
  
 	cSql := " SELECT MAX(GSD.GSD_CODEND) GSD_MAX"
	
		cSql += " 	FROM " + RetSQLName("GSD") + " GSD"

		cSql += " 	WHERE GSD.GSD_FILIAL =  '" + xFilial("GSD") + "'" 
 	cSql += "  		AND GSD.D_E_L_E_T_ <> '*'"
 	cSql += "  		AND GSD.GSD_ENDTIP =  '1'" 
 
 	cSql := ChangeQuery(cSql)

 	TCQUERY cSql NEW ALIAS "QRY"
 	nMaiorReg := Val( IIf(!Empty(QRY->GSD_MAX), QRY->GSD_MAX, "1") )          
 	DbCloseArea()
  
  dbSelectArea("GSD")  
  dbSetOrder(1)
  
  nLenCod := Len(GSD->GSD_CODEND)
  
  M->GSD_LOTE := CriaVar("GSD_LOTE")
  M->GSD_LOTE := HS_VSxeNum("GSD", "M->GSD_LOTE", 1)
 
  For nCtafor := 1 to MV_PAR01 
  	
  	While DBSeek( xFilial("GSD") + PadL(nMaiorReg, nLenCod, "0") )
  		nMaiorReg++
  		DbSkip()
  	EndDo
   RecLock("GSD", .T.)
    GSD->GSD_FILIAL := xFILIAL("GSD")
    GSD->GSD_CODEND := PadL(nMaiorReg, nLenCod, "0")
    GSD->GSD_DESEND := "Pasta " + PadL(nMaiorReg, nLenCod, "0")
    GSD->GSD_TIPEND := ""
    GSD->GSD_EATIVO := "0"
    GSD->GSD_ENDTIP := "1" /* PASTA */
    GSD->GSD_STATUS := "0"
    GSD->GSD_ARQEXT := "0"
    GSD->GSD_LOTE   := M->GSD_LOTE
    GSD->GSD_LOGARQ := HS_LOGARQ()
   MsUnLock()
   nMaiorReg++
  Next
 EndIf

Return ( Nil ) 
                                                                             
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± FUNCAO GERASX1() PADRAO    AUTOR: MARCELO JOSE        DATA: 19/01/2006  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraSX1(cPerg) 
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}
Local aPergs   := {}
Local _sAlias := Alias()

DbSelectArea("SX1")
If DbSeek(cPerg) // Se encontrar a pergunta retorna, pois ja foi criada.
	DbSelectArea(_sAlias)
	Return
Endif

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Qtde de Enderecos Pasta a Gerar   ")
AADD(aHelpSpa,"                                  ")
AADD(aHelpEng,"                                  ")
AADD(aPergs,{"Quantidade","Quantidade","Quantidade","mv_ch1","N",06,0,1,"G","","mv_par01","","","","","","",;
"","","","","","","","","","","","","","","","","","","","N","","",;
aHelpPor,aHelpEng,aHelpSpa})   

AjustaSx1(cPerg, aPergs)
DbSelectArea(_sAlias)
Return (nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA93  ºAutor  ³Eduardo Alves       º Data ³  02/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada para validacao dos campos.	               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VldA93()
	Local lRet := .T.
	
	/* Controle */
	If ReadVar() == "M->GSD_ENDTIP"
		If (M->GSD_ENDTIP = "1")
			HS_MsgInf(STR0014, STR0004, STR0015) //"Controle não permitido neste cadastro. Para efetuar esta operação selecione a opção Gerar Pastas"###"Atenção"###"Validação dos Campos"
			lRet := .F.
		EndIf
	/* Status */
	ElseIf ReadVar() == "M->GSD_EATIVO"
	 lRet := HS_VEA93(.F.)	
	EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RCodEndºAutor  ³Daniel Peixoto      º Data ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna o codigo do endereco do prontuario de   º±±
±±º          ³ um paciente de acordo com o Tipo do seu atendimento        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RCodEnd(cAtendi, cRegGer, cRegAte)
 Local cCodEnd  := ""
 Local cSql     := ""
 Local aAreaOld := GetArea()
 Local cTipEnd  := IIF(cAtendi == "0", "3", cAtendi)
  
 cSql := "SELECT GSB_CODEND"
 cSql += " FROM " + RetSqlName("GSB") + " GSB "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGGER = GSB.GSB_REGGER AND GCY.GCY_REGATE = '" + cRegAte + "' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_CODEND = GSB.GSB_CODEND AND GSD.GSD_TIPEND = '" + cTipEnd + "' AND GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' "
 cSql += " WHERE GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' "
 cSql += "	  AND GSB.GSB_REGGER = '" + cRegGer + "' "

 cSql := ChangeQuery(cSql)

 DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGSD", .F., .F.)

 DbSelectArea("TMPGSD")

 cCodEnd := TMPGSD->GSB_CODEND 

 DbCloseArea()

 RestArea(aAreaOld)

Return(cCodEnd)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 06/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{"Pesquisar"     ,"AxPesqui"   ,0,1, 0, nil},; //"Pesquisar"
                     {"Visualizar"    ,"AxVisual"   ,0,2, 0, nil},; //"Visualizar"
                     {"Incluir"       ,"HS_A93"     ,0,3, 0, nil},; //"Incluir"
                     {"Alterar"       ,"AxAltera"   ,0,4, 0, nil},; //"Alterar"
                     {"Gerar Pastas"  ,"HS_GeraE()" ,0,3, 0, nil},; //"Gerar Pastas"                      
                     {"Excluir"       ,"axDeleta"   ,0,5, 0, nil}}  //"Excluir"
Return(aRotina)