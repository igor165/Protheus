#INCLUDE "Mata915.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FILEIO.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Mata915   �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
�������������������������������������������������������������������������͹��
���Desc.     �Le o arquivo de retorno da Prefeitura Municipal de Sao Paulo���
���          �/ Resende referente as informacoes da Nota Fiscal Eletronica���
���          �Legislacao: Lei no. 14.097 de 08/12/2005 (Sao Paulo - SP)   ���
���          �Legislacao: Lei no. 2.604 de 01/08/2007 (Resende - RJ)      ���
���          �Legislacao: Lei no. 1.090 de 29/12/2006 (Manaus - AM)       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mata915(aWizard)

Local aArqTmp	:= {}
Local aCarga	:= {}
Local aMunic    := {}

Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local cCampos	:= ""
Local cMunic    := ""

Local lCarga 	:= .F.

Local nOpcA     := 1

Local oReport
Local oDlg
Local oBtOk
Local oBtCan
Local oBtPar
Local oMunic

Default aWizard := {}

Private lAutomato := IiF(IsBlind(),.T.,.F.)

If lAutomato
	Private aWizAuto := aWizard
EndIf

SM0->(DbGoTop())
SM0->(MsSeek(cEmpAnt+cFilAnt, .T.))

Private lResende   := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) == "RESENDE",.T.,.F.)
Private lManaus    := Iif(GetNewPar("MV_ESTADO","xx") == "AM" .And. Alltrim(SM0->M0_CIDENT) == "MANAUS",.T.,.F.)
Private lSAndre    := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "SANTO ANDRE",.T.,.F.)
Private lEspSanto  := Iif(GetNewPar("MV_ESTADO","xx") == "ES" .And. Alltrim(SM0->M0_CIDENT) == "VITORIA",.T.,.F.)
Private lRecife    := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Alltrim(SM0->M0_CIDENT) == "RECIFE",.T.,.F.)
Private lMacae     := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) $ "MACAE/MACA�",.T.,.F.)
Private lJoinville := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Alltrim(SM0->M0_CIDENT) == "JOINVILLE",.T.,.F.)
Private lBarueri   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "BARUERI",.T.,.F.)
Private lBMansa    := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) == "BARRA MANSA",.T.,.F.)
Private lItapevi   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "ITAPEVI",.T.,.F.)
Private lVRedonda  := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) == "VOLTA REDONDA",.T.,.F.)
Private lOsasco    := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "OSASCO",.T.,.F.) 
Private lSaopaulo  := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "SAO PAULO",.T.,.F.)
Private lRio       := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Alltrim(SM0->M0_CIDENT) == "RIO DE JANEIRO",.T.,.F.)
Private lSantParn  := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Alltrim(SM0->M0_CIDENT) == "SANTANA DE PARNAIBA",.T.,.F.)
Private lTamCpo    := GetNewPar("MV_TAMCPO",.F.)

//�������������������������������������������������������������Ŀ
//�Somente efetua o processamento se todas as implementacoes da �
//�Nota Fiscal Eletronica tiverem sido feitas.                  �
//���������������������������������������������������������������
If Empty(cCampos)

	aAdd( aMunic, "S�o Paulo"  	)
	aAdd( aMunic, "Barueri"    	)
	aAdd( aMunic, "Resende"    	)
	aAdd( aMunic, "Manaus"     	)
	aAdd( aMunic, "Santo Andre"	)
	aAdd( aMunic, "Vitoria"    	)
	aAdd( aMunic, "Recife"     	)
	aAdd( aMunic, "Macae"      	)
	aAdd( aMunic, "Joinville"  	)
	aAdd( aMunic, "Barra Mansa"		)
	aAdd( aMunic, "Volta Redonda"	)
	aAdd( aMunic, "Rio de Janeiro"	)
	aAdd( aMunic, "Osasco"			)
	aAdd( aMunic, "Santana de Parna�ba"	)
	//�����������������������������������������������Ŀ
	//�Inicia o Combo, de acordo com o Municipio      �
	//�������������������������������������������������
	Do Case
		Case lBarueri
			cMunic := "Barueri"
		Case lResende
			cMunic := "Resende"
		Case lManaus
			cMunic := "Manaus"
		Case lSAndre
			cMunic := "Santo Andre"
		Case lEspSanto
			cMunic := "Vitoria"
		Case lRecife
			cMunic := "Recife"
		Case lMacae
			cMunic := "Macae"
		Case lJoinville
			cMunic := "Joinville"
		Case lBMansa
			cMunic := "Barra Mansa"
		Case lVRedonda
			cMunic := "Volta Redonda"
		Case lOsasco
			cMunic := "Osasco"
		Case lRio
			cMunic := "Rio de Janeiro"
		Case lSaopaulo
			cMunic := "S�o Paulo"
		Case lSantParn
			cMunic := "Santana de Parna�ba"
	EndCase

	If !lAutomato
		DEFINE MSDIALOG oDlg TITLE "Selecionar o Municipio" FROM 000,000 TO 100,500 Of oMainWnd pixel
		
		@ 005,005 combobox oMunic var cMunic items aMunic size 210,008 of oDlg pixel
		
		define sButton oBtOk  from 05,218 type 1 action (nOpcA := 1, oDlg:End()) enable of oDlg pixel
		define sButton oBtCan from 20,218 type 2 action (nOpcA := 0, oDlg:End()) enable of oDlg pixel
		define sButton oBtPar from 35,218 type 5 when .F. of oDlg pixel

		ACTIVATE MSDIALOG oDlg CENTER
	Else
		nOpcA := 1
	EndIF

	If nOpcA == 1

		If !lAutomato

			//���������������������������������������������������������Ŀ
			//�Apos a selecao do Combo atualiza a variavel do Municipio �
			//�����������������������������������������������������������
			lBarueri  := .F.
			lResende  := .F.
			lManaus   := .F.
			lSAndre   := .F.
			lEspSanto := .F.
			lRecife   := .F.
			lMacae    := .F.
			lJoinville:= .F.
			lBMansa   := .F.
			lVRedonda := .F.
			lOsasco   := .F.
			lSantParn := .F.

			Do Case
				Case cMunic == "Barueri"
					lBarueri := .T.
				Case cMunic  == "Resende"
					lResende := .T.
				Case cMunic  == "Manaus"
					lManaus  := .T.
				Case cMunic  == "Santo Andre"
					lSAndre  := .T.
				Case cMunic  == "Vitoria"
					lEspSanto:= .T.
				Case cMunic  == "Recife"
					lRecife  := .T.
				Case cMunic  == "Macae"
					lMacae   := .T.
				Case cMunic  == "Joinville"
					lJoinville:= .T.
				Case cMunic  == "Barra Mansa"
					lBMansa  := .T.
				Case cMunic == "Volta Redonda"
					lVRedonda := .T.
				Case cMunic == "Rio De Janeiro"
					lRio := .T.
				Case cMunic == "Osasco"
					lOsasco := .T.
				Case cMunic == "Santana de Parna�ba"
					lSantParn := .T.
			EndCase
		EndIf

		If Mta915Wiz()
			//������������������������������������������������������������������Ŀ
			//�Carrega no arquivo temporario as informacoes do arquivo de retorno�
			//��������������������������������������������������������������������
			Processa({|| aCarga := Mta915Le(@aArqTmp)})
			lCarga := aCarga[01]
			If lCarga
				//����������������������������������������������Ŀ
				//�Atualiza tabelas com as informacoes do retorno�
				//������������������������������������������������
				Processa({|| Mta915Atu(aCarga[02], aCarga[03])})

				If !lAutomato
					//����������������������������������������������������Ŀ
					//�Imprime o relatorio de conferencia personalizavel   �
					//������������������������������������������������������
					oReport := ReportDef()
					oReport:PrintDialog()
				EndIF
			Else
				cTitulo		:= STR0028 //"Importa��o n�o realizada"
				cErro		:= STR0029 //"A importa��o do arquivo de retorno n�o foi realizada "
				cErro		+= STR0030 //"por n�o existirem informa��es de retorno no arquivo "
				cErro		+= STR0031 //"texto informado. "
				cSolucao	:= STR0032 //"Verifique se o arquivo de retorno informado nas "
				cSolucao	+= STR0033 //"perguntas da rotina � o enviado pela prefeitura "
				cSolucao	+= STR0034 //"e processe esta rotina novamente."

				If !lAutomato
					xMagHelpFis(cTitulo,cErro,cSolucao)
				Else
					Aviso(cTitulo,cErro,{"OK"})
				EndIF

			Endif
			//�������������������������������������Ŀ
			//�Excluindo o arquivo temporario criado�
			//���������������������������������������
			dbSelectArea(aArqTmp[1,2])
			dbCloseArea()
			Ferase(aArqTmp[1,1]+GetDBExtension())
			Ferase(aArqTmp[1,1]+OrdBagExt())
		Endif
		
	Endif
	
Else
	cTitulo		:= STR0018				//"Implementa��o n�o efetuada"
	cErro		:= STR0019				//"A implementa��o do processo da Nota "
	cErro		+= STR0020				//"Fiscal Eletr�nica n�o foi efetuada corretamente, "
	cErro		+= STR0021				//"visto que existem tabelas e campos que "
	cErro		+= STR0022				//"n�o est�o dispon�veis no dicion�rio de dados."
	cErro		+= STR0027 + cCampos 	//"Campos: "
	cSolucao	:= STR0023				//"verifique a documenta��o que acompanha a rotina e "
	cSolucao	+= STR0024				//"execute todos os procedimentos indicados e processe "
	cSolucao	+= STR0025				//"esta rotina novamente."

	If !lAutomato
		xMagHelpFis(cTitulo,cErro,cSolucao)
	Else
		Aviso(cTitulo,cErro,{"OK"})
	EndIF

Endif

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Mta915Wiz   �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Monta a wizard com as perguntas a rotina de importacao        ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mta915Wiz()

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local aTxtPre 		:= {}
Local aPaineis 		:= {}

Local cTitObj1		:= ""
Local cMask			:= Replicate("X",245)
Local cMaskEsp		:= Replicate("X",TamSx3("F2_ESPECIE")[1])

Local nPos			:= 0

Local lRet			:= 0
Local cCab			:= ""

If !lAutomato

	//�����������������������������������������������Ŀ
	//�Verifica o cabecalho, de acordo com o Municipio�
	//�������������������������������������������������
	Do Case
		Case lResende
			cCab := "Prefeitura Municipal de Resende"
		Case lManaus
			cCab := "Prefeitura Municipal de Manaus"
		Case lSAndre
			cCab := "Prefeitura Municipal de Santo Andre"
		Case lEspSanto
			cCab := "Prefeitura Municipal de Vitoria"
		Case lRecife
			cCab := "Prefeitura Municipal de Recife"
		Case lMacae
			cCab := "Prefeitura Municipal de Macae"
		Case lItapevi
			cCab := "Prefeitura Municipal de Itapevi"
		Case lJoinville
			cCab := "Prefeitura Municipal de Joinville"
		Case lBarueri
			cCab := "Prefeitura Municipal de Barueri"
		Case lBMansa
			cCab := "Prefeitura Municipal de Barra Mansa"
		Case lVRedonda
			cCab := "Prefeitura Municipal de Volta Redonda"
		Case lOsasco
			cCab := "Prefeitura Municipal de Osasco"
		Case lRio
			cCab := "Prefeitura Municipal do Rio De Janeiro"
		Case lSaopaulo
			cCab := "Prefeitura Municipal de S�o Paulo"
		Case lSantParn
			cCab := "Prefeitura Municipal de Santana de Parna�ba"
	EndCase
		
	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�
	//�������������������������������������������
	aAdd(aTxtPre,STR0001) //"Importa��o da Nota Fiscal Eletr�nica"
	aAdd(aTxtPre,STR0002) //"Aten��o"
	aAdd(aTxtPre,STR0003) //"Preencha corretamente as informa��es solicitadas."
	aAdd(aTxtPre,Alltrim(STR0004)+" "+cCab+Alltrim(STR0005)+" "+Alltrim(STR0006))	
											//"Esta rotina ira importar o arquivo de retorno disponibilizado pela            "
											//"Prefeitura Municipal de S�o Paulo/Resende, contendo informa��es sobre as notas     "
											//"fiscais eletr�nicas geradas no per�odo."

	//�������������������������������������Ŀ
	//�Painel 1 - Informacoes da Empresa    �
	//���������������������������������������
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0007) //"Assistente de parametriza��o" 
	aAdd(aPaineis[nPos],STR0008) //"Informa��es sobre o arquivo de retorno: "
	aAdd(aPaineis[nPos],{})

	cTitObj1 :=	STR0009 //"Arquivo de retorno: "
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,245,,.T.})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,"Esp�cie do Documento Fiscal",,,,,,})
	aAdd(aPaineis[nPos][3],{2,"",cMaskEsp,1,,,,20})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	If lOsasco
	aAdd(aPaineis[nPos][3],{1,STR0083,,,,,,}) //Serie RPS
	aAdd(aPaineis[nPos][3],{2,"",,1,,,,3,,})
	EndIf

	lRet :=	xMagWizard(aTxtPre,aPaineis,"MTA915")
Else
	lRet := .T.
EndIf

Return(lRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Mta915Tmp   �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Cria o arquivo temporario para importacao                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mta915Tmp()

Local aArqNFE := {}
Local aArqTmp := {}
Local cArqNFE := ""

AADD(aArqNFE,{"NFE"			,"C",Iif(lTamCpo,6,TamSX3("FT_NFELETR")[1]),0})
AADD(aArqNFE,{"EMISSAO"		,"D",8,0})
AADD(aArqNFE,{"HORA"		,"C",6,0})
AADD(aArqNFE,{"VERIFICA"	,"C",TamSX3("FT_CODNFE")[1],0})
AADD(aArqNFE,{"RPS"			,"C",Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1]),0})
AADD(aArqNFE,{"SERIE"		,"C",TamSX3("FT_SERIE")[1],0})
AADD(aArqNFE,{"VALSERV"		,"N",TamSX3("FT_VALCONT")[1],TamSX3("FT_VALCONT")[2]})
AADD(aArqNFE,{"ALIQUOTA"	,"N",TamSX3("FT_ALIQICM")[1],TamSX3("FT_ALIQICM")[2]})
AADD(aArqNFE,{"VALISS"		,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
AADD(aArqNFE,{"VALCRED"		,"N",TamSX3("FT_CREDNFE")[1],TamSX3("FT_CREDNFE")[2]})
AADD(aArqNFE,{"CLIENTE"		,"C",TamSX3("A1_COD")[1],0})
AADD(aArqNFE,{"LOJA"		,"C",TamSX3("A1_LOJA")[1],0})
AADD(aArqNFE,{"IMPORT"		,"C",1,0})
AADD(aArqNFE,{"ERRO"		,"C",145,0})
AADD(aArqNFE,{"CODISS"		,"C",TamSX3("F3_CODISS")[1],0})
AADD(aArqNFE,{"SITUACAO"	,"C",1,0})
AADD(aArqNFE,{"QTD"			,"N",TamSX3("FT_QUANT")[1],0})
If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lItapevi .Or. lSantParn
	AADD(aArqNFE,{"VALCOFI"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
	AADD(aArqNFE,{"VALCSLL"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
	AADD(aArqNFE,{"VALPIS"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
	AADD(aArqNFE,{"VALINSS"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
	AADD(aArqNFE,{"VALIRRF"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
Endif
If lItapevi .Or. lBarueri .Or. lSantParn
	AADD(aArqNFE,{"ISSRET"	,"N",TamSX3("FT_VALICM")[1],TamSX3("FT_VALICM")[2]})
	AADD(aArqNFE,{"RPS7"	,"C",TamSX3("FT_NFISCAL")[1],0})
	AADD(aArqNFE,{"RPS8"	,"C",TamSX3("FT_NFISCAL")[1],0})
	AADD(aArqNFE,{"RPS9"	,"C",TamSX3("FT_NFISCAL")[1],0})
Endif
If lSAndre
	AADD(aArqNFE,{"AUTENT"	,"C",100,0})
	AADD(aArqNFE,{"URL"		,"C",100,0})
EndIf
If lEspSanto
	AADD(aArqNFE,{"CHVALID"	,"C",100,0})
	AADD(aArqNFE,{"OUTRET"	,"N",TamSX3("FT_VALCONT")[1],TamSX3("FT_VALCONT")[2]})
	AADD(aArqNFE,{"VALPAG"	,"N",TamSX3("FT_VALCONT")[1],TamSX3("FT_VALCONT")[2]})
EndIf
If lRecife
	AADD(aArqNFE,{"CODATIV"	,"C",TamSX3("F3_CNAE")[1],0})
EndIf

cArqNFE	:=	CriaTrab(aArqNFE)
dbUseArea(.T.,__LocalDriver,cArqNFE,"NFE")
IndRegua("NFE",cArqNFE,"RPS+SERIE")

aArqTmp := {{cArqNFE,"NFE"}}

Return(aArqTmp)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Mta915Le    �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Le arquivo de retorno da prefeitura e carrega o arquivo       ���
���          �temporario para atualizar as tabelas.                         ���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mta915Le(aArqTmp)

Local aWizard		:= {}

Local lRet			:= !xMagLeWiz("MTA915",@aWizard,.T.)

Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""
Local cLinha		:= ""
Local cLinhaUtf 	:= ""
Local cChar			:= ""

Local lCarga		:= .F.
Local lArqValido	:= .F.
Local lSerieSN		:= GetNewPar("MV_ESPNFX5",.F.)

Local nTamRPS		:= TamSX3("FT_NFISCAL")[1]
Local nTamNFE		:= TamSX3("FT_NFELETR")[1]
Local nTamSer		:= TamSX3("FT_SERIE")[1]
Local nTamISS		:= TamSX3("FT_CODISS")[1]
Local nTamAtv		:= TamSX3("F3_CNAE")[1]
Local nCont			:= 0
Local nContChr		:= 0
Local nPosSign		:= 0
Local nPosSA    	:= 0
Local cCampoSA  	:= ""
Local aDadosSA  	:= {}
Local aEspecie  	:= {}
Local nL	      	:= 0

Local cArqProc		:= Alltrim(aWizard[01][01])
Local cSerOsa		:= If(lOsasco,Padr(aWizard[01][03],nTamSer),"") // S�rie de emiss�o do RPS antes de tranmitor para prefeitura - Apenas para municipio de Osasco

Local cTiposDoc		:= iif(lSerieSN .And. findFunction("MaSerEspNF"), MaSerEspNF(), GetNewPar("MV_ESPECIE","") ) 
Local cArqXML		:= ""
Local nY			:= 0
Local nV			:= 0
Local cErro1		:= ""
Local cAviso		:= ""
Local cDrive		:= ""
Local cPath			:= ""
Local cNewFile		:= ""
Local cExt			:= ""
Local cStartPath	:= 	GetSrvProfString("StartPath","")
Local cCliente  	:= ""
Local cSerie    	:= ""
Local cLoja     	:= ""
Local lSdoc			:= If(TamSx3("F2_SERIE")[1] > 3,.T.,.F.)
Local cSerId		:= ""
Local aAux			:= {}

Private oNfse
Private cEspChave	:= If(lSdoc,Padr(aWizard[01][02],TamSx3("F2_ESPECIE")[1]),"")

//�������������������������������������������Ŀ
//�Cria o arquivo temporario para a importacao�
//���������������������������������������������
aArqTmp := Mta915TMP()

SFT->(dbSetOrder(1))
//��������������������������������������������������Ŀ
//�Verifica se o arquivo existe no diretorio indicado�
//����������������������������������������������������
If File(cArqProc) .And. !lRet

	SplitPath(cArqProc,@cDrive,@cPath, @cNewFile,@cExt)
	cNewFile := cNewFile+cExt

	If !Empty(cDrive)
		CpyT2S(cDrive+cPath+cNewFile,cStartPath,.F.)
	EndIf

	cArqProc := cStartPath+cNewFile

	nHandle	:=	FOpen(cArqProc)
	nTam	:=	FSeek(nHandle,0,FS_END)
	FSeek(nHandle,0,0)
	ProcRegua(nTam)

	FT_FUse(cArqProc)
	FT_FGotop()

	//����������������������������Ŀ
	//�Verifica se � um arquivo XML�
	//������������������������������

	cLinha := FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
	If At("<?xml",cLinha)>0
		lCarga 	:= .F.

		If lJoinville
			FT_FGotop()
			cLinha :=""
			While ( !FT_FEof() )
				
				cLinha += FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
				//Processo Nota a Nota
				While "/nota>" $ cLinha
					nY := At("<nota>",cLinha)//Posi��o inicial da tag nota
					nV := At("</nota>",cLinha)+7 //Posi��o final da tag nota

					cArqXML := SubStr(cLinha,nY,nV-nY)//Conteudo da Tag nota

					oNfse := XmlParser(cArqXML,"_",@cErro1,@cAviso)//carrego no objeto o conteudo da tag Nota

					//������������������������������������������������������������������Ŀ
					//�Verifica se o arquivo aberto e um arquivo de retorno da prefeitura�
					//��������������������������������������������������������������������

					//Valido se a estrutura do XML � a de Joinville
					If Type("oNfse:_Nota")<>"U" .And. Type("oNfse:_Nota:_Numero_RPS")<>"U"
						If oNfse:_NOTA:_NUMERO_RPS:TEXT<>""
							RecLock("NFE",.T.)
							NFE->NFE		:= oNfse:_NOTA:_NUMERO:TEXT
							NFE->EMISSAO	:= StoD(SubStr(oNfse:_NOTA:_DATA_EMISSAO:TEXT,1,4)+SubStr(oNfse:_NOTA:_DATA_EMISSAO:TEXT,6,2)+SubStr(oNfse:_NOTA:_DATA_EMISSAO:TEXT,9,2))
							NFE->VERIFICA	:= oNfse:_NOTA:_CODIGO_VERIFICACAO:TEXT
							NFE->RPS		:= oNfse:_NOTA:_NUMERO_RPS:TEXT

							If lSdoc
								NFE->SERIE		:= oNfse:_NOTA:_SERIE_RPS:TEXT + SubStr(oNfse:_NOTA:_DATA_EMISSAO:TEXT,6,2) + SubStr(oNfse:_NOTA:_DATA_EMISSAO:TEXT,1,4)+cEspChave
							Else
								NFE->SERIE		:= oNfse:_NOTA:_SERIE_RPS:TEXT
							EndIf

							NFE->VALSERV	:= Val(oNfse:_NOTA:_VALOR_TOTAL:TEXT)
							NFE->ALIQUOTA	:= Val(oNfse:_NOTA:_ALIQUOTA_ISS:TEXT)/100
							NFE->VALISS		:= Val(oNfse:_NOTA:_VALOR_ISS:TEXT)
							NFE->CODISS		:= Right(oNfse:_NOTA:_SERVICO:TEXT,nTamISS)
							NFE->SITUACAO	:= Iif(oNfse:_NOTA:_CANCELADA:TEXT=="1","C","")

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If NFE->SITUACAO <> "C"
								SF2->(dbSetOrder(1))
								//Caso em que o campo tem 9 ou mais posi��es por�m apenas 6 posi��es s�o preenchidas
								If SF2->(dbSeek(xFilial("SF2")+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								//Caso em que o campo tem 9 ou mais posi��es e as 9 ou mais posi��es s�o preenchidas
								ElseIf SF2->(dbSeek(xFilial("SF2")+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								ElseIf SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								Endif
							Else
								//�������������������������������������������������������������������������Ŀ
								//�Quando a nota fiscal eh cancelada, a busca pelo cliente sera feita       �
								//�pelo SFT, visto que no SF3 nao ha como identificar sem o CFOP e aliquota.�
								//���������������������������������������������������������������������������

								//Caso em que o campo tem 9 posi��es por�m apenas 6 posi��es s�o preenchidas
								If SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6))) 
									NFE->CLIENTE	:= SFT->FT_CLIEFOR
									NFE->LOJA		:= SFT->FT_LOJA
								//Caso em que o campo tem 9 posi��es e as 9 posi��es s�o preenchidas
								ElseIf SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)))
									NFE->CLIENTE	:= SFT->FT_CLIEFOR
									NFE->LOJA		:= SFT->FT_LOJA
								ElseIf SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS))
									NFE->CLIENTE	:= SFT->FT_CLIEFOR
									NFE->LOJA		:= SFT->FT_LOJA
								Endif
							Endif
							MsUnLock()
							lCarga := .T.
						EndIf
					EndIf
					//Pego o conteudo de cLinha da posi��o da tag final dessa Nota para frente
					cLinha :=  SubStr(cLinha,nV)

				EndDo
				FT_FSkip()
			EndDo
			FT_FUse()
		EndIf

	Else

		//������������������������������������������������������������������Ŀ
		//�Verifica se o arquivo aberto e um arquivo de retorno da prefeitura�
		//��������������������������������������������������������������������
		FT_FGotop()
		lArqValido:= .F.
		cChar     := "."
		nCont     := 0
		nContChr  := 0

		While (!FT_FEof())
			If !lSAndre
				FT_FSkip()
			EndIf
			cLinha := ""
			If lResende	.Or. lManaus .Or. lRecife .Or. lMacae .Or. lBMansa
				While cChar<>Chr(10)
					cChar := FReadStr(nHandle,1)
					If cChar <> Chr(10) .And. nCont < 45
						nCont++
						cLinha += cChar
					Else
						FT_FSkip()
						cChar := "."
						nCont := 0
						Exit
					EndIf
				EndDo
			ElseIf lRio
				While cChar<>Chr(10)
					cChar := FReadStr(nHandle,1)
					If cChar <> Chr(10)  .And. cChar <> ""
						cLinha += cChar
						If cChar == ";"
							nCont++
						EndIf
						If cChar == Chr(09)
							nContChr++
						EndIf
					Else
						If Len(cLinha)>1023
							FT_FSkip()
						EndIf
						cChar := "."
						Exit
					Endif
				EndDo
			Else
				cLinha := FReadLine()//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
			Endif
			If lResende .Or. lManaus  .Or. lRecife .Or. lBMansa
				If lRecife .And. (SubStr(cLinha,1,1)=="2" .And. (Alltrim(SubStr(cLinha,42,1))=="0" .Or. Alltrim(SubStr(cLinha,42,1))=="1")) .Or. (SubStr(cLinha,1,1)=="3" .And. Alltrim(SubStr(cLinha,42,1))=="2")
					lArqValido := .T.
					Exit
				ElseIf (SubStr(cLinha,1,1) == "2" .And. (Alltrim(SubStr(cLinha,39,1)) == "0" .Or. Alltrim(SubStr(cLinha,39,1)) == "1")) .Or. (SubStr(cLinha,1,1) == "3" .And. Alltrim(SubStr(cLinha,39,1)) == "2")
					lArqValido := .T.
					Exit
				Endif
			ElseIf lSAndre
				If At("|",cLinha)>0
					lArqValido := .T.
					Exit
				EndIf
			ElseIf lEspSanto
				If At("|",cLinha)>0 .And. Alltrim(SubStr(cLinha,1,2)) =="T2"
					lArqValido := .T.
					Exit
				EndIf
			ElseIf lMacae
				If SubStr(cLinha,1,1) == "2" .And. Alltrim(SubStr(cLinha,39,1)) $ "012"
					lArqValido := .T.
					Exit
				EndIf
			ElseIf lItapevi .Or. lBarueri .Or. lVRedonda .Or. lOsasco
				lArqValido := .T.
			ElseIf lRio
				If At("|",cLinha)>0 .Or. SubStr(cLinha,1,2) == "20"
					lArqValido := .T.
					Exit
				EndIf
			ElseIf lSaopaulo
				If (SubStr(cLinha,1,1) == "2" .And. (Alltrim(SubStr(cLinha,32,5)) == "RPS" .Or. Alltrim(SubStr(cLinha,32,5)) == "RPS-M" .Or. Alltrim(SubStr(cLinha,32,5)) == "RPS-C"))
					lArqValido := .T.
				Endif
				Exit
			ElseIf lSantParn
				If SubStr(cLinha,9,3) $ "Ref"
					lArqValido := .T.
				Endif
				Exit
			Else
				If (SubStr(cLinha,1,1) == "2" .And. (Alltrim(SubStr(cLinha,40,5)) == "RPS" .Or. Alltrim(SubStr(cLinha,40,5)) == "RPS-M")) .Or. (SubStr(cLinha,1,1) == "3" .And. Alltrim(SubStr(cLinha,40,5)) == "RPS-C")
					lArqValido := .T.
				Endif
				Exit
			Endif
		EndDo

		If lArqValido
			FT_FGotop()
			FSeek(nHandle,0,0)
			cChar  := "."
			cLinha := ""

			While (!FT_FEof())
				IncProc()

				If Substr(cLinha,1,2) == "90" .And. lBMansa
					Exit
				EndIf

				cLinha := ""
				aDadosSA := {}

				If lResende	.Or. lManaus .Or. lMacae .Or. lBMansa
					While cChar<>Chr(10)
						cChar := FReadStr(nHandle,1)
						If cChar <> Chr(10)
							cLinha += cChar
						Else
							FT_FSkip()
							cChar := "."
							Exit
						EndIf
					EndDo
				Elseif lVRedonda
					If FReadStr(nHandle,1) == "R"
						FT_FSkip()
						cLinha := FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
					Endif
				Elseif lRio
					While cChar<>Chr(10)
						cChar := FReadStr(nHandle,1)
						If cChar <> Chr(10)
							cLinha += cChar
							If cChar == Chr(09)
								nContChr++
							EndIf
							If cChar = ";"
								nCont++
							EndIf
						Else
							If Len(cLinha)>1023
								FT_FSkip()
							EndIf
							cChar := "."
							Exit
						EndIf
					EndDo
				Elseif lSantParn
					cLinha := FReadLine()
					If SubStr(cLinha,1,4) $ "NF-e"
						FT_FSkip()
						cLinha := FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
					Endif
				Else
					cLinha := FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres

					//��������������������������������������������������������Ŀ
					//| Tratamento para o tamanho do RPS apenas para Sao Paulo |
					//����������������������������������������������������������
					If Substr(cLinha,1,1) $ "23" .And. !lResende .And. !lManaus .And. !lSAndre .And. !lEspSanto .And. !lRecife .And. !lMacae .And. !lJoinville .And. !lBarueri .And. !lVRedonda .And. !lRio
						//����������������������������������������������������Ŀ
						//�O controle do tamanho do RPS deve ser feito mesmo   �
						//�     apos o cliente ter executado o Ajuste SINIEF   |
						//�     pois e' possivel utilizar NF's com tamanho 6   |
						//������������������������������������������������������
						If nTamRPS == TamSX3("FT_NFISCAL")[1]
							SX5->(dbSetOrder(1))
							If SX5->(dbSeek(xFilial("SX5")+"01"+Alltrim(SubStr(cLinha,37,5))))
								nTamRPS	:= Len(Alltrim(X5Descri()))
							EndIf
						EndIf
					EndIf

				Endif

				If Len(Alltrim(cLinha))>0
					If lSAndre
						nPosSign:=At("=",cTiposDoc)
						While nPosSign <= Len(cTiposDoc) .And. nPosSign<>0
							If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)=="RPS"
								cEspecie := Substr(cTiposDoc,At("=",cTiposDoc)+1,3)
								AAdd(aEspecie,cEspecie)
							EndIf
							cTiposDoc := Substr(cTiposDoc,nPosSign+1,Len(cTiposDoc))
							nPosSign:=At("=",cTiposDoc)
						Enddo
						If At("|",cLinha)>0
							While nPosSA < Len(cLinha)
								If At("|",cLinha)==0 .And. nPosSA>0
									cCampoSA:=cLinha
									AAdd(aDadosSA,cCampoSA)
									Exit
								Endif
								nPosSA := At("|",cLinha)
								cCampoSA := Substr(cLinha,1,nPosSA)
								cCampoSA := Substr(cCampoSA,1,Len(cCampoSA)-1)
								AAdd(aDadosSA,cCampoSA)
								cLinha := Substr(cLinha,nPosSA+1,Len(cLinha)) 
							Enddo
						EndIf
					EndIf
					If lEspSanto
						While nPosSign <= Len(cTiposDoc)
							nPosSign:=At("=",cTiposDoc) 
							If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)=="RPS"
								cEspecie := Substr(cTiposDoc,1,At("=",cTiposDoc)-1)
								AAdd(aEspecie,cEspecie)
							EndIf
							cTiposDoc := Substr(cTiposDoc,nPosSign+5,Len(cTiposDoc))
						Enddo
						If At("|",cLinha)>0
							While nPosSA < Len(cLinha)
								If At("|",cLinha)==0 .And. nPosSA>0
									cCampoSA:=cLinha
									AAdd(aDadosSA,cCampoSA)
									Exit
								Endif
								nPosSA := At("|",cLinha)
								cCampoSA := Substr(cLinha,1,nPosSA)
								cCampoSA := Substr(cCampoSA,1,Len(cCampoSA)-1)
								AAdd(aDadosSA,cCampoSA)
								cLinha := Substr(cLinha,nPosSA+1,Len(cLinha))
								nPosSA:=1
							Enddo
						EndIf
					EndIf
					If lItapevi .Or. lBarueri .Or. lVRedonda
						While nPosSign <= Len(cTiposDoc)
							nPosSign:=At("=",cTiposDoc)+1
							If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)=="RPS"
								cEspecie := Substr(cTiposDoc,1,At("=",cTiposDoc)-1)
								AAdd(aEspecie,cEspecie)
							EndIf
							If Len(cTiposDoc)< 9 .And. At(";",cTiposDoc)==0
								cTiposDoc:=cTiposDoc+";"
							EndIf
							cTiposDoc := Substr(cTiposDoc,At(";",cTiposDoc)+1,Len(cTiposDoc))
						Enddo
						If At("NF-e",cLinha)>0 .Or. At("PMB",cLinha)>0
							FT_FSkip()
							cLinha := FReadLine()	//FT_FREADLN() -> funcao substituida para ler mais de 1023 caracteres
						EndIf
					EndIf
					If lOsasco
						While nPosSign <= Len(cTiposDoc)
							nPosSign:=At("=",cTiposDoc)+1
							If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)=="RPS"
								cEspecie := Substr(cTiposDoc,1,At("=",cTiposDoc)-1)
								AAdd(aEspecie,cEspecie)
							EndIf
							If Len(cTiposDoc)< 9 .And. At(";",cTiposDoc)==0
								cTiposDoc:=cTiposDoc+";"
							EndIf
							cTiposDoc := Substr(cTiposDoc,At(";",cTiposDoc)+1,Len(cTiposDoc))
						Enddo
						aLinha := Separa(cLinha,";",.T.)
					EndIf
					If lRio
						While nPosSign <= Len(cTiposDoc)
							nPosSign:=At("=",cTiposDoc)+1
							If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)=="RPS"
								cEspecie := Substr(cTiposDoc,1,At("=",cTiposDoc)-1)
								AAdd(aEspecie,cEspecie)
							EndIf
							If Len(cTiposDoc)< 9 .And. At(";",cTiposDoc)==0
								cTiposDoc:=cTiposDoc+";"
							EndIf
							cTiposDoc := Substr(cTiposDoc,At(";",cTiposDoc)+1,Len(cTiposDoc))
						Enddo
						If 	nContChr > 0
							aLinha := Separa(cLinha,Chr(9),.T.)
						ElseIf nCont > 0
							aLinha := Separa(cLinha,";",.T.)
						EndIf
					EndIf

					//�����������������������������������������������������Ŀ
					//�Apenas utiliza os registro 2 (RPS) e 3 (cupom fiscal)�
					//�������������������������������������������������������
					If SubStr(cLinha,1,1) $ "23" .And. !lSAndre .And. !lEspSanto .And. !lItapevi .And. !lBarueri .And. !lVRedonda .And. !lRio .And. !lOsasco

						RecLock("NFE",.T.)
						If lResende .Or. lManaus .Or. lMacae .Or. lBMansa
							NFE->NFE		:= Right(SubStr(cLinha,2,15),nTamNFE)
							NFE->EMISSAO	:= sTod(SubStr(cLinha,17,8)) 
							NFE->HORA		:= SubStr(cLinha,25,6)
							NFE->VERIFICA	:= SubStr(cLinha,31,8)
							NFE->RPS		:= Right(SubStr(cLinha,45,15),nTamRPS)

							If lSdoc
								NFE->SERIE		:= Left(SubStr(cLinha,40,3),nTamSer) + SubStr(SubStr(cLinha,17,8),5,2) + SubStr(SubStr(cLinha,17,8),1,4)+cEspChave
							Else
								NFE->SERIE		:= Left(SubStr(cLinha,40,5),nTamSer)
							EndIF

							NFE->VALSERV	:= Val(SubStr(cLinha,631,15)) / 100
							NFE->ALIQUOTA	:= Val(SubStr(cLinha,669,5)) / 100
							NFE->VALISS		:= Val(SubStr(cLinha,674,15)) / 100
							NFE->VALCRED	:= Val(SubStr(cLinha,689,15)) / 100
							NFE->CODISS		:= Right(SubStr(cLinha,661,8),nTamISS)
							NFE->SITUACAO	:= SubStr(cLinha,599,1)
							NFE->VALCOFI	:= Val(SubStr(cLinha,1250,15)) / 100
							NFE->VALCSLL	:= Val(SubStr(cLinha,1265,15)) / 100
							NFE->VALPIS		:= Val(SubStr(cLinha,1310,15)) / 100
							NFE->VALINSS	:= Val(SubStr(cLinha,1280,15)) / 100
							NFE->VALIRRF	:= Val(SubStr(cLinha,1295,15)) / 100

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If NFE->SITUACAO <> "C"
								If lTamCpo
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									EndIf
								Else
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									Endif
								EndIf
							Else
								//�������������������������������������������������������������������������Ŀ
								//�Quando a nota fiscal eh cancelada, a busca pelo cliente sera feita       �
								//�pelo SFT, visto que no SF3 nao ha como identificar sem o CFOP e aliquota.�
								//���������������������������������������������������������������������������
								If lTamCpo
									If SFT->(dbSeek(xFilial("SFT")+"S"+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									EndIf
								Else
									If SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									Endif
								EndIf
							Endif
						ElseIf lRecife
							If lTamCpo
								nTamRPS := 6
								nTamNFE := 6
							EndIf

							NFE->NFE		:= Right(SubStr(cLinha,3,15),nTamNFE)
							NFE->SITUACAO	:= SubStr(cLinha,18,1)
							NFE->VERIFICA	:= SubStr(cLinha,19,8)
							NFE->EMISSAO	:= sTod(SubStr(cLinha,28,8))
							NFE->HORA		:= SubStr(cLinha,36,6)

							If lSdoc
								NFE->SERIE		:= Left(SubStr(cLinha,43,3),nTamSer) + SubStr(SubStr(cLinha,28,8),5,2) + SubStr(SubStr(cLinha,28,8),1,4)+cEspChave
							Else
								NFE->SERIE		:= Left(SubStr(cLinha,43,5),nTamSer)
							EndIF

							NFE->SERIE		:= Left(SubStr(cLinha,43,5),nTamSer)
							NFE->RPS		:= Right(SubStr(cLinha,48,15),nTamRPS)
							NFE->CODATIV	:= Right(SubStr(cLinha,1355,20),nTamAtv)
							NFE->ALIQUOTA	:= Val(SubStr(cLinha,1375,5)) / 100
							NFE->VALSERV	:= Val(SubStr(cLinha,1380,15)) / 100
							NFE->VALISS		:= Val(SubStr(cLinha,1530,15)) / 100
							NFE->VALCRED	:= Val(SubStr(cLinha,1545,15)) / 100

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If NFE->SITUACAO <> "C"
								If lTamCpo
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									EndIf
								Else
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									EndIf
								Endif
							Else
								//�������������������������������������������������������������������������Ŀ
								//�Quando a nota fiscal eh cancelada, a busca pelo cliente sera feita       �
								//�pelo SFT, visto que no SF3 nao ha como identificar sem o CFOP e aliquota.�
								//���������������������������������������������������������������������������
								If lTamCpo
									If SFT->(dbSeek(xFilial("SFT")+"S"+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									EndIf
								Else
									If SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									Endif
								EndIf
							Endif
						ElseIF lSaopaulo
							NFE->NFE		:= SubStr(cLinha,2,8)
							NFE->EMISSAO	:= sTod(SubStr(cLinha,10,8))
							NFE->HORA		:= SubStr(cLinha,18,6)
							NFE->VERIFICA	:= SubStr(cLinha,24,8)
							NFE->RPS		:= Right(SubStr(cLinha,42,12),nTamRPS)
							If lSdoc
								NFE->SERIE		:= Left(SubStr(cLinha,37,3),nTamSer) + SubStr(SubStr(cLinha,10,8),5,2) + SubStr(SubStr(cLinha,10,8),1,4)+cEspChave
							Else
								NFE->SERIE		:= Left(SubStr(cLinha,37,5),nTamSer)
							EndIF
							NFE->VALSERV	:= Val(SubStr(cLinha,448,15)) / 100
							NFE->ALIQUOTA	:= Val(SubStr(cLinha,483,4)) / 100
							NFE->VALISS		:= Val(SubStr(cLinha,487,15)) / 100
							NFE->VALCRED	:= Val(SubStr(cLinha,502,15)) / 100
							NFE->CODISS		:= Right(SubStr(cLinha,478,5),nTamISS)
							NFE->SITUACAO	:= SubStr(cLinha,419,1)

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If NFE->SITUACAO <> "C"
								If lTamCpo
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									EndIf
								Else
									SF2->(dbSetOrder(1))
									If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
									EndIf
								Endif
							Else
							//�������������������������������������������������������������������������Ŀ
							//�Quando a nota fiscal eh cancelada, a busca pelo cliente sera feita       �
							//�pelo SFT, visto que no SF3 nao ha como identificar sem o CFOP e aliquota.�
							//���������������������������������������������������������������������������
								If lTamCpo
									If SFT->(dbSeek(xFilial("SFT")+"S"+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									EndIf
								Else
									If SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS))
										NFE->CLIENTE	:= SFT->FT_CLIEFOR
										NFE->LOJA		:= SFT->FT_LOJA
									Endif
								EndIf
							Endif
						Else
							NFE->NFE		:= SubStr(cLinha,10,8)
							NFE->EMISSAO	:= sTod(SubStr(cLinha,18,8))
							NFE->HORA		:= SubStr(cLinha,26,6)
							NFE->VERIFICA	:= SubStr(cLinha,32,8)
							NFE->RPS		:= Right(SubStr(cLinha,50,12),nTamRPS)
							If lSdoc
								NFE->SERIE		:= Left(SubStr(cLinha,45,3),nTamSer) + SubStr(SubStr(cLinha,18,8),5,2) + SubStr(SubStr(cLinha,18,8),1,4)+cEspChave
							Else
								NFE->SERIE		:= Left(SubStr(cLinha,45,5),nTamSer)
							EndIF
							NFE->VALSERV	:= Val(SubStr(cLinha,79,15)) / 100
							NFE->ALIQUOTA	:= Val(SubStr(cLinha,114,4)) / 100
							NFE->VALISS		:= Val(SubStr(cLinha,118,15)) / 100
							NFE->VALCRED	:= Val(SubStr(cLinha,133,15)) / 100
							NFE->CODISS		:= Right(SubStr(cLinha,109,5),nTamISS)
							NFE->SITUACAO	:= SubStr(cLinha,78,1)

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If lTamCpo
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								EndIf
							Else
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								EndIf
							Endif
						Endif
						MsUnLock()
						lCarga := .T.
					Else
						If lItapevi
							RecLock("NFE",.T.)
							NFE->NFE		:= Right(SubStr(cLinha,1,8),nTamNFE)
							NFE->RPS		:= Right(SubStr(cLinha,13,6),nTamRPS)
							NFE->RPS7		:= Right(SubStr(cLinha,13,7),nTamRPS)
							NFE->RPS8		:= Right(SubStr(cLinha,13,8),nTamRPS)
							NFE->RPS9		:= Right(SubStr(cLinha,13,9),nTamRPS)
							NFE->EMISSAO	:= sTod(SubStr(cLinha,25,10))
							NFE->CODISS		:= Right(SubStr(cLinha,49,8),nTamISS)
							NFE->ALIQUOTA	:= Val(SubStr(cLinha,57,5)) / 100
							NFE->VALSERV	:= Val(SubStr(cLinha,62,18)) / 100
							NFE->VALISS     := Val(SubStr(cLinha,98,18)) / 100
							NFE->ISSRET     := Val(SubStr(cLinha,116,18)) / 100
							NFE->VALIRRF	:= Val(SubStr(cLinha,134,18)) / 100
							NFE->VALPIS		:= Val(SubStr(cLinha,152,18)) / 100
							NFE->VALCOFI	:= Val(SubStr(cLinha,170,18)) / 100
							NFE->VALCSLL	:= Val(SubStr(cLinha,188,18)) / 100
							NFE->VALINSS	:= Val(SubStr(cLinha,206,18)) / 100

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							SF2->(dbSetOrder(1))
							If len(aEspecie)>0
								For nL:=1 to len(aEspecie)

									If lSdoc
										cSerId := SubStr(aEspecie[nL],1,3) + SubStr(SubStr(cLinha,25,10),6,2) + SubStr(SubStr(cLinha,25,10),1,4)+cEspChave
									Else
										cSerId := SubStr(aEspecie[nL],1,3)
									EndIf

									If lTamCpo
										If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerId))
											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA 		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										EndIf
									Else 
										If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerId)) .Or.;
											SF2->(dbSeek(xFilial("SF2")+NFE->RPS7+cSerId)) .Or.;
											SF2->(dbSeek(xFilial("SF2")+NFE->RPS8+cSerId)) .Or.;
											SF2->(dbSeek(xFilial("SF2")+NFE->RPS9+cSerId))

											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										Endif
									EndIf
								Next
							EndIf
							MsUnLock()
							lCarga := .T.
						EndIf

						If lVRedonda
							RecLock("NFE",.T.)
							NFE->RPS		:= Right(SubStr(cLinha,16,9),nTamRPS)
							NFE->NFE     	:= Right(SubStr(cLinha,17,9),nTamRPS)

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							SF2->(dbSetOrder(1))
							If len(aEspecie)>0
								For nL:=1 to len(aEspecie)

									If lSdoc
										cSerId := SubStr(aEspecie[nL],1,3) + SubStr(SubStr(cLinha,25,10),6,2) + SubStr(SubStr(cLinha,25,10),1,4)+cEspChave
									Else
										cSerId := SubStr(aEspecie[nL],1,3)
									EndIf

									If lTamCpo
										If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerId))
											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA 		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										EndIf
									Else
										If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerId))
											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										Endif
									EndIf
								Next
							EndIf
							MsUnLock()
							lCarga := .T.
						EndIf

						If lSAndre .And. len(aDadosSA)>0
							RecLock("NFE",.T.)
							NFE->NFE		:= aDadosSA[2]
							NFE->RPS		:= StrZero(Val(aDadosSA[1]),TamSX3("F3_NFISCAL")[1])
							NFE->AUTENT		:= aDadosSA[3]
							NFE->URL		:= aDadosSA[4]

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							SF2->(dbSetOrder(1))
							If len(aEspecie)>0
								For nL:=1 to len(aEspecie)

									If lSdoc
										cSerId := SubStr(aEspecie[nL],1,3) + SubStr(SubStr(cLinha,25,10),6,2) + SubStr(SubStr(cLinha,25,10),1,4)+cEspChave
									Else
										cSerId := SubStr(aEspecie[nL],1,3)
									EndIf

									If lTamCpo
										If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerId))
											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										Endif
									Else
										If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerId))
											NFE->CLIENTE	:= SF2->F2_CLIENTE
											NFE->LOJA		:= SF2->F2_LOJA
											NFE->SERIE		:= cSerId
										Endif
									EndIf
								Next
							EndIf
							MsUnLock()
							lCarga := .T.
						EndIf
					Endif
				If lBarueri
					cLinhaUtf := DecodeUtf8(cLinha)
					If Valtype(cLinhaUtf) == "U"
						cLinhaUtf := cLinha
					EndIf
					If SubStr(cLinha,1,1) $ "2"

						//����������������������������������������������������Ŀ
						//�O controle do tamanho do RPS deve ser feito mesmo   �
						//�     apos o cliente ter executado o Ajuste SINIEF   |
						//�     pois e' possivel utilizar NF's com tamanho 6   |
						//������������������������������������������������������
						If nTamRPS == TamSX3("FT_NFISCAL")[1]
							SX5->(dbSetOrder(1))
							If SX5->(dbSeek(xFilial("SX5")+"01"+Alltrim(SubStr(cLinhaUtf,51,4))))
								nTamRPS	:= Len(Alltrim(X5Descri()))
							EndIf
						EndIf

						RecLock("NFE",.T.)
						NFE->NFE		:= Right(SubStr(cLinhaUtf,7,6),nTamNFE)
						NFE->RPS		:= Right(SubStr(cLinhaUtf,55,10),nTamRPS)
						NFE->EMISSAO	:= sTod(SubStr(cLinhaUtf,13,8))
						NFE->HORA		:= SubStr(cLinhaUtf,21,6)
						NFE->VERIFICA	:= SubStr(cLinhaUtf,27,24)
						//����������������������������������������������������Ŀ
						//�Buscando o cliente para qual foi emitido o documento�
						//������������������������������������������������������
						findClient(lSdoc,cLinhaUtf,cEspChave,aEspecie,aAux)
						MsUnLock()
						lCarga := .T.

					ElseIf SubStr(cLinhaUtf,1,1) $ "3"
						RecLock("NFE",.F.)
						NFE->QTD    := Val(SubStr(cLinhaUtf,2,6))
						NFE->VALISS := (NFE->QTD * (Val(SubStr(cLinhaUtf,77,13)+"."+SubStr(cLinhaUtf,90,2))))
						MsUnLock()
						lCarga := .T.
					EndIf

				EndIf
				If lEspSanto .And. len(aDadosSA)>0  .And. AllTrim(aDadosSA[1])=="T2"
					RecLock("NFE",.T.)

						NFE->NFE		:= aDadosSA[2]
						NFE->EMISSAO	:= sTod(aDadosSA[3])
						NFE->RPS		:= StrZero(Val(aDadosSA[23]),Len(NFE->RPS))
						NFE->CHVALID    := aDadosSA[22]
						NFE->VALSERV	:= Val(StrTran(aDadosSA[14],",","."))
						NFE->VALISS		:= Val(StrTran(aDadosSA[15],",","."))
						NFE->OUTRET     := Val(StrTran(aDadosSA[16],",","."))
						NFE->VALPAG     := Val(StrTran(aDadosSA[17],",","."))
						If !Empty(AllTrim(aDadosSA[4]))
						 NFE->SITUACAO	:="C"
						EndIf

						//����������������������������������������������������Ŀ
						//�Buscando o cliente para qual foi emitido o documento�
						//������������������������������������������������������
						SF2->(dbSetOrder(1))
						If len(aEspecie)>0
							For nL:=1 to len(aEspecie)

								If lSdoc
									cSerId := SubStr(aEspecie[nL],1,3) + StrZero(Month(sTod(aDadosSA[3])),2)+Str(Year(sTod(aDadosSA[3])),4) +cEspChave
								Else
									cSerId := SubStr(aEspecie[nL],1,3)
								EndIf

								If lTamCpo
									If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerId))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
										NFE->SERIE		:= cSerId
									Endif
								Else
									If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerId))
										NFE->CLIENTE	:= SF2->F2_CLIENTE
										NFE->LOJA		:= SF2->F2_LOJA
										NFE->SERIE		:= cSerId
									EndIf
								EndIf
							Next
						EndIf

						MsUnLock()
						lCarga := .T.
					Endif
					If lOsasco .And. aLinha[1]=="D"
						RecLock("NFE",.T.)
						NFE->NFE		:= aLinha[2]
						NFE->EMISSAO	:= cTod( Substr(aLinha[3],1,10))
						NFE->HORA       := AllTrim(Substr(aLinha[3],11))
						NFE->VERIFICA   := aLinha[4]
						NFE->RPS		:= StrZero(Val(aLinha[6]),Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1]))
						NFE->SITUACAO   := aLinha[22]
						NFE->VALSERV	:= Val(aLinha[26])/100 
						NFE->VALISS		:= Val(aLinha[30])/100
						NFE->CODISS		:= AllTrim(Separa(aLinha[28],".")[1])+"."+AllTrim(Separa(aLinha[28],".")[2])
						NFE->ALIQUOTA	:= Val(aLinha[29]) / 100

						//����������������������������������������������������Ŀ
						// processo para situa��es onde a s�rie � diferente do �
						// arquivo de retorno, sempre �     utilizado a serie  �
						// do  MV_ESPECIE.                                     �
						//������������������������������������������������������
						If len(aEspecie)>0
							For nL:=1 to len(aEspecie)
								If lSdoc
									NFE->SERIE := SubStr(aEspecie[nL],1,3) + StrZero(Month(cTod( Substr(aLinha[3],1,10))),2)+Str(Year(cTod( Substr(aLinha[3],1,10))),4)+cEspChave
								Else
									NFE->SERIE := SubStr(aEspecie[nL],1,3)
								EndIf
							Next
						EndIf

						//����������������������������������������������������Ŀ
						//�Buscando o cliente para qual foi emitido o documento�
						//������������������������������������������������������
						If lTamCpo
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+StrZero(Val(aLinha[6]),6)+Space(3)+cSerOsa))
								NFE->CLIENTE	:= SF2->F2_CLIENTE
								NFE->LOJA		:= SF2->F2_LOJA
							EndIf
						Else
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerOsa))
								NFE->CLIENTE	:= SF2->F2_CLIENTE
								NFE->LOJA		:= SF2->F2_LOJA
							Endif
						EndIf

						MsUnLock()
						lCarga := .T.
					Endif

					If lRio .And. SubStr(cLinha,1,2)== "20"
						//����������������������������������������������������Ŀ
						//�Importando dados do arquivo SYSTEM\temp             �
						//�Layout de gera��o/recebimento vers�o 3.1            �
						//�Contempla vers�o tabulada(Chr(09)/Chr(3B)(tab ou ;))�
						//�ou apenas o arquivo texto sem tabula��o             �
						//������������������������������������������������������
						If (nContChr>0 .Or. nCont>0)     //para uso de arquivo tabulado Chr(09)/Chr(3B)(tab ou ;)

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If len(aEspecie)>0
								For nL:=1 to len(aEspecie)

									If lSdoc
										cSerId := SubStr(aEspecie[nL],1,3) + StrZero(Month(cTod(Substr(aLinha[5],1,10))),2)+Str(Year(cTod(Substr(aLinha[5],1,10))),4)+cEspChave
									Else
										cSerId := SubStr(aEspecie[nL],1,3)
									EndIf

									If lTamCpo
										SF2->(dbSetOrder(1))
										If SF2->(dbSeek(xFilial("SF2")+Right(Substr(StrZero(Val(aLinha[8]),Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1])),1,6),6)+"   "+cSerId))
											cCliente	:= SF2->F2_CLIENTE
											cLoja		:= SF2->F2_LOJA
											cSerie		:= cSerId
										EndIf
									Else
										SF2->(dbSetOrder(1))
										If SF2->(dbSeek(xFilial("SF2")+StrZero(Val(aLinha[8]),Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1]))+cSerId))
											cCliente	:= SF2->F2_CLIENTE
											cLoja		:= SF2->F2_LOJA
											cSerie		:= cSerId
										Endif
									EndIf
								Next
							EndIf

							RecLock("NFE",.T.)
							NFE->NFE		:= aLinha[2]
							NFE->EMISSAO	:= cTod(Substr(aLinha[5],1,10))
							NFE->HORA       := AllTrim(Substr(aLinha[5],11))
							NFE->VERIFICA   := aLinha[4]
							NFE->RPS		:= StrZero(Val(aLinha[8]),Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1]))
							NFE->SITUACAO   := aLinha[3]
							NFE->VALSERV	:= Val(StrTran(StrTran(aLinha[51],".",""),",","."))
							NFE->VALISS		:= Val(StrTran(StrTran(aLinha[61],".",""),",","."))
							NFE->CODISS		:= Alltrim(Substr(aLinha[49],1,TamSX3("B1_CODISS")[1]))
							NFE->ALIQUOTA	:= Val(aLinha[50])
							NFE->CLIENTE	:= cCliente
							NFE->LOJA		:= cLoja
							NFE->SERIE		:= cSerie
							MsUnLock()
							lCarga := .T.

						Else // arquivo texto sem tabula��o
							RecLock("NFE",.T.)
							NFE->NFE		:= Right(SubStr(cLinha,3,15),9)
							NFE->RPS		:= StrZero(val(Right(SubStr(cLinha,48,15),nTamRPS)),Iif(lTamCpo,6,TamSX3("FT_NFISCAL")[1]))
							NFE->EMISSAO	:= sTod(SubStr(cLinha,25,10)) 
							NFE->HORA       := AllTrim(Substr(cLinha,35,6))
							NFE->VERIFICA   := Substr(cLinha,19,9)

							If lSdoc
								NFE->SERIE := SubStr(Substr(cLinha,43,5),1,3) + StrZero(Month(sTod(SubStr(cLinha,25,10))),2)+Str(Year(sTod(SubStr(cLinha,25,10))),4)+ cEspChave
							Else
								NFE->SERIE := SubStr(Substr(cLinha,43,5),1,3)
							EndIf

							NFE->SITUACAO   := Substr(cLinha,18,1)
							NFE->VALSERV	:= Val(SubStr(cLinha,1380,15)) / 100
							NFE->VALISS     := Val(SubStr(cLinha,1530,15)) / 100
							NFE->CODISS		:= Right(SubStr(cLinha,1355,20),6)
							NFE->ALIQUOTA	:= val(SubStr(cLinha,1375,5))/100

							//����������������������������������������������������Ŀ
							//�Buscando o cliente para qual foi emitido o documento�
							//������������������������������������������������������
							If lTamCpo
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								EndIf
							Else
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+NFE->RPS + NFE->SERIE))
									NFE->CLIENTE	:= SF2->F2_CLIENTE
									NFE->LOJA		:= SF2->F2_LOJA
								EndIf
								Endif

							MsUnLock()
							lCarga := .T.

						Endif
					EndIf			
					If lSantParn
						RecLock("NFE",.T.)
						NFE->NFE      := Iif(lTamCpo,Right(SubStr(cLinha,1,8),6),STRZERO(Val(Right(SubStr(cLinha,1,8),9)),9))//NF-e
						NFE->RPS      := Iif(lTamCpo,Right(SubStr(cLinha,13,9),6),Right(SubStr(cLinha,13,9),nTamRPS))//Refer�ncia
						NFE->SERIE    := Right(SubStr(cLinha,22,3),nTamSer)//Refer�ncia
						NFE->EMISSAO  := CTOD(SubStr(cLinha,25,10))//Emiss�o //formato dd/mm/aaaa layout https://www.santanadeparnaiba.sp.gov.br/nfe/layout_exportacao.htm
						NFE->SITUACAO := Iif('cancelada'$SubStr(cLinha,35,10),"C","")//Tipo_Op
						NFE->VERIFICA := SubStr(cLinha,387,8)
						//Loc
						NFE->CODISS   := Right(SubStr(cLinha,49,8),nTamISS)//CodServ
						NFE->ALIQUOTA := Val(SubStr(cLinha,57,5))/100 //Aliq
						NFE->VALSERV  := Val(SubStr(cLinha,62,18))/100//Valor_Total
						//Deducao_Base
						NFE->VALISS   := Val(SubStr(cLinha,98,18))/100 //ISS_Incluso
						NFE->ISSRET   := Val(SubStr(cLinha,116,18))/100//ISS_Retido
						NFE->VALIRRF  := Val(SubStr(cLinha,134,18))/100//IRRF_Retido
						NFE->VALPIS   := Val(SubStr(cLinha,152,18))/100//PIS_Retido
						NFE->VALCOFI  := Val(SubStr(cLinha,170,18))/100//Cofins_Retido
						NFE->VALCSLL  := Val(SubStr(cLinha,188,18))/100//CSLL_Retido
						NFE->VALINSS  := Val(SubStr(cLinha,206,18))/100//INSS_Retido
						If lTamCpo
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
								NFE->CLIENTE := SF2->F2_CLIENTE
								NFE->LOJA    := SF2->F2_LOJA
							EndIf
						Else
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+NFE->RPS + NFE->SERIE))
								NFE->CLIENTE := SF2->F2_CLIENTE
								NFE->LOJA    := SF2->F2_LOJA
							EndIf
						Endif
						//CNPJ_Tomador
						//Munic�pio_Tomador
						//UF
						//Vencimento
						//Link_NF-e
						MsUnLock()
						lCarga := .T.
					Endif
				Endif
				FT_FSkip()
			Enddo
		Else
			lCarga := .F.
		Endif
	EndIf
	FT_FUse()
	FClose(nHandle)

	If File(cArqProc)
		FErase(cArqProc)
	EndIf

	//����������������������������������������Ŀ
	//�Correcao quando ocorrer estouro de linha�
	//������������������������������������������
	If !lEspSanto .AND. !lSAndre .AND. !lItapevi .AND. !lJoinville .AND. !lBarueri .And. !lVRedonda .And. !lOsasco .And. !lSantParn
		dbSelectArea("NFE")
		NFE->(dbGoTop())

		While !NFE->(Eof())

			If Empty(AllTrim(NFE->SITUACAO))
				RecLock("NFE",.F.)
				dbDelete()
				MsUnLock()
				NFE->(FkCommit())
			EndIf

			NFE->(dbSkip())
		EndDo
	EndIf
Else
	cTitulo		:= STR0011				//"Arquivo de importa��o n�o localizado"
	cErro		:= STR0012 + cArqProc	//"N�o foi localizado no diret�rio "
	cErro		+= STR0013 + STR0014	//" o arquivo "," indicado nas perguntas "
	cErro		+= STR0015				//"da rotina."
	cSolucao	:= STR0016				//"Informe o diret�rio e o nome do arquivo "
	cSolucao	+= STR0017				//"corretamente e processe a rotina novamente."

	If !lAutomato
		xMagHelpFis(cTitulo,cErro,cSolucao)
	Else
		Aviso(cTitulo,cErro,{"OK"})
	EndIF

	lCarga := .F.
Endif

Return({lCarga,cArqProc,cSerOsa})

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Mta915Atu   �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Atualiza tabelas do Protheus com as informacoes retornadas    ���
���          �pela Prefeitura Municipal de Sao Paulo / Resende / Santo Andre���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Mta915Atu(cCarga, cSerOsa)

Local aAreaNFE	:= {}
Local aErro		:= {}
Local aNFE		:= {}
Local cChave	:= ""
Local cErro		:= ""
Local cCodISS	:= ""
Local cCnae     := ""
Local cChvSE1	:= ""
Local lSF3		:= .F.
Local lImpNFE	:= ExistBlock("MTIMPNFE")
Local lCodISS	:= .F.
Local lIntTaf	:= .F.
Local nX		:= 0
Local cESPNFEL	:= GetNewPar("MV_ESPNFEL","")

ProcRegua(NFE->(LastRec()))

NFE->(dbGoTop())
Do While !(NFE->(Eof()))

	IncProc()
	//���������������������������������������������������������������Ŀ
	//�Verifica se encontra todos os documentos que serao atualizados:�
	//�SF2, SF3 e SFT. Caso nao encontre, nao sera atualizado.        �
	//�����������������������������������������������������������������
	lSF3 		:= .F.
	lCodISS		:= .T.
	cErro		:= ""
	cCodISS		:= ""
	aErro		:= {}

	If lEspSanto
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		// Notas fiscais canceladas nao possuem SF2
		If NFE->SITUACAO <> "C"
			If lTamCpo
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				Endif
			Else
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				EndIf
			EndIf
		EndIf
		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		SF3->(dbSetOrder(4))
		If lTamCpo
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While SF3->(!Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//����������������������������������������������������������������������������Ŀ
					//�Verifica se o valor do ISS esta diferente para atualizar conforme o retorno.�
					//������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5"
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						Exit
					Endif
					SF3->(dbSkip())
				Enddo
			Else
				lSF3 := .F.
			EndIf
		Else
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While SF3->(!Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//����������������������������������������������������������������������������Ŀ
					//�Verifica se o valor do ISS esta diferente para atualizar conforme o retorno.�
					//������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5" .And. !lVRedonda
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						Exit
					Endif 
					SF3->(dbSkip())
				Enddo
			Else
				lSF3 := .F.
			EndIf
		EndIf
		If !lSF3
			//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."		
			Aadd(aErro,STR0073)
		Endif
	ElseIf lItapevi .Or. lBarueri .Or. lVRedonda
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		// Notas fiscais canceladas nao possuem SF2
		If NFE->SITUACAO <> "C"
			If lTamCpo
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				Endif
			Else
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				EndIf
			EndIf
		EndIf
		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		SF3->(dbSetOrder(4))
		If lTamCpo
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While SF3->(!Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//����������������������������������������������������������������������������Ŀ
					//�Verifica se o valor do ISS esta diferente para atualizar conforme o retorno.�
					//������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5"
						lSF3 := .T.
						If lBarueri
							If (SF3->F3_VALCONT <> NFE->VALISS .And. NFE->ISSRET == 0) .Or. (SF3->F3_VALICM <> NFE->ISSRET .And. NFE->VALISS == 0) 
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							EndIf
						Else
							If (SF3->F3_VALICM <> NFE->VALISS .And. NFE->ISSRET == 0) .Or. (SF3->F3_VALICM <> NFE->ISSRET .And. NFE->VALISS == 0)
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						Exit
					Endif
					SF3->(dbSkip())
				Enddo
			Else
				lSF3 := .F.
			EndIf
		Else
			//������������������������������Ŀ
			//|Verificacao de tamanho do RPS.|
			//��������������������������������
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While SF3->(!Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//����������������������������������������������������������������������������Ŀ
					//�Verifica se o valor do ISS esta diferente para atualizar conforme o retorno.�
					//������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5"
						lSF3 := .T.
						If lBarueri .And. !lVRedonda
							If (SF3->F3_VALCONT <> NFE->VALISS .And. NFE->ISSRET == 0) .Or. (SF3->F3_VALICM <> NFE->ISSRET .And. NFE->VALISS == 0) 
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						ElseIf !lVRedonda
							If (SF3->F3_VALICM <> NFE->VALISS .And. NFE->ISSRET == 0) .Or. (SF3->F3_VALICM <> NFE->ISSRET .And. NFE->VALISS == 0) 
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						Exit
					Endif
					SF3->(dbSkip())
				Enddo
			Else
				//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."		
				Aadd(aErro,STR0073)
			EndIf
		EndIf
	ElseIf lSAndre
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		If lTamCpo
			SF2->(dbSetOrder(1))
			If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
				//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
				Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
			Endif
		Else
			SF2->(dbSetOrder(1))
			If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
				//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
				Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
			Endif
		EndIf
		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		If lTamCpo
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
		Else
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
		EndIf
		SF3->(dbSetOrder(4))
		If !SF3->(dbSeek(cChave))
			//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."		
			Aadd(aErro,STR0073)
		Endif
	ElseIf lJoinville
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		// Notas fiscais canceladas nao possuem SF2
		If NFE->SITUACAO <> "C"
			SF2->(dbSetOrder(1))
			If lTamCpo
				cChave := xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
			Else
				If SF2->(dbSeek(xFilial("SF2")+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->SERIE+NFE->CLIENTE+NFE->LOJA)) 
					cChave := xFilial("SF2")+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
				Elseif SF2->(dbSeek(xFilial("SF2")+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->SERIE+NFE->CLIENTE+NFE->LOJA))
					cChave := xFilial("SF2")+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
				ElseIf SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE+NFE->CLIENTE+NFE->LOJA))
					cChave := xFilial("SF2")+NFE->RPS+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
				Else
					cChave := xFilial("SF2")+NFE->RPS+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
				EndIf
			EndIf
			If !SF2->(dbSeek(cChave))
				//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
				Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
			EndIf
		EndIf
		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		SF3->(dbSetOrder(4))
		If lTamCpo
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
		Else
			If SF3->(dbSeek(xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->SERIE))
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->SERIE
			Elseif SF3->(dbSeek(xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->SERIE))
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->SERIE
			ElseIf SF3->(dbSeek(xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE))
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			Else
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			EndIf
		EndIf
		If SF3->(DbSeek(cChave))
			While SF3->(!Eof()) .And.;
					cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
				//����������������������������������������������������������������������������Ŀ
				//�Verifica se o valor do ISS esta diferente para atualizar conforme o retorno.�
				//������������������������������������������������������������������������������
				If Left(SF3->F3_CFO,1) >= "5" .And. !lVRedonda
					lSF3 := .T.
					//Aceita diferen�as apenas nas casas decimais pois pode haver diferen�as no arredondamento da prefeitura e do Protheus
					If Round(SF3->F3_VALICM,0) <> Round(NFE->VALISS,0)
						//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
						Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
					Endif
					Exit
				Endif
				SF3->(dbSkip())
			End
		Else
			//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."
			Aadd(aErro,STR0073)
		EndIf
	Elseif lOsasco .Or. lRio
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		// Notas fiscais canceladas nao possuem SF2
		If NFE->SITUACAO <> "C"
			If lTamCpo
				SF2->(dbSetOrder(1))
				If lRio
					If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
						//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
						Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
					Endif
				Else
					If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerOsa))
						//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
						Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
					Endif
				EndIf
			Else
				SF2->(dbSetOrder(1))
				If lRio
					If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
						//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
						Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
					Endif
				Else
					If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerOsa))
						//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
						Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
					Endif
				EndIf
			EndIf
		EndIf
		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		If lTamCpo .And. !lOsasco
			SF3->(dbSetOrder(4))
			If lRio
				If NFE->NFE == NFE->RPS
					cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->NFE,6)+Space(03)+NFE->SERIE
				Else
					cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
				EndIf
			Else
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
			EndIf
			If SF3->(dbSeek(cChave))
				While !SF3->(Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//������������������������������������������������������������������������Ŀ
					//�Verifica se o codigo do ISS no arq. de retorno e o mesmo do livro fiscal�
					//��������������������������������������������������������������������������
					If lRecife
						cCnae := Replicate("0",9-Len(Alltrim(SF3->F3_CNAE))) + Alltrim(SF3->F3_CNAE)
						If Right(Substr(NFE->CODATIV,1,9),9) <> Right(Substr(cCnae,1,9),9)
							cCodISS := cCnae
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIF
					Else
						If Val(NFE->CODISS) <> Val(SF3->F3_CODISS)
							cCodISS := SF3->F3_CODISS
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIf
					Endif

					lCodISS := .T.
					//�������������������������������������������������������������������������������������������Ŀ
					//�Verifica se a aliquota e o valor do ISS estao diferentes para atualizar conforme o retorno.�
					//���������������������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5"
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS .And. !lOsasco
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						If SF3->F3_ALIQICM <> NFE->ALIQUOTA .And. !lOsasco
							//"Al�quota no arq. de retorno: diverge da gravada nas notas fiscais: "
							Aadd(aErro,STR0069 + Alltrim(Transform(NFE->ALIQUOTA,"@E 99.99")) + STR0070 + Alltrim(Transform(SF3->F3_ALIQICM,"@E 99.99")))
						Endif

						If lResende	.Or. lManaus .Or. lMacae .Or. lItapevi .Or. lBMansa
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
								If SF2->F2_VALCOFI <> NFE->VALCOFI
									//"Cofins no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0074 + Alltrim(Transform(NFE->VALCOFI,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCOFI,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALCSLL <> NFE->VALCSLL
									//"CSLL no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0075 + Alltrim(Transform(NFE->VALCSLL,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCSLL,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALPIS <> NFE->VALPIS
									//"PIS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0076 + Alltrim(Transform(NFE->VALPIS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALPIS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALINSS <> NFE->VALINSS
									//"INSS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0080 + Alltrim(Transform(NFE->VALINSS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALINSS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALIRRF <> NFE->VALIRRF
									//"IR no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0081 + Alltrim(Transform(NFE->VALIRRF,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALIRRF,"@E 9,999,999.99")))
								Endif
							Endif
						Endif
						Exit
					Endif
					SF3->(dbSkip())
				End
			Else
				lSF3 := .F.	
			Endif
		Else
			SF3->(dbSetOrder(4))
			If lOsasco
				If lTamCpo
					cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+space(3)+cSerOsa
				Else
					cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+cSerOsa
				EndIf
			Else
				cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			EndIf
			If SF3->(dbSeek(cChave))
				While !SF3->(Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//������������������������������������������������������������������������Ŀ
					//�Verifica se o codigo do ISS no arq. de retorno e o mesmo do livro fiscal�
					//��������������������������������������������������������������������������
					If lRecife 
						cCnae := Replicate("0",9-Len(Alltrim(SF3->F3_CNAE))) + Alltrim(SF3->F3_CNAE)
						If Right(Substr(NFE->CODATIV,1,9),9) <> Right(Substr(cCnae,1,9),9)
							cCodISS := cCnae
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIF
					Else
						If Val(NFE->CODISS) <> Val(SF3->F3_CODISS)
							cCodISS := SF3->F3_CODISS
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIf
					Endif

					lCodISS := .T.
					//�������������������������������������������������������������������������������������������Ŀ
					//�Verifica se a aliquota e o valor do ISS estao diferentes para atualizar conforme o retorno.�
					//���������������������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5" .And. !lVRedonda
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS .And. !lOsasco
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						If SF3->F3_ALIQICM <> NFE->ALIQUOTA .And. !lOsasco
							//"Al�quota no arq. de retorno: diverge da gravada nas notas fiscais: "
							Aadd(aErro,STR0069 + Alltrim(Transform(NFE->ALIQUOTA,"@E 99.99")) + STR0070 + Alltrim(Transform(SF3->F3_ALIQICM,"@E 99.99")))
						Endif

						If lResende	.Or. lManaus .Or. lMacae .Or. lItapevi .Or. lBMansa
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
								If SF2->F2_VALCOFI <> NFE->VALCOFI
									//"Cofins no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0074 + Alltrim(Transform(NFE->VALCOFI,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCOFI,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALCSLL <> NFE->VALCSLL
									//"CSLL no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0075 + Alltrim(Transform(NFE->VALCSLL,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCSLL,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALPIS <> NFE->VALPIS
									//"PIS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0076 + Alltrim(Transform(NFE->VALPIS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALPIS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALINSS <> NFE->VALINSS
									//"INSS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0080 + Alltrim(Transform(NFE->VALINSS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALINSS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALIRRF <> NFE->VALIRRF
									//"IR no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0081 + Alltrim(Transform(NFE->VALIRRF,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALIRRF,"@E 9,999,999.99")))
								Endif
							Endif
						Endif
						Exit
					Endif
					SF3->(dbSkip())
				End
			Else
				lSF3 := .F.
			Endif
		EndIf

		If !lCodIss .And. !lRecife
			//"O c�digo do ISS gravado no livro fiscal (SF3) diverge do arquivo de retorno"
			Aadd(aErro,STR0071 + Alltrim(cCodISS) + STR0072 + Alltrim(Str(Val(NFE->CODISS))))
		Endif

		If !lSF3 .And. !lVRedonda
			//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."		
			Aadd(aErro,STR0073)
		Endif
	Else
		//������������������������������������������Ŀ
		//�SF2 - cabecalho das notas fiscais de saida�
		//��������������������������������������������
		// Notas fiscais canceladas nao possuem SF2
		If NFE->SITUACAO <> "C"
			If lTamCpo
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				Endif
			Else
				SF2->(dbSetOrder(1))
				If !SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
					//"N�o foi encontrado o cabe�alho (SF2) do documento. Filial: , RPS: e s�rie: . Verifique se o arquivo est� sendo importado na filial correta."
					Aadd(aErro,STR0063 + xFilial("SF2") + STR0066 )
				Endif
			EndIf
		Endif

		//������������������Ŀ
		//�SF3 - livro Fiscal�
		//��������������������
		If lTamCpo
			SF3->(dbSetOrder(4))
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+Right(NFE->RPS,6)+Space(03)+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While !SF3->(Eof()) .And. cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//������������������������������������������������������������������������Ŀ
					//�Verifica se o codigo do ISS no arq. de retorno e o mesmo do livro fiscal�
					//��������������������������������������������������������������������������
					If lRecife
						cCnae := Replicate("0",9-Len(Alltrim(SF3->F3_CNAE))) + Alltrim(SF3->F3_CNAE)
						If Right(Substr(NFE->CODATIV,1,9),9) <> Right(Substr(cCnae,1,9),9)
							cCodISS := cCnae 
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIF
					Else
						If Val(NFE->CODISS) <> Val(SF3->F3_CODISS)
							cCodISS := SF3->F3_CODISS
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIf
					Endif

					lCodISS := .T.
					//�������������������������������������������������������������������������������������������Ŀ
					//�Verifica se a aliquota e o valor do ISS estao diferentes para atualizar conforme o retorno.�
					//���������������������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5"
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						If SF3->F3_ALIQICM <> NFE->ALIQUOTA
							//"Al�quota no arq. de retorno: diverge da gravada nas notas fiscais: "
							Aadd(aErro,STR0069 + Alltrim(Transform(NFE->ALIQUOTA,"@E 99.99")) + STR0070 + Alltrim(Transform(SF3->F3_ALIQICM,"@E 99.99")))
						Endif

						If lResende	.Or. lManaus .Or. lMacae .Or. lItapevi .Or. lBMansa .Or. lSantParn
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+NFE->SERIE))
								If SF2->F2_VALCOFI <> NFE->VALCOFI
									//"Cofins no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0074 + Alltrim(Transform(NFE->VALCOFI,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCOFI,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALCSLL <> NFE->VALCSLL
									//"CSLL no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0075 + Alltrim(Transform(NFE->VALCSLL,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCSLL,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALPIS <> NFE->VALPIS
									//"PIS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0076 + Alltrim(Transform(NFE->VALPIS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALPIS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALINSS <> NFE->VALINSS
									//"INSS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0080 + Alltrim(Transform(NFE->VALINSS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALINSS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALIRRF <> NFE->VALIRRF
									//"IR no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0081 + Alltrim(Transform(NFE->VALIRRF,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALIRRF,"@E 9,999,999.99")))
								Endif
							Endif
						Endif
						Exit
					Endif
					SF3->(dbSkip())
				End
			Else
				lSF3 := .F.	
			Endif
		Else
			SF3->(dbSetOrder(4))
			cChave := xFilial("SF3")+NFE->CLIENTE+NFE->LOJA+NFE->RPS+NFE->SERIE
			If SF3->(dbSeek(cChave))
				While !SF3->(Eof()) .And.;
					cChave == xFilial("SF3")+SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					//������������������������������������������������������������������������Ŀ
					//�Verifica se o codigo do ISS no arq. de retorno e o mesmo do livro fiscal�
					//��������������������������������������������������������������������������
					If lRecife 
						cCnae := Replicate("0",9-Len(Alltrim(SF3->F3_CNAE))) + Alltrim(SF3->F3_CNAE)
						If Right(Substr(NFE->CODATIV,1,9),9) <> Right(Substr(cCnae,1,9),9)
							cCodISS := cCnae
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIF
					Else
						If Val(NFE->CODISS) <> Val(SF3->F3_CODISS)
							cCodISS := SF3->F3_CODISS
							lCodISS := .F.
							SF3->(dbSkip())
							Loop
						EndIf
					Endif

					lCodISS := .T.
					//�������������������������������������������������������������������������������������������Ŀ
					//�Verifica se a aliquota e o valor do ISS estao diferentes para atualizar conforme o retorno.�
					//���������������������������������������������������������������������������������������������
					If Left(SF3->F3_CFO,1) >= "5" .And. !lVRedonda
						lSF3 := .T.
						If lBarueri
							If SF3->F3_VALCONT <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						Else
							If SF3->F3_VALICM <> NFE->VALISS
								//"ISS no arq. de retorno: diverge do gravado nas notas fiscais: "
								Aadd(aErro,STR0067 + Alltrim(Transform(NFE->VALISS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF3->F3_VALICM,"@E 9,999,999.99")))
							Endif
						EndIf
						If SF3->F3_ALIQICM <> NFE->ALIQUOTA
							//"Al�quota no arq. de retorno: diverge da gravada nas notas fiscais: "
							Aadd(aErro,STR0069 + Alltrim(Transform(NFE->ALIQUOTA,"@E 99.99")) + STR0070 + Alltrim(Transform(SF3->F3_ALIQICM,"@E 99.99")))
						Endif

						If lResende	.Or. lManaus .Or. lMacae .Or. lItapevi .Or. lBMansa .Or. lSantParn
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+NFE->RPS+NFE->SERIE))
								If SF2->F2_VALCOFI <> NFE->VALCOFI
									//"Cofins no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0074 + Alltrim(Transform(NFE->VALCOFI,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCOFI,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALCSLL <> NFE->VALCSLL
									//"CSLL no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0075 + Alltrim(Transform(NFE->VALCSLL,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALCSLL,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALPIS <> NFE->VALPIS
									//"PIS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0076 + Alltrim(Transform(NFE->VALPIS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALPIS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALINSS <> NFE->VALINSS
									//"INSS no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0080 + Alltrim(Transform(NFE->VALINSS,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALINSS,"@E 9,999,999.99")))
								Endif
								If SF2->F2_VALIRRF <> NFE->VALIRRF
									//"IR no arq. de retorno: diverge do gravado nas notas fiscais: "
									Aadd(aErro,STR0081 + Alltrim(Transform(NFE->VALIRRF,"@E 9,999,999.99")) + STR0068 + Alltrim(Transform(SF2->F2_VALIRRF,"@E 9,999,999.99")))
								Endif
							Endif
						Endif
						Exit
					Endif
					SF3->(dbSkip())
				End
			Else
				lSF3 := .F.
			Endif
		EndIf

		If !lCodIss .And. !lRecife
			//"O c�digo do ISS gravado no livro fiscal (SF3) diverge do arquivo de retorno"
			Aadd(aErro,STR0071 + Alltrim(cCodISS) + STR0072 + Alltrim(Str(Val(NFE->CODISS))))
		Endif

		If !lSF3 .And. !lVRedonda
			//"N�o foi localizado o registro no livro fiscal (SF3). Verifique se o c�digo do ISS e o cliente da NF-e correspondem com os do RPS emitido."
			Aadd(aErro,STR0073)
		Endif
	Endif

	//��������������������������������Ŀ
	//�Atualizando tabelas posicionadas�
	//����������������������������������
	If Len(aErro) == 0
		Begin Transaction
			// Notas fiscais canceladas nao possuem SF2
			If NFE->SITUACAO <> "C"
				RecLock("SF2",.F.)
				SF2->F2_NFELETR	:= NFE->NFE
				SF2->F2_EMINFE	:= NFE->EMISSAO
				SF2->F2_HORNFE	:= NFE->HORA
				SF2->F2_CODNFE	:= NFE->VERIFICA
				SF2->F2_CREDNFE	:= NFE->VALCRED
				MsUnLock()
				IF IntTMS()
					DT6->(DbSetOrder(1))
					IF DT6->(DbSeek(xFilial("DT6") + SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE ))
						RecLock("DT6",.F.)
						DT6->DT6_NFELET := NFE->NFE
						DT6->DT6_EMINFE := NFE->EMISSAO
						DT6->DT6_CODNFE := NFE->VERIFICA
						MsUnLock()
						//-- Executa integra��o do Datasul
						If FindFunction("TMSAE76")
							TMSAE76()
						EndIf
						DTC->(DbSetOrder(7))
						IF DTC->(DbSeek(xFilial("DTC") + DT6->DT6_DOC + DT6->DT6_SERIE + DT6->DT6_FILDOC ))
							While !DTC->(Eof()) .and. DTC->DTC_FILIAL == xFilial("DTC") .and.;
								DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_FILDOC ==;
								DT6->DT6_DOC + DT6->DT6_SERIE + DT6->DT6_FILDOC
								RecLock("DTC",.F.)
								DTC->DTC_NFELET	:= NFE->NFE
								DTC->DTC_EMINFE	:= NFE->EMISSAO
								DTC->DTC_CODNFE	:= NFE->VERIFICA
								MsUnLock()
								DTC->(DbSkip())
							EndDO
						EndIF
					EndIF
				EndIF
			Endif
			If lSF3
				RecLock("SF3",.F.)
				SF3->F3_NFELETR	:= NFE->NFE
				SF3->F3_EMINFE	:= NFE->EMISSAO
				SF3->F3_HORNFE	:= NFE->HORA
				SF3->F3_CODNFE	:= NFE->VERIFICA
				SF3->F3_CREDNFE	:= NFE->VALCRED
				MsUnLock()
			EndIf
		End Transaction

		//���������������������������������Ŀ
		//�Atualizando todos os itens do SFT�
		//�����������������������������������
		If lTamCpo .And. !lOsasco
			SFT->(dbSetOrder(1))
			cChave := xFilial("SFT")+"S"+NFE->SERIE+Right(NFE->RPS,9)+Space(03)+NFE->CLIENTE+NFE->LOJA
			If NFE->RPS <> NFE->NFE .And. !lBarueri .And. !lRio .And. !lRecife .And. !lMacae
				cChave := xFilial("SFT")+"S"+NFE->SERIE+Right(NFE->NFE,9)+Space(03)+NFE->CLIENTE+NFE->LOJA
			EndIf
			If SFT->(dbSeek(cChave))
				While !SFT->(Eof()) .And. cChave == xFilial("SFT")+"S"+SFT->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
					//nao faz a verificacao do Codigo de ISS qdo forem processadas as notas para Sto Andre
					If lEspSanto .Or. lOsasco .Or. lItapevi .Or. lRio												
						Mta915Upd(@lIntTaf,cESPNFEL,.T.)	
					ElseIf lBarueri
						Mta915Upd(@lIntTaf,cESPNFEL,.T., ,.T.)
					Elseif lVRedonda .Or. lSAndre
						Mta915Upd(@lIntTaf,cESPNFEL)
					Else
						If !lRecife
							If Val(NFE->CODISS) <> Val(SFT->FT_CODISS)
								SFT->(dbSkip())
								Loop
							Endif
						Endif
						Mta915Upd(@lIntTaf,cESPNFEL,.T.,.T.,.T.)
					EndIf
					SFT->(dbSkip())
				End
			Endif
		Else
			If lJoinville
				SFT->(dbSetOrder(1))
				If SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->CLIENTE+NFE->LOJA)) 
					cChave := xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",6-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+Space(Len(NFE->RPS)-6)+NFE->CLIENTE+NFE->LOJA
				Elseif SFT->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->CLIENTE+NFE->LOJA))
					cChave := xFilial("SFT")+"S"+NFE->SERIE+Replicate("0",len(NFE->RPS)-Len(Alltrim(NFE->RPS)))+AllTrim(NFE->RPS)+NFE->CLIENTE+NFE->LOJA
				ElseIf SF2->(dbSeek(xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS+NFE->CLIENTE+NFE->LOJA))
					cChave := xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS+NFE->CLIENTE+NFE->LOJA
				Else
					cChave := xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS+NFE->CLIENTE+NFE->LOJA
				EndIf
				If SFT->(dbSeek(cChave))
					While !SFT->(Eof()) .And. cChave == xFilial("SFT")+"S"+SFT->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
						Mta915Upd(@lIntTaf,cESPNFEL,.T.,.T.)
						SFT->(dbSkip())
					End
				EndIf
			Else
				SFT->(dbSetOrder(1))
				If lTamCpo .And. lOsasco
					cChave := xFilial("SFT")+"S"+cSerOsa+NFE->RPS+space(3)+NFE->CLIENTE+NFE->LOJA
				ElseIf !lTamCpo .And. lOsasco
					cChave := xFilial("SFT")+"S"+cSerOsa+NFE->RPS+NFE->CLIENTE+NFE->LOJA
				Else
					cChave := xFilial("SFT")+"S"+NFE->SERIE+NFE->RPS+NFE->CLIENTE+NFE->LOJA
				EndIf
				IF NFE->RPS <> NFE->NFE .And. !lBarueri .And. !lSaopaulo .And. !lOsasco .And. !lRio .and. !lBMansa .And. !lRecife .And. !lMacae .And. !lSantParn
					cChave := xFilial("SFT")+"S"+NFE->SERIE+NFE->NFE+NFE->CLIENTE+NFE->LOJA
				EndIf
				If SFT->(dbSeek(cChave))
					While !SFT->(Eof()) .And.; 
						cChave == xFilial("SFT")+"S"+SFT->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
						//nao as a verificacao do Codigo de ISS qdo forem processadas as notas para Sto Andre
						If lEspSanto .Or. lOsasco .Or. lItapevi .Or. lRio
							Mta915Upd(@lIntTaf,cESPNFEL,.T.)	
						ElseIf lBarueri
							Mta915Upd(@lIntTaf,cESPNFEL,.T., ,.T.)	
						Elseif lVRedonda .Or. lSAndre
							Mta915Upd(@lIntTaf,cESPNFEL)
						Else
							If !lRecife
								If Val(NFE->CODISS) <> Val(SFT->FT_CODISS)
									SFT->(dbSkip())
									Loop
								Endif
							Endif
							Mta915Upd(@lIntTaf,cESPNFEL,.T.,.T.,.T.)
						EndIf
						SFT->(dbSkip())
					End
				Endif
			EndIf
		EndIf
		//����������������������������������������������Ŀ
		//�Se tiver o campo E1_NFELETR de nota fiscal    �
		//�eletronica, grava o numero da NFe gerada na   �
		//�prefeitura tambem no titulo (SE1)             �
		//������������������������������������������������
		// Se tiver o campo E1_NFELETR de nota fiscal eletronica, grava o numero da NFe gerada na prefeitura tambem no titulo (SE1)
		If !Empty(SF2->F2_NFELETR)
			cChvSE1 := xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DOC)
			dbSelectArea("SE1")
			dbSetOrder(2) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			MsSeek(cChvSE1) //campo F2_SERIE substituido pelo F2_PREFIXO
			While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cChvSE1 //campo F2_SERIE substituido pelo F2_PREFIXO
				RecLock("SE1",.F.)
				SE1->E1_NFELETR := SF2->F2_NFELETR
				MsUnlock()
				Iif(FindFunction("J255AjNfe"), J255AjNfe(SE1->(Recno())), Nil)
				dbSkip()
			End
		Endif

		//����������������������������������������������Ŀ
		//�Se houve algum erro na atualizacao das tabelas�
		//������������������������������������������������
		If Empty(NFE->IMPORT)
			RecLock("NFE",.F.)
			NFE->IMPORT := "0"
			NFE->ERRO   := STR0039 //"N�o foi poss�vel efetuar a grava��o, tente novamente."
			MsUnLock()
		Endif

		//�����������������������������������������������Ŀ
		//�Ponto de entrada apos a importacao de cada NF-e�
		//�������������������������������������������������
		aAreaNFE := NFE->(GetArea())
		If lImpNFE
			Execblock("MTIMPNFE",.F.,.F.,{cCarga})
		Endif
		RestArea(aAreaNFE)
	Else
		For nX := 1 to Len(aErro)
			// Para criar mais de uma linha caso exista mais de um erro por RPS
			If lResende .Or. lManaus .Or. lMacae .Or. lBMansa
				Aadd(aNFE,{NFE->RPS,NFE->SERIE,NFE->CLIENTE,NFE->LOJA,NFE->NFE,NFE->VALISS,NFE->VALCOFI,NFE->VALCSLL,NFE->VALPIS,NFE->IMPORT,aErro[nX]})
			Else
				Aadd(aNFE,{NFE->RPS,NFE->SERIE,NFE->CLIENTE,NFE->LOJA,NFE->NFE,NFE->VALISS,NFE->IMPORT,aErro[nX]})
			Endif
		Next
	Endif
	NFE->(dbSkip())
Enddo

//������������������������������������������������������������������Ŀ
//�Cria registros na tabela temporaria com todos os erros de cada RPS�
//��������������������������������������������������������������������
For nX := 1 to Len(aNFE)
	NFE->(dbSetOrder(1))
	If NFE->(dbSeek(aNFE[nX][01]+aNFE[nX][02])) .And. Empty(NFE->ERRO)
		RecLock("NFE",.F.)
		NFE->ERRO   := Iif(lResende .Or. lManaus .Or. lMacae .Or. lBMansa,aNFE[nX][11],aNFE[nX][08])
		NFE->IMPORT := "2"
		MsUnLock()
	Else
		RecLock("NFE",.T.)
		NFE->RPS 		:= aNFE[nX][01]
		NFE->SERIE		:= aNFE[nX][02]
		NFE->CLIENTE	:= aNFE[nX][03]
		NFE->LOJA		:= aNFE[nX][04]
		NFE->NFE		:= aNFE[nX][05]
		NFE->VALISS		:= aNFE[nX][06]
		If lResende .Or. lManaus .Or. lMacae .Or. lBMansa
			NFE->VALCOFI	:= aNFE[nX][07]
			NFE->VALCSLL	:= aNFE[nX][08]
			NFE->VALPIS		:= aNFE[nX][09]
			NFE->IMPORT		:= aNFE[nX][10]
			NFE->ERRO		:= aNFE[nX][11]
		Else
			NFE->IMPORT		:= aNFE[nX][07]
			NFE->ERRO		:= aNFE[nX][08]
		Endif
		NFE->IMPORT		:= "3"
		MsUnLock()
	Endif
Next

//Executa integracao com TAF
If lIntTaf
	If FindFunction("TAFExstInt") .AND. TAFExstInt() // VERIFICA INTEGRACAO COM SIGATAF
		If FindFunction("TAFVldAmb") .And. TAFVldAmb("1") .And. FindFunction("ExtTafFExc")
			ExtTafFExc()
		EndIf
	EndIf
EndIf

Return(.T.)	

/*/{Protheus.doc} Mta915Upd
(Atualizacao dos itens dos livros ficais)

@type Function
@author    Flavio Luiz vicco
@since     24/10/2018

@param lIntTaf,  logico, indica se executa integ. TAF no final
@param cESPNFEL, caracter, parametro MV_ESPNFEL
@param lGrvData, logico, indica se grava data
@param lGrvHora, logico, indica se grava hora
@param lGrvInfo, logico, indica se grava info.adicional

@Return Nil, nulo, n�o tem retorno
/*/
Static Function Mta915Upd(lIntTaf, cESPNFEL, lGrvData, lGrvHora, lGrvInfo)

Default lIntTaf  := .F.
Default cESPNFEL := ""
Default lGrvData := .F.
Default lGrvHora := .F.
Default lGrvInfo := .F.

Begin Transaction
	RecLock("SFT",.F.)
	SFT->FT_NFELETR	:= NFE->NFE
	If lGrvData
		If ValType(SFT->FT_EMINFE) == "D"
			SFT->FT_EMINFE := NFE->EMISSAO
		Else
			SFT->FT_EMINFE := dtos(NFE->EMISSAO)
		Endif
	Endif
	If lGrvHora
		SFT->FT_HORNFE	:= NFE->HORA
	EndIf
	If lGrvInfo
		SFT->FT_CODNFE	:= NFE->VERIFICA
		SFT->FT_CREDNFE	:= NFE->VALCRED
	EndIf
	MsUnLock()
	RecLock("NFE",.F.)
	NFE->IMPORT := "1"
	MsUnLock()
End Transaction

If !lIntTaf
	// Verifica se executa integracao TAF para especie informada no parametro MV_ESPNFEL
	If AllTrim(SFT->FT_ESPECIE)$cESPNFEL
		lIntTaf := .T.
	EndIf
EndIf

Return Nil

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �ReportDef   �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Imprime um relatorio de conferencia com os dados importados e ���
���          �os que nao foram importados por algum erro - Release 4        ���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportDef()

Local aOrdem 	:= {}

Local cCab		:= ""

Local oReport
Local oImport
Local oTotal

//�����������������������Ŀ
//�Componente de impressao�
//�������������������������
//�����������������������������������������������Ŀ
//�Verifica o cabecalho, de acordo com o Municipio�
//�������������������������������������������������
Do Case
	Case lItapevi
		cCab := "Itapevi"
	Case lBarueri
		cCab := "Barueri"
	Case lResende
		cCab := "Resende"
	Case lManaus
		cCab := "Manaus"
	Case lSAndre
		cCab := "Santo Andre"
	Case lEspSanto
		cCab := "Vitoria"
	Case lRecife
		cCab := "Recife"
	Case lMacae
		cCab := "Macae"
	Case lJoinville
		cCab := "Joinville"
	Case lBMansa
		cCab := "Barra Mansa"
	Case lVRedonda
		cCab := "Volta Redonda"
	Case lOsasco
		cCab := "Osasco"
	Case lRio
		cCab := "Rio de Janeiro"
	Case lSaopaulo
		cCab := "S�o Paulo"
	Case lSantParn
		cCab := "Santana de Parna�ba"
EndCase

oReport := TReport():New("MATA915",STR0051 + cCab,"MTA915", {|oReport| ReportPrint(oReport)},STR0052) // "Relat�rio de confer�ncia de importa��o da Nota Fiscal Eletr}onica - ","Este programa ir� apresentar uma listagem com o resultado da importa��o do retorno da Nota Fiscal Eletr�nica"
oReport:HideParamPage()
oReport:SetLandscape()

//������������������������������Ŀ
//�Secao 1 Impressao da Listagem �
//��������������������������������
oImport := TRSection():New(oReport,STR0051,{"NFE"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Relat�rio de confer�ncia de importa��o da Nota Fiscal Eletr}onica - S�o Paulo"
oImport:SetHeaderSection(.T.) 
oImport:SetReadOnly()
TRCell():New(oImport,"RPS"		,"NFE",STR0037 /*"N�mero RPS"*/,/*Picture*/,TamSX3("FT_NFISCAL")[1]+2,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"SERIE"	,"NFE",STR0038 /*"S�rie"*/,"!!!",TamSX3("FT_SERIE")[1]+2,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"CLIENTE"	,"NFE",STR0053 /*"Cliente"*/,/*Picture*/,TamSX3("A1_COD")[1]+2,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"LOJA"		,"NFE",STR0054 /*"Loja"*/,/*Picture*/,TamSX3("A1_LOJA")[1]+2,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"NFE"		,"NFE",STR0055 /*"NF-e"*/,/*Picture*/,TamSX3("FT_NFELETR")[1]+2,/*lPixel*/,/*{|| codblock de impressao }*/)
If !lSAndre
TRCell():New(oImport,"VALISS"	,"NFE",STR0056 /*"Valor ISS"*/,PesqPict("SFT","FT_VALICM"),TamSX3("FT_VALICM")[1],/*lPixel*/,/*{|| codblock de impressao }*/)
EndIf
If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lSantParn
	TRCell():New(oImport,"VALCOFI"	,"NFE",STR0077 /*"Valor Cofins"*/,PesqPict("SFT","FT_VALICM"),TamSX3("FT_VALICM")[1],/*lPixel*/,/*{|| codblock de impressao }*/)
	TRCell():New(oImport,"VALCSLL"	,"NFE",STR0078 /*"Valor CSLL"*/,PesqPict("SFT","FT_VALICM"),TamSX3("FT_VALICM")[1],/*lPixel*/,/*{|| codblock de impressao }*/)
	TRCell():New(oImport,"VALPIS"	,"NFE",STR0079 /*"Valor PIS"*/,PesqPict("SFT","FT_VALICM"),TamSX3("FT_VALICM")[1],/*lPixel*/,/*{|| codblock de impressao }*/)
Endif
TRCell():New(oImport,"IMPORT"	,"NFE",STR0057 /*"Status"*/,/*Picture*/,10,/*lPixel*/,{|| Iif(NFE->IMPORT == "1",STR0048,STR0049) })
TRCell():New(oImport,"ERRO"		,"NFE",STR0058 /*"Mensagem de Erro"*/,/*Picture*/,110,/*lPixel*/,/*{|| codblock de impressao }*/)

oTotal := TRFunction():New(oImport:Cell("RPS"),Nil,"COUNT",/*oBreak2*/,STR0061,"9999999999",/*uFormula*/,.F.,.T.) // "Total de documentos importados sem erro: "
oTotal:SetCondition({ || NFE->IMPORT == "1" })
oTotal := TRFunction():New(oImport:Cell("RPS"),Nil,"COUNT",/*oBreak2*/,STR0062,"9999999999",/*uFormula*/,.F.,.T.) // "Total de documentos n�o importados:      "
oTotal:SetCondition({ || NFE->IMPORT == "2" })

Return(oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Mary C. Hergert     � Data � 03/07/2006  ���
���������������������������������������������������������������������������͹��
���Desc.     �Impressao do detalhe do relatorio de conferencia no Release 4 ���
���������������������������������������������������������������������������͹��
���Uso       �Mata915                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)

Local cChave := ""

//����������������������������������������Ŀ
//�Regua de Processamento                  �
//������������������������������������������
oReport:SetMeter(NFE->(LastRec()))
oReport:Section(1):Init()

NFE->(dbGoTop())

Do While !NFE->(Eof())
	If lTamCpo
		If cChave == Right(Substr(NFE->RPS,1,6),6)+"   "+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
			oReport:Section(1):Cell("RPS"):Hide()
			oReport:Section(1):Cell("SERIE"):Hide()
			oReport:Section(1):Cell("CLIENTE"):Hide()
			oReport:Section(1):Cell("LOJA"):Hide()
			oReport:Section(1):Cell("NFE"):Hide()
			If !lSAndre
			oReport:Section(1):Cell("VALISS"):Hide()
			EndIf
			If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lSantParn
				oReport:Section(1):Cell("VALCOFI"):Hide()
				oReport:Section(1):Cell("VALCSLL"):Hide()
				oReport:Section(1):Cell("VALPIS"):Hide()
			Endif
			oReport:Section(1):Cell("IMPORT"):Hide()
		Else
			oReport:Section(1):Cell("RPS"):Show()
			oReport:Section(1):Cell("SERIE"):Show()
			oReport:Section(1):Cell("CLIENTE"):Show()
			oReport:Section(1):Cell("LOJA"):Show()
			oReport:Section(1):Cell("NFE"):Show()
			If !lSAndre
			oReport:Section(1):Cell("VALISS"):Show()
			EndIf
			If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lSantParn
				oReport:Section(1):Cell("VALCOFI"):Show()
				oReport:Section(1):Cell("VALCSLL"):Show()
				oReport:Section(1):Cell("VALPIS"):Show()
			Endif
			oReport:Section(1):Cell("IMPORT"):Show()
			cChave := Left(Substr(NFE->RPS,4,9),9)+"   "+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
		Endif
	Else
		If cChave == NFE->RPS+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
			oReport:Section(1):Cell("RPS"):Hide()
			oReport:Section(1):Cell("SERIE"):Hide()
			oReport:Section(1):Cell("CLIENTE"):Hide()
			oReport:Section(1):Cell("LOJA"):Hide()
			oReport:Section(1):Cell("NFE"):Hide()
			If !lSAndre
			oReport:Section(1):Cell("VALISS"):Hide()
			EndIf
			If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lSantParn
				oReport:Section(1):Cell("VALCOFI"):Hide()
				oReport:Section(1):Cell("VALCSLL"):Hide()
				oReport:Section(1):Cell("VALPIS"):Hide()
			Endif
			oReport:Section(1):Cell("IMPORT"):Hide()
		Else
			oReport:Section(1):Cell("RPS"):Show()
			oReport:Section(1):Cell("SERIE"):Show()
			oReport:Section(1):Cell("CLIENTE"):Show()
			oReport:Section(1):Cell("LOJA"):Show()
			oReport:Section(1):Cell("NFE"):Show()
			If !lSAndre
			oReport:Section(1):Cell("VALISS"):Show()
			EndIf
			If lResende .Or. lManaus .Or. lMacae .Or. lBMansa .Or. lSantParn
				oReport:Section(1):Cell("VALCOFI"):Show()
				oReport:Section(1):Cell("VALCSLL"):Show()
				oReport:Section(1):Cell("VALPIS"):Show()
			Endif
			oReport:Section(1):Cell("IMPORT"):Show()
			cChave := NFE->RPS+NFE->SERIE+NFE->CLIENTE+NFE->LOJA
		Endif
	EndIf

	oReport:Section(1):PrintLine()
	oReport:IncMeter()

	NFE->(dbSkip())

Enddo

oReport:Section(1):Finish()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FReadLine	�Autor�                      � Data �  27/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para leitura de linhas com o tamanho superior a 1023 ���
�������������������������������������������������������������������������͹��
���Uso       �           							                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FReadLine()
Local 	cLinhaTmp		:= ""
Local	cLinhaM100		:= ""

cLinhaTmp	:= FT_FReadLN()
If !Empty(cLinhaTmp)
	cIdent	:= SubStr(cLinhaTmp,1,1)
	If Len(cLinhaTmp) < 1023
		cLinhaM100	:= cLinhaTmp
	Else
		cLinAnt		:= cLinhaTmp
		cLinhaM100	+= cLinAnt
		Ft_FSkip()
		cLinProx:= Ft_FReadLN()
		If Len(cLinProx) >= 1023 .and. SubStr(cLinProx,1,1) <> cIdent
			While Len(cLinProx) >= 1023 .and. SubStr(cLinProx,1,1) <> cIdent .and. !Ft_fEof() .And. Len(cLinhaM100) < 1024000
				cLinhaM100 += cLinProx
				Ft_FSkip()
				cLinProx := Ft_fReadLn()
				If Len(cLinProx) < 1023 .and. SubStr(cLinProx,1,1) <> cIdent
					cLinhaM100 += cLinProx
				EndIf
			Enddo
		Else
			cLinhaM100 += cLinProx
		EndIf
	EndIf
EndIf
Return cLinhaM100

/*/{Protheus.doc} nomeStaticFunction

	Busca o cliente para qual foi emitido o documento 	
	Search the customer the document was issued to
	
	@type  Static Function
	@author Igor Ramos
	@since 02/05/2019
	@version 1.0
		@param lSdoc 		is true when the size of the F2_SERIE field is less than 3
		@param cLinhaUtf 	is Processed file line
		@param cEspChave	document type
		@param aEspecie		Specify the document defined in MV_ESPECIE
		@param aAux			auxiliary array to monitor processed records	
	@return Verdadeiro se encontrou o registro e posiciona no registro encontrado
	true if found the record and placed on the record
	/*/
Static Function findClient(lSdoc,cLinhaUtf,cEspChave,aEspecie,aAux)
 	Local nL 		:= 0
	Local nTamRPS	:= TamSX3("FT_NFISCAL")[1]

	For nL:=1 to len(aEspecie)
		If lSdoc
			cSerId := SubStr(aEspecie[nL],1,3) + SubStr(SubStr(cLinhaUtf,13,8),5,2) + SubStr(SubStr(cLinhaUtf,13,8),1,4)+cEspChave
		Else
			cSerId := SubStr(aEspecie[nL],1,3)
		EndIf

		SF2->(dbSetOrder(4))
		If  SF2->(dbSeek(xFilial("SF2")+cSerId+dTos(NFE->EMISSAO)+Padr(NFE->RPS,nTamRPS,"")))
			If ASCAN(aAux, xFilial("SF2")+cSerId+dTos(NFE->EMISSAO)+Padr(NFE->RPS,nTamRPS,"")) == 0 
				NFE->CLIENTE	:= SF2->F2_CLIENTE
				NFE->LOJA		:= SF2->F2_LOJA
				NFE->SERIE		:= cSerId
				aAdd(aAux,xFilial("SF2")+cSerId+dTos(NFE->EMISSAO)+Padr(NFE->RPS,nTamRPS,""))
				Return .T.
			EndIf
		Endif
		
		SF2->(dbSetOrder(1))
		If lTamCPO .And. SF2->(dbSeek(xFilial("SF2")+Right(NFE->RPS,6)+Space(03)+cSerId))
			If ASCAN(aAux, xFilial("SF2")+cSerId+Padr(NFE->RPS,nTamRPS,"")) == 0 
				NFE->CLIENTE	:= SF2->F2_CLIENTE
				NFE->LOJA		:= SF2->F2_LOJA
				NFE->SERIE		:= cSerId
				aAdd(aAux,xFilial("SF2")+cSerId+Padr(NFE->RPS,nTamRPS,""))
				Return .T.
			EndIf
		ElseIf SF2->(dbSeek(xFilial("SF2")+NFE->RPS+cSerId))
			If ASCAN(aAux, xFilial("SF2")+cSerId+Padr(NFE->RPS,nTamRPS,"")) == 0 
				NFE->CLIENTE	:= SF2->F2_CLIENTE
				NFE->LOJA		:= SF2->F2_LOJA
				NFE->SERIE		:= cSerId
				aAdd(aAux,xFilial("SF2")+cSerId+Padr(NFE->RPS,nTamRPS,""))
				Return .T.
			EndIf
		EndIf
	Next
Return .F.

