#INCLUDE "Protheus.CH"
#INCLUDE "MNTA907.CH"

#DEFINE _nVERSAO 3 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA907
Painel de gest�o da Planta Gr�fica, possibilitando fazer controle de
todos os itens pr� adicionados apartir da rotina MNTA905, como gest�o de 
Ordem de Servi�o, Solicita��o de Servi�o e etc.

@author Vitor Emanuel Batista
@since 04/03/2010
@build 7.00.100601A-20100707
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA907
	Local lOpened := Type("oMainWnd") == "O"
	//��������������������������������������������Ŀ
	//�Guarda conteudo e declara variaveis padroes �
	//����������������������������������������������
	Local aNGBEGINPRM := If(lOpened,NGBEGINPRM(_nVERSAO,"MNTA907",{},.T.,.T.),{})
	Local oDlg,oTPanel
	
	//Variaveis de Largura/Altura da Janela
	Local aSize   := If(lOpened,MsAdvSize(,.f.,430),{0,0,0,0,(GetScreenRes()[1]-7),(GetScreenRes()[2]-85)})
	Local nLargura  := aSize[5]+2
	Local nAltura   := aSize[6]+If(PtGetTheme() = "MDI",120,0)
	Local lExect    := fValRunRot() //Verifica a execu��o da rotina.
	
	If lExect
		cCadastro := ""
	
		If !lOpened
			oDlg := tWindow():New( 0, 0, nAltura, nLargura, "",,,,,,,,CLR_BLACK,CLR_WHITE,,,,,,,.f. ) 
		Else
			Define Dialog oDlg Title "" From 22,0 To nAltura,nLargura COLOR CLR_BLACK, CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) Of oMainWnd Pixel
				oDlg:lMaximized := .T.
		EndIf
	
			oDlg:lEscClose := .F.
			oDlg:bValid := {|| oTPanel:Destroy()}
			oTPanel := TNGPG():New(oDlg,.F.)
				oTPanel:Activate()
	
		If !lOpened
			oDlg:Activate("MAXIMIZED")
		Else
			ACTIVATE DIALOG oDlg
		EndIf
	EndIf

	//��������������������������������������������Ŀ
	//�Retorna conteudo de variaveis padroes       �
	//����������������������������������������������
	NGRETURNPRM(aNGBEGINPRM)
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRunRot
Verifica se � permitido a execu��o da rotina.

@author Guilherme Benkendorf
@since 30/06/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValRunRot()
	Local lSigaMdtPs:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local lRet      := .T.

	If lSigaMdtPs
		MsgStop( STR0002 , STR0001 ) //"Prestador de Servi�o n�o tem acesso a �rvore L�gica."###"Aten��o"
		lRet := .F.
	Else
		//Verifica��o para a utiliza��o da Planta Grafica em MDT
		If nModulo == 35 
			If !FindFunction("MNT902VlId")
				Aviso(OemToAnsi(STR0001), OemToAnsi(STR0003), {"Ok"})	//"Atencao"#"Reposit�rio incompat�vel para esta opera��o, favor contatar o Administrador para atualizar."
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_CODAMB", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA1" , "TPTZE6" )
				lRet := .F.
			ElseIf !NGCADICBASE( "TAF_EVEMDT", "D", "TAF", .F. )
				NGINCOMPDIC( "UPDMDTA3" , "TQEKGE" )
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet