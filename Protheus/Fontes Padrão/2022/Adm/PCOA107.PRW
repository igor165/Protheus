#INCLUDE "PCOA107.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA107   �Autor  �Jair Ribeiro        � Data �  11/20/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de amarracao entre usuario e planilha de planejamento ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

		Help("   ",1,"NOPCOA107",,STR0006,1,0) // "Acesso ao Controle do Planejamento desabilidade, verificar o conte�do do par�metro MV_PCOCAPL"

	EndIf
	
Return Nil		

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA107USR�Autor  � Jair Ribeiro		 � Data �11/20/10     ���
�������������������������������������������������������������������������͹��
���Desc.     �  Tela de selecao de usuarios                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                         	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |FGrvDados �Autor  �Microsiga           � Data �  10/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Efetua alteracoes no banco de dados                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaHeader�Autor  �Alvaro Camillo Neto � Data �  19/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o Aheader da getdados                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESTRE                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaHeader(cAlias,cCampos,cExcessao,aHeader)
Local   aArea		:= (cAlias)->(GetArea())
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que n�o conciderados

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaAcols �Autor  �Alvaro Camillo Neto � Data �  19/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Func�a que cria Acols                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�aHeader : aHeader aonde o aCOls ser� baseado                ���
���          �cAlias  : Alias da tabela                                   ���
���          �nIndice : Indice da tabela que sera usado para              ���
���          �cComp   : Informacao dos Campos para ser comparado no While ���
���          �nOpc    : Op��o do Cadastro                                 ���
���          �aCols   : Opcional caso queira iniciar com algum elemento   ���
�������������������������������������������������������������������������͹��
���Uso       � ESTRE                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA107   �Autor  �Microsiga           � Data �  06/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata o nome do usuario, atraves do codigo                  ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA107                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
			Help("   ",1,"NOUSERPCOA107",,STR0005,1,0) //"O usu�rio digitado j� encontra-se na planilha, favor selecionar outro c�digo de usu�rio."
			lRet := .F.
			oGetDados:Refresh()		
		EndIf
	Next nFor
EndIf

Return lRet
