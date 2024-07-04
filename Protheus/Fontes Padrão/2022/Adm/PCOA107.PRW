#INCLUDE "PCOA107.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA107   ºAutor  ³Jair Ribeiro        º Data ³  11/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de amarracao entre usuario e planilha de planejamento º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA107()
	
	Local cContAce		:= SuperGetMv("MV_PCOCAPL",,"2") // 1=Liga ou 2=Desliga o controle de usuarios
	
	Private aRotina 	:= {{STR0001	,"AxPesqui"		,0,1} ,; //"Pesquisar"
	             			{STR0002	,"PCOA107USR()"	,0,2} ,; //"Visualizar"
	           				{STR0003 	,"PCOA107USR()"	,0,4} }	  //"Alterar"
	
	If cContAce == "1"

		DbSelectArea("ALV")
		ALV->(DbSetOrder(1))
		mBrowse( 6,1,22,75,"ALV")

	Else

		Help("   ",1,"NOPCOA107",,STR0006,1,0) // "Acesso ao Controle do Planejamento desabilidade, verificar o conteúdo do parâmetro MV_PCOCAPL"

	EndIf
	
Return Nil		

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA107USRºAutor  ³ Jair Ribeiro		 º Data ³11/20/10     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Tela de selecao de usuarios                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                         	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOA107USR(cAlias,nReg,nOpc)
	Local aEditCpo	:= {"AMU_CODUSR"} 													//Campos editaveis na msgetdados	
    Local oDlg		:= Nil																//Objetos MsDialog
	Local aTamDlg	:= FWGetDialogSize(oMainWnd)
	Local cLinhaOk	:= "" // "U_PC107LOK()"
	Local cCPOs 	:= ""
	Local aHeader	:= {}
	Local aCols		:= {}
	Local lRet		:= PCO490VAP() // Verifica se o usuario tem acesso a planilha
	
	If lRet	
		Private oGetDados	:= Nil																//Objeto da getdados	
		Private cMsgErr 	:= ""
			
		cCPOs := "AMU_FILIAL|AMU_CODPLN"
		
		aHeader	:= CriaHeader("AMU",NIL,cCPOs,aHeader)
		aCols	:= CriaAcols(aHeader,"AMU",2,xFilial("AMU")+ALV->ALV_CODIGO,nOpc,aCols)		
	
		oDlg := MSDialog():New(aTamDlg[1],aTamDlg[2],aTamDlg[3],aTamDlg[4],STR0004,,,,,,,,,.T.) //"Controle do Planejamento"
			oGetDados := MsNewGetDados():New(015,015,365,362,GD_UPDATE+GD_DELETE+GD_INSERT	,/*cLinhaOk*/,,"+AMU_ITPLN",aEditCpo,,,"AllWaysTrue",,"AllWaysTrue",oDlg,aHeader,aCols)
			oGetDados:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
		oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,{|| FGrvDados(oGetDados),oDlg:End()},{||oDlg:End()}))
	EndIf
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FGrvDados ºAutor  ³Microsiga           º Data ³  10/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Efetua alteracoes no banco de dados                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FGrvDados(oGetDados)
	Local nX		:= 0
	Local nJ		:= 0
	Local lGrava	:= .F.
	Local nPosItem	:= Ascan(oGetDados:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMU_ITPLN")})
	Local nItem		:= 1

	DbSelectArea("AMU")
	AMU->(DbSetOrder(2)) // AMU_FILIAL+AMU_CODPLN+AMU_ITPLN+AMU_CODUSR
	For nX:=1 To Len(oGetDados:aCols)
		lGrava := MsSeek(xFilial("AMU")+ALV->ALV_CODIGO+oGetDados:aCols[nX,nPosItem])
		If oGetDados:aCols[nX,Len(oGetDados:aHeader)+1] .And. lGrava
			RecLock("AMU",!lGrava)
				IF !AMU->( FkDelete( @cMsgErr ) )
					AMU->( RollBackDelTran( cMsgErr ) )
				EndIF
		   	MsUnLock()
		ElseIf !oGetDados:aCols[nX,Len(oGetDados:aHeader)+1]
			RecLock("AMU",!lGrava)
			AMU->AMU_FILIAL		:= xFilial("AMU")
		  	AMU->AMU_CODPLN		:= ALV->ALV_CODIGO
			For nJ:=1 to Len(oGetDados:aHeader)
				If AllTrim(oGetDados:aHeader[nJ,2]) == "AMU_ITPLN"
					FieldPut(FieldPos(oGetDados:aHeader[nJ,2]),StrZero(nItem,oGetDados:aHeader[nJ,4]))
				Else
					FieldPut(FieldPos(oGetDados:aHeader[nJ,2]),oGetDados:aCols[nX,nJ])
				EndIf
			Next nJ
			nItem++
		   	MsUnLock()
	 	EndIf
	Next nX
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaHeaderºAutor  ³Alvaro Camillo Neto º Data ³  19/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o Aheader da getdados                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESTRE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaHeader(cAlias,cCampos,cExcessao,aHeader)
Local   aArea		:= (cAlias)->(GetArea())
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que não conciderados

SX3->(dbSetOrder(1))
SX3->(MsSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao))
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;			// 02 - Campo
		SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		   , ;		// 09 - F3
		SX3->X3_CONTEXT   , ;       // 10 - Contexto
		SX3->X3_CBOX	  , ; 		// 11 - ComboBox
		SX3->X3_RELACAO   , } )   // 12 - Relacao
		
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaAcols ºAutor  ³Alvaro Camillo Neto º Data ³  19/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcõa que cria Acols                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aHeader : aHeader aonde o aCOls será baseado                º±±
±±º          ³cAlias  : Alias da tabela                                   º±±
±±º          ³nIndice : Indice da tabela que sera usado para              º±±
±±º          ³cComp   : Informacao dos Campos para ser comparado no While º±±
±±º          ³nOpc    : Opção do Cadastro                                 º±±
±±º          ³aCols   : Opcional caso queira iniciar com algum elemento   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESTRE                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols)
Local 	nX			:= 0
Local 	nCols     	:= 0
Local   aArea		:= (cAlias)->(GetArea())
DEFAULT aCols 		:= {}


(cAlias)->(dbSetOrder(nIndice))
(cAlias)->(MsSeek(cComp))
While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(AMU_FILIAL+AMU_CODPLN)) == ALLTRIM(cComp)
	aAdd(aCols,Array(Len(aHeader)+1))
	nCols++
	For nX := 1 To Len(aHeader)
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			aCols[nCols][nX] := UsrFullName(aCols[nCols][nX-1])
		Endif
	Next nX
	aCols[nCols][Len(aHeader)+1] := .F.
	(cAlias)->(dbSkip())
End
       
RestArea(aArea)
Return(aCols)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA107   ºAutor  ³Microsiga           º Data ³  06/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata o nome do usuario, atraves do codigo                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PCOA107                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCO107NAME()
Local aUser		:= {}
Local nPosNam	:= Ascan(oGetDados:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMU_NOMUSR")})
Local nPosUsr	:= Ascan(oGetDados:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMU_CODUSR")})
Local nPosItem	:= Ascan(oGetDados:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMU_ITPLN")})
Local cUser		:= M->AMU_CODUSR
Local lRet		:= UsrExist(cUser) // Valida se o usuario existe no cadastro de usuarios
Local nFor		:= 0

If lRet
	For nFor := 1 To Len(oGetDados:aCols)
		If oGetDados:aCols[nFor,nPosUsr] == cUser .And.;  // valida se o usuario existe no aCols
		  !oGetDados:aCols[nFor,Len(oGetDados:aHeader)+1] // valida deletado
			Help("   ",1,"NOUSERPCOA107",,STR0005,1,0) //"O usuário digitado já encontra-se na planilha, favor selecionar outro código de usuário."
			lRet := .F.
			oGetDados:Refresh()		
		EndIf
	Next nFor
EndIf

Return lRet
