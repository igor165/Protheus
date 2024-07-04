#Include "fileio.ch"
#Include "Protheus.ch"
#Include "GPEM700.CH"
#define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GPEM700  ºAutor  ³Equipe Inovacao RH              ³  05/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc      ³ Consignacao em folha de pagamento (Generico)		                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	  ³ BOPS/FNC  ³  Motivo da Alteracao 		            ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºCecilia.C  |17/10/13|MRH12-RQ013|Unificacao da Folha de Pagamento          ³±±
±±³Esther V.  |22/04/14|M_RH003    |Replica V11 para V12. Tratamento do para- ³±±
±±³           |        |           |metro MV_ITMCLVL para aceitar '3', nao    ³±±
±±³           |        |           |obrigando o preenchimento dos campos.     ³±±
±±³Esther V.  |27/05/14|M_RH003    |Ajustes na função fImpFolha() para gravar ³±±
±±³           |        |           |itens na tabela RGB em vez de SRC.        ³±±
±±³Leandro Dr.|07/01/16|TUCWUM     |Ajuste no sispag para tratar os segmentos ³±±
±±³           |        |           |dos tipos I e H.                          ³±±
±±³Renan B.   ³10/06/16³TVJON2     ³Ajuste p/ buscar a posicao correta do lote³±±
±±³           ³        ³           ³quando for layout H do SISPAG  		     ³±±
±±³P. Pompeu..|05/07/16|TVNIQ4     |Pergunta Regra de Desc. e alteracao na GUI|**
±±³Tiago B.	|18/04/17|MPRIMESP-  |Ajsute na gravação do campo RK_STATUS      ³±±
±±³           ³        ³9563       ³
±±³Tiago B.	|22/08/17|MPRIMESP-  |Ajsute na gravação do campo RK_STATUS       ³±±
±±³           ³        ³10319      ³Quando afastado e RK_EMPCONS              ³±±
±±³Oswaldo L  |31/10/16|DRHPAG-7555|Alterar sistema para utilizar tabela      ³±±
±±³           |        |           |fisica SGX                                ³±±
±±³           |        |           | Manter ainda tratativas ctree no fonte   ³±±
±±³Jaqueline L|11/01/18|DRHPAG-   |Correçao para filtrar o processo correta  ³±±
±±³           |        |10616      |mente do que está sendo importado         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM700()
Local aArea
Local cPath			:= ""
Local cPath1		:= ""
Local cPath2		:= ""
Local cArqBkp		:= ""
Local cArquivo		:= "RHLAYOUT"
Local cArqDbf		:= cArquivo+GetDBExtension()
Local cArqNtx		:= cArquivo+OrdBagExt()
Local cIndCond		:= "TRB_BANCO+TRB_LAYOUT"
Local cDriver		:= "DBF"
Local aFixe			:= {}
Local aFields		:= {}
Local aMsg			:= {}
Private cBanco		:= ""
Private cNome		:= ""
Private nLayout		:= 0
Private cArqConf	:= ""
Private cRemRet		:= ""
Private cTipoPag	:= ""
Private cCPF		:= ""
Private cParcela	:= ""
Private cValor		:= ""
Private cVerba		:= ""
Private cConsQtd	:= ""
Private cNConsQtd	:= ""
Private cConsVal	:= ""
Private cNConsVal	:= ""
Private aRotina		:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro	:= OemToAnsi(STR0024) //"Consignacao em Folha de Pagamento"
Private cArqDados	:= ""
Private aModelo		:= {}
Private aCores		:= {}
Private lNvTab		:= TabNovaDic()
Private cRDD		:= __LocalDriver

If lNvTab

	DbSelectArea('SGX')
	If File(cArqDbf) .And. SGX->(RecCount()) == 0
		aAdd( aMsg, OemToAnsi(STR0171) )
		Help( ,, OemToAnsi(STR0169),, OemToAnsi(STR0170), 1,,,,,,, aMsg )	//"Carga Inicial do Legado de Consignação, RHLAYOUT"
		//	"Devido à descontinuidade do uso de driver ISAM, a rotina de Consignação deixará de utilizar o arquivo RHLAYOUT, passando a usar a tabela SGX do banco de dados."
		//	"Efetue a carga inicial das informações contidas no arquivo RHLAYOUT através da rotina RSPM004, e remova o arquivo da pasta System para utilizar esta rotina."
		return
	EndIf

	aCores	  := { { "SGX->GX_BCO<>''" , 'BR_VERDE' } }

	DBSELECTAREA('SRA')
	AAREA := GetArea()

	AADD( aModelo , { "1" , oEmToAnsi(STR0017) } ) // Cnab Padrao
	AADD( aModelo , { "2" , oEmToAnsi(STR0018) } ) // Cnab Modelo 2
	AADD( aModelo , { "3" , oEmToAnsi(STR0019) } ) // Sispag

	AADD( aFields , { 'GX_BCO' , 'C',  03, 0 } )
	AADD( aFields , { 'GX_NOME'  , 'C',  20, 0 } )
	AADD( aFields , { 'GX_LAYO', 'C',  01, 0 } )
	AADD( aFields , { 'GX_CONF', 'C', 150, 0 } )
	AADD( aFields , { 'GX_POSC', 'C',  03, 0 } ) // Posicao CPF
	AADD( aFields , { 'GX_POSP', 'C',  03, 0 } ) // Posicao Parcela
	AADD( aFields , { 'GX_POSV', 'C',  03, 0 } ) // Posicao Valor da Parcela
	AADD( aFields , { 'GX_VERBA' , 'C',  03, 0 } ) // Verba para desconto em folha
	AADD( aFields , { 'GX_VERRE', 'C',  03, 0 } ) // Verba para desconto em rescisao
	AADD( aFields , { 'GX_REMR', 'C',  03, 0 } ) // Remessa/Retorno
	AADD( aFields , { 'GX_TIPOP', 'C',  03, 0 } ) // Tipo de Pagamento (Averbacao, Manutencao, Consignacao)
	AADD( aFields , { 'GX_QTCON' , 'C',  03, 0 } ) // Posicao Qtde Total Consignado (Parcelas)
	AADD( aFields , { 'GX_QTNC', 'C',  03, 0 } ) // Posicao Qtde Total Nao Consignado (Parcelas)
	AADD( aFields , { 'GX_VLCON' , 'C',  03, 0 } ) // Posicao Valor Total Consignado
	AADD( aFields , { 'GX_VLNC', 'C',  03, 0 } ) // Posicao Valor Total Nao Consignado

	AADD( aFixe   , { STR0025 , 'GX_BCO' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0026 , 'GX_NOME'  , 'C',  20, 0 , '!@' } )
	AADD( aFixe   , { STR0027 , 'GX_LAYO', 'C',  01, 0 , '!@' } )
	AADD( aFixe   , { STR0028 , 'GX_CONF', 'C', 150, 0 , '!@' } )
	AADD( aFixe   , { STR0055 , 'GX_POSC', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0084 , 'GX_POSP', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0029 , 'GX_POSV', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0030 , 'GX_VERBA' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0141 , 'GX_VERRE', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0146 , 'GX_REMR', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0147 , 'GX_TIPOP', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0150 , 'GX_QTCON' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0151 , 'GX_QTNC', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0152 , 'GX_VLCON' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0153 , 'GX_VLNC', 'C',  03, 0 , '!@' } )

	mBrowse( 6 , 1 , 22 , 75 , 'SGX' , aFixe , 'GX_BCO' ,,, 2 , aCores )

	RestArea( aArea )

Else
	aCores	  := { { "TRB->TRB_BANCO<>''" , 'BR_VERDE' } }

	DBSELECTAREA('SRA')
	AAREA := GetArea()

	AADD( aModelo , { "1" , oEmToAnsi(STR0017) } ) // Cnab Padrao
	AADD( aModelo , { "2" , oEmToAnsi(STR0018) } ) // Cnab Modelo 2
	AADD( aModelo , { "3" , oEmToAnsi(STR0019) } ) // Sispag

	AADD( aFields , { 'TRB_BANCO' , 'C',  03, 0 } )
	AADD( aFields , { 'TRB_NOME'  , 'C',  20, 0 } )
	AADD( aFields , { 'TRB_LAYOUT', 'C',  01, 0 } )
	AADD( aFields , { 'TRB_CONFIG', 'C', 150, 0 } )
	AADD( aFields , { 'TRB_POSCPF', 'C',  03, 0 } ) // Posicao CPF
	AADD( aFields , { 'TRB_POSPAR', 'C',  03, 0 } ) // Posicao Parcela
	AADD( aFields , { 'TRB_POSVAL', 'C',  03, 0 } ) // Posicao Valor da Parcela
	AADD( aFields , { 'TRB_VERBA' , 'C',  03, 0 } ) // Verba para desconto em folha
	AADD( aFields , { 'TRB_VERRES', 'C',  03, 0 } ) // Verba para desconto em rescisao
	AADD( aFields , { 'TRB_REMRET', 'C',  03, 0 } ) // Remessa/Retorno
	AADD( aFields , { 'TRB_TIPOPG', 'C',  03, 0 } ) // Tipo de Pagamento (Averbacao, Manutencao, Consignacao)
	AADD( aFields , { 'TRB_QTCON' , 'C',  03, 0 } ) // Posicao Qtde Total Consignado (Parcelas)
	AADD( aFields , { 'TRB_QTNCON', 'C',  03, 0 } ) // Posicao Qtde Total Nao Consignado (Parcelas)
	AADD( aFields , { 'TRB_VLCON' , 'C',  03, 0 } ) // Posicao Valor Total Consignado
	AADD( aFields , { 'TRB_VLNCON', 'C',  03, 0 } ) // Posicao Valor Total Nao Consignado

	AADD( aFixe   , { STR0025 , 'TRB_BANCO' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0026 , 'TRB_NOME'  , 'C',  20, 0 , '!@' } )
	AADD( aFixe   , { STR0027 , 'TRB_LAYOUT', 'C',  01, 0 , '!@' } )
	AADD( aFixe   , { STR0028 , 'TRB_CONFIG', 'C', 150, 0 , '!@' } )
	AADD( aFixe   , { STR0055 , 'TRB_POSCPF', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0084 , 'TRB_POSPAR', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0029 , 'TRB_POSVAL', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0030 , 'TRB_VERBA' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0141 , 'TRB_VERRES', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0146 , 'TRB_REMRET', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0147 , 'TRB_TIPOPG', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0150 , 'TRB_QTCON' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0151 , 'TRB_QTNCON', 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0152 , 'TRB_VLCON' , 'C',  03, 0 , '!@' } )
	AADD( aFixe   , { STR0153 , 'TRB_VLNCON', 'C',  03, 0 , '!@' } )

	If !File(cArqDbf)
		DbCreate(cArqDbf,aFields,cRDD)
		dbUseArea(.T.,cRDD,cArqDbf,"TRB")
	Else
		// Monta o path do arquivo de acordo com Mp8Srv.ini
		cPath1 := GetPvProfString( GetEnvServer(),"RootPath","",GetAdv97() )
		cPath2 := GetPvProfString( GetEnvServer(),"StartPath","",GetAdv97() )
		cPath  := cPath1 + cPath2

		nPos  := At("\\",cPath)
		If nPos > 0
			cPath := SubStr(cPath,1,nPos-1) + SubStr(cPath,nPos+1)
		Endif
		If Right(cPath,1) != "\"
			cPath += "\"
		Endif

		MsOpenDbf(.T.,cRDD,cArqDbf,"TRB", .T., .F.)
		If TRB->( Type("TRB_VERRES") ) == "U" .OR. ;
		   TRB->( Type("TRB_REMRET") ) == "U" .OR. ;
		   TRB->( Type("TRB_TIPOPG") ) == "U" .OR. ;
		   TRB->( Type("TRB_QTCON" ) ) == "U" .OR. ;
		   TRB->( Type("TRB_QTNCON") ) == "U" .OR. ;
		   TRB->( Type("TRB_VLCON" ) ) == "U" .OR. ;
		   TRB->( Type("TRB_VLNCON") ) == "U"
			TRB->( DbCloseArea() )

			cArqBkp := RetArq(cDriver,cArquivo+".#DB",.F.)

			FErase(cArqBkp)
			FRename(cPath+cArqDbf,cPath+cArqBkp)
			FErase(cArqNtx)

			// Cria o novo arquivo
			DbCreate(cArqDbf,aFields,cRDD)

			// Abre o novo arquivo e faz append do backup
			MsOpenDbf(.T.,cRDD,cArqDbf,"TRB",.T.,.F.)
			DbSelectArea("TRB")
			MyAppend("TRB",cArqBkp)
		Endif
	Endif

	If !File( cArqNtx )
		IndRegua( "TRB", cArqNtx, cIndCond,,, STR0048 )  //"Aguarde"
	Else
		Set Index To (cArqNtx)
	Endif

	mBrowse( 6 , 1 , 22 , 75 , 'TRB' , aFixe , 'TRB_BANCO' ,,, 2 , aCores )
	TRB->( DbCloseArea() )
	RestArea( aArea )

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fManutTRB    º Autor ³ Kelly Soares          ³  06/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao e alteracao de registro na tabela rhlayout.dbf    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fManutTRB(cAlias,nReg,nOpcx)
Local aArea 	:= GetArea()
Local oDlg
Local oMain
Local oGroup
Local oLayout
Local oVerba
Local oVerbaRes
Local oBtn
Local nX
Local nOpca	:= 0
Local nPos1	:= 0
Local lAppend	:= .F.
Local aCombo	:= {}
Local bSet15 	:= {|| }
Local bSet24	:= {|| }
Local cTitulo	:= If( nOpcx = 1 , STR0031 , If( nOpcx = 2 , STR0032 , STR0033 ) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private aVerbas 	:= {}
Private cBanco		:= space(003)
Private cNome		:= space(025)
Private cLayout		:= space(001)
Private cArqConf	:= space(150)
Private cPosCPF		:= space(003)
Private cPosPar		:= space(003)
Private cPosVal		:= space(003)
Private cPosCod		:= space(003)
Private cPosPag		:= space(003)
Private cVerba		:= space(003)
Private cDVerba		:= space(050)
Private cVerbaRes	:= space(003)
Private cDVerbaRes	:= space(050)
Private cQtdeCon	:= space(003)
Private cQtdeNCon	:= space(003)
Private cValorCon	:= space(003)
Private cValorNCon	:= space(003)

SRV->( DbSelectArea("SRV") )
SRV->( DbSetOrder(1) )
SRV->( DbGoTop() )

While !SRV->( Eof() )
	aAdd( aVerbas , { SRV->RV_COD , SRV->RV_DESC } )
	SRV->( DbSkip() )
Enddo

For nX := 1 to len(aModelo)
	aAdd( aCombo , aModelo[nX,1] + "=" + aModelo[nX,2] )
Next nX

If nOpcx = 2
	If lNvTab
		cBanco	 	:= SGX->GX_BCO
		cNome	 	:= SGX->GX_NOME
		cArqConf 	:= SGX->GX_CONF
		cPosCPF		:= SGX->GX_POSC
		cPosPar		:= SGX->GX_POSP
		cPosVal		:= SGX->GX_POSV
		cPosCod		:= SGX->GX_REMR
		cPosPag		:= SGX->GX_TIPOP
		cVerba	 	:= SGX->GX_VERBA
		cVerbaRes 	:= SGX->GX_VERRE
		cQtdeCon 	:= SGX->GX_QTCON
		cQtdeNCon 	:= SGX->GX_QTNC
		cValorCon 	:= SGX->GX_VLCON
		cValorNCon  := SGX->GX_VLNC
		fSelVerba(@cVerba,@cDVerba,1)
		fSelVerba(@cVerbaRes,@cDVerbaRes,1)
	Else
		cBanco	 	:= TRB->TRB_BANCO
		cNome	 	:= TRB->TRB_NOME
		cArqConf 	:= TRB->TRB_CONFIG
		cPosCPF		:= TRB->TRB_POSCPF
		cPosPar		:= TRB->TRB_POSPAR
		cPosVal		:= TRB->TRB_POSVAL
		cPosCod		:= TRB->TRB_REMRET
		cPosPag		:= TRB->TRB_TIPOPG
		cVerba	 	:= TRB->TRB_VERBA
		cVerbaRes 	:= TRB->TRB_VERRES
		cQtdeCon 	:= TRB->TRB_QTCON
		cQtdeNCon 	:= TRB->TRB_QTNCON
		cValorCon 	:= TRB->TRB_VLCON
		cValorNCon := TRB->TRB_VLNCON
		fSelVerba(@cVerba,@cDVerba,1)
		fSelVerba(@cVerbaRes,@cDVerbaRes,1)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as Dimensoes dos Objetos         				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize		:= MsAdvSize(,.T.,400)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMain PIXEL

	@ aObjSize[1,1]+5, aObjSize[1,4]*0.02  Say OemToAnsi(STR0025)+":"		PIXEL
	@ aObjSize[1,1]+3,(aObjSize[1,4]*0.02)+20  MSGET cBanco		SIZE 20,10		PIXEL

	@ aObjSize[1,1]+5, aObjSize[1,4]*0.20  Say OemToAnsi(STR0026)+":"		PIXEL
	@ aObjSize[1,1]+3,(aObjSize[1,4]*0.20)+20  MSGET cNome			SIZE 75,10	PIXEL

	@ aObjSize[1,1]+5, aObjSize[1,4]*0.55  Say OemToAnsi(STR0027)+":"		PIXEL
	@ aObjSize[1,1]+3, (aObjSize[1,4]*0.55)+23 MSCOMBOBOX oLayout	VAR cLayout	ITEMS aCombo SIZE 55,10 OF oDlg PIXEL
	If nOpcx = 2

		If !lNvTab
			nPos1 := Ascan( aCombo , { |x| Left(x,1) = TRB->TRB_LAYOUT } )
		Else
			nPos1 := Ascan( aCombo , { |x| Left(x,1) = SGX->GX_LAYO } )
		EndIf

		If nPos1 > 0
			oLayout:nAt := nPos1
		Endif
	Endif

	@ aObjSize[1,1]+23, aObjSize[1,4]*0.02  Say OemToAnsi(STR0028)+":"				PIXEL
	@ aObjSize[1,1]+21,(aObjSize[1,4]*0.02)+69  MSGET cArqConf			   SIZE 155,10	PIXEL
	@ aObjSize[1,1]+22,(aObjSize[1,4]*0.02)+224  BUTTON "..." 				   SIZE 12,10   ACTION ( fGetArqDados(@cArqConf) ) PIXEL

	// ----- Verbas para desconto -----
	@ aObjSize[2,1], aObjSize[2,4]*0.02 GROUP oGroup TO  aObjSize[2,3], aObjSize[2,4]*0.99 PROMPT oEmToAnsi(STR0142) OF oDlg PIXEL

	// FOLHA
	@ aObjSize[2,1]+9, aObjSize[2,4]*0.04  Say OemToAnsi(STR0143)				PIXEL
	@ aObjSize[2,1]+7, (aObjSize[2,4]*0.04)+30  MSGET cVerba		SIZE 30,7	PIXEL ;
			  ON CHANGE ( fSelVerba(@cVerba,@cDVerba,1) )
	@((aObjSize[2,1]+7)*2), (aObjSize[2,4]*0.04)+143  BTNBMP oBtn RESOURCE "pesquisa"		SIZE 025,025	OF oDlg PIXEL ACTION fSelVerba(@cVerba,@cDVerba,2)
	@aObjSize[2,1]+7, (aObjSize[2,4]*0.04)+80  MSGET oVerba		VAR cDVerba		   	SIZE 115,007	OF oDlg PIXEL WHEN .F.

	// RESCISAO
	@ aObjSize[2,1]+23, aObjSize[2,4]*0.04  Say OemToAnsi(STR0144)+":"			PIXEL
	@ aObjSize[2,1]+21, (aObjSize[2,4]*0.04)+30  MSGET cVerbaRes	SIZE 30,7	PIXEL ;
			  ON CHANGE ( fSelVerba(@cVerbaRes,@cDVerbaRes,1) )
	@ ((aObjSize[2,1]+21)*2), (aObjSize[2,4]*0.04)+143  BTNBMP oBtn RESOURCE "pesquisa"		SIZE 025,025	OF oDlg PIXEL ACTION fSelVerba(@cVerbaRes,@cDVerbaRes,2)
	@ aObjSize[2,1]+21, (aObjSize[2,4]*0.04)+80  MSGET oVerbaRes		VAR cDVerbaRes	   	SIZE 115,007	OF oDlg PIXEL WHEN .F.

	// ----- Posicoes no Layout -----
	@ aObjSize[3,1], aObjSize[3,4]*0.02 GROUP oGroup TO aObjSize[3,3]-10, aObjSize[3,4]*0.99 PROMPT oEmToAnsi(STR0056) OF oDlg PIXEL

	// REMESSA/RETORNO
	@ aObjSize[3,1]+10, aObjSize[3,4]*0.04  Say OemToAnsi(STR0148)+":"		PIXEL
	@ aObjSize[3,1]+10, (aObjSize[3,4]*0.04)+25  MSGET cPosCod				SIZE 40,7	PIXEL

	// TIPO PAGTO
	@ aObjSize[3,1]+10, aObjSize[3,4]*0.30  Say OemToAnsi(STR0149)+":"		PIXEL
	@ aObjSize[3,1]+10, (aObjSize[3,4]*0.30)+23  MSGET cPosPag				SIZE 40,7	PIXEL

	// CPF
	@ aObjSize[3,1]+10, aObjSize[3,4]*0.60  Say OemToAnsi(STR0057)+":"		PIXEL
	@ aObjSize[3,1]+10, (aObjSize[3,4]*0.60)+15  MSGET cPosCPF				SIZE 40,7	PIXEL

	// ----- Parcela(s) -------------
	@ aObjSize[3,1]+25, aObjSize[3,4]*0.04 GROUP oGroup TO aObjSize[3,1]+53,aObjSize[3,4]*0.97 PROMPT oEmToAnsi(STR0154) OF oDlg PIXEL

	// NUMERO
	@ aObjSize[3,1]+35, aObjSize[3,4]*0.06  Say OemToAnsi(STR0155)+":"		PIXEL
	@ aObjSize[3,1]+35, (aObjSize[3,4]*0.06)+25  MSGET cPosPar				SIZE 35,7	PIXEL

	// QTDE CONSIG.
	@ aObjSize[3,1]+35, aObjSize[3,4]*0.30  Say OemToAnsi(STR0150)+":"		PIXEL
	@ aObjSize[3,1]+35, (aObjSize[3,4]*0.30)+40  MSGET cQtdeCon			SIZE 35,7	PIXEL

	// QTDE NAO CONSIG.
	@ aObjSize[3,1]+35, aObjSize[3,4]*0.60  Say OemToAnsi(STR0151)+":"		PIXEL
	@ aObjSize[3,1]+35, (aObjSize[3,4]*0.60)+40  MSGET cQtdeNCon			SIZE 35,7	PIXEL

	// ----- Valor(es) --------------
	@ aObjSize[3,1]+58, aObjSize[3,4]*0.04 GROUP oGroup TO aObjSize[3,1]+86,aObjSize[3,4]*0.97 PROMPT oEmToAnsi(STR0158) OF oDlg PIXEL

	// VALOR
	@ aObjSize[3,1]+68, aObjSize[3,4]*0.06  Say OemToAnsi(STR0058)+":"				PIXEL
	@ aObjSize[3,1]+68, (aObjSize[3,4]*0.06)+25  MSGET cPosVal				   SIZE 35,7	PIXEL

	// TOTAL CONSIG.
	@ aObjSize[3,1]+68, aObjSize[3,4]*0.30  Say OemToAnsi(STR0152)+":"				PIXEL
	@ aObjSize[3,1]+68, (aObjSize[3,4]*0.30)+40  MSGET cValorCon			   SIZE 35,7	PIXEL

	// TOTAL NAO CONSIG.
	@ aObjSize[3,1]+68, aObjSize[3,4]*0.60  Say OemToAnsi(STR0153)+":"				PIXEL
	@ aObjSize[3,1]+68, (aObjSize[3,4]*0.60)+40  MSGET cValorNCon			   SIZE 35,7	PIXEL

    bSet15 := {|| If (fTRBTudoOk(cAlias,nReg,nOpcx),oDlg:End(),)}
    bSet24 := {|| oDlg:End()}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, Nil) CENTERED
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fTRBTudoOk   º Autor ³ Kelly Soares          ³  09/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checa os dados informados e grava na tabela.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fTRBTudoOk(cAlias,nReg,nOpcx)
Local lOk  := .T.
Local cMsg := ""

	If Empty(AllTrim(cBanco))
		cMsg := STR0025
	ELseif Empty(AllTrim(cNome))
		cMsg := STR0026
	ELseif Empty(AllTrim(cArqConf))
		cMsg := STR0028
	ELseif Empty(AllTrim(cPosCPF))
		cMsg := STR0055
	ELseif Empty(AllTrim(cPosVal))
		cMsg := STR0029
	ELseif Empty(AllTrim(cVerba))
		cMsg := STR0145
	Endif

	If !( cMsg == '' )
		lOk := .F.
		Alert(oEmToAnsi(STR0049)+oEmToAnsi(cMsg))
	Else
		lAppEnd := nOpcx == 1

		If lNvTab .And. lAppEnd
			DbSelectArea("SGX")
			DbSetOrder(1) //GX_FILIAL+GX_BCO+GX_LAYO+GX_CONF

			If SGX->( MsSeek( xFilial("SGX") + cBanco + cLayout + cArqConf ) )
				Alert( OemToAnsi(STR0172) ) //Já existe registro cadastrado com esse Banco, Layout e Arquivo.
				Return .F.
			EndIf
		EndIf

		RecLock(cAlias,lAppEnd)

		If !lNvTab
			TRB->TRB_BANCO	:= cBanco
			TRB->TRB_NOME	:= cNome
			TRB->TRB_LAYOUT	:= cLayout
			TRB->TRB_CONFIG	:= cArqConf
			TRB->TRB_POSCPF	:= StrZero(Val(cPosCPF),3)
			TRB->TRB_POSPAR	:= StrZero(Val(cPosPar),3)
			TRB->TRB_POSVAL	:= StrZero(Val(cPosVal),3)
			TRB->TRB_REMRET	:= StrZero(Val(cPosCod),3)
			TRB->TRB_TIPOPG	:= StrZero(Val(cPosPag),3)
			TRB->TRB_VERBA	:= cVerba
			TRB->TRB_VERRES	:= cVerbaRes
			TRB->TRB_QTCON	:= cQtdeCon
			TRB->TRB_QTNCON	:= cQtdeNCon
			TRB->TRB_VLCON	:= cValorCon
			TRB->TRB_VLNCON	:= cValorNCon
		Else
			SGX->GX_FILIAL := Fwxfilial('SGX')
			SGX->GX_BCO	:= cBanco
			SGX->GX_NOME	:= cNome
			SGX->GX_LAYO	:= cLayout
			SGX->GX_CONF	:= cArqConf
			SGX->GX_POSC	:= StrZero(Val(cPosCPF),3)
			SGX->GX_POSP	:= StrZero(Val(cPosPar),3)
			SGX->GX_POSV	:= StrZero(Val(cPosVal),3)
			SGX->GX_REMR	:= StrZero(Val(cPosCod),3)
			SGX->GX_TIPOP	:= StrZero(Val(cPosPag),3)
			SGX->GX_VERBA	:= cVerba
			SGX->GX_VERRE	:= cVerbaRes
			SGX->GX_QTCON	:= cQtdeCon
			SGX->GX_QTNC	:= cQtdeNCon
			SGX->GX_VLCON	:= cValorCon
			SGX->GX_VLNC	:= cValorNCon
		EndIf

		MsUnlock()
	Endif
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fSelVerba    º Autor ³ Kelly Soares          ³  06/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Dialogo para escolha da verba.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelVerba(cCodigo	,;	// Codigo da Verba
						      cDescricao	,;	// Descricao da Verba
						      nTipo)			// 1 = Digitacao, 2 = Dialogo para escolha
Local oDlg
Local oFont1
Local oLbx
Local cLbx
Local oBtn1
Local oBtn2
Local bSet15
Local bSet24
Local nX
Local nPos	  := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	   := {}
Local aGDCoord		:= {}

If nTipo = 1
	nPos := Ascan( aVerbas , { |x| x[1] == AllTrim(cCodigo) } )
	If nPos > 0
		cDescricao := aVerbas[nPos,2]
	Else
		cDescricao := ""
	Endif
Else
//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³ Monta as Dimensoes dos Objetos    ³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*58) }	//1,3 Vertical /1,4 Horizontal

	DEFINE FONT oFont1  NAME "Arial"        SIZE 7,16 BOLD
	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0043) PIXEL

	// ----- Verbas para desconto -----
	@ aGdCoord[1],aGdCoord[2] GROUP oGroup TO aGdCoord[3],aGdCoord[4] PROMPT oEmToAnsi(STR0044) OF oDlg PIXEL

	@ aGdCoord[1]+10,aGdCoord[2]+10 LISTBOX oLbx VAR cLbx FIELDS HEADER	oEmToAnsi(STR0045), oEmToAnsi(STR0046) ;
		ON DBLCLICK ( cCodigo := aVerbas[oLbx:nAt,1] , cDescricao := aVerbas[oLbx:nAt,2] , oDlg:End() );
		SIZE (aGdCoord[4]- aGdCoord[2])-20,(aGdCoord[3]-aGdCoord[1])-20 OF oDlg PIXEL
	 		oLbx:SetArray(aVerbas)
			oLbx:LHSCROLL := .F.
			oLbx:LVSCROLL := .T.

			// Posiciona o listbox na verba atual
			For nX := 1 to len(aVerbas)
				If aVerbas[nX,1] == AllTrim(cCodigo)
					oLbx:nAt := nX
					nX := len(aVerbas)
				Endif
			Next nX

			oLbx:bLine := { || { aVerbas[oLbx:nAt,1] , aVerbas[oLbx:nAt,2] } }

	bSet15 := {|| cCodigo := aVerbas[oLbx:nAt,1] , cDescricao := aVerbas[oLbx:nAt,2] , oDlg:End()}
	bSet24 := {|| oDlg:End()}

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, Nil) CENTERED
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fExcTRB      º Autor ³ Kelly Soares          ³  06/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui um registro da tabela rhlayout.dbf                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fExcTRB(cAlias,nReg,nOpcx)
IF MsgYesNo( STR0047 ) //"Confirma a exclusao deste item?"
	RecLock(cAlias,.F.)
	dbDelete()
	MsUnlock()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fChamaProc   º Autor ³ Kelly Soares          ³  05/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite selecionar um arquivo de retorno a ser processado. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fChamaProc(cAlias,nReg,nOpcx)
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList({"RA_CIC"}) )

	If lBlqAcesso	//Tratamento de acesso a dados pessoais
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Else
		If !lNvTab
			cBanco		:= 	TRB->TRB_BANCO
			cNome		:= 	TRB->TRB_NOME
			nLayout	    := 	Val(TRB->TRB_LAYOUT)
			cArqConf	:= 	TRB->TRB_CONFIG
			cRemRet	    := 	TRB->TRB_REMRET
			cTipoPag	:= 	TRB->TRB_TIPOPG
			cCPF 		:= 	TRB->TRB_POSCPF
			cParcela	:= 	TRB->TRB_POSPAR
			cValor		:= 	TRB->TRB_POSVAL
			cVerba		:= 	TRB->TRB_VERBA
			cConsQtd	:= 	TRB->TRB_QTCON
			cNConsQtd	:= 	TRB->TRB_QTNCON
			cConsVal	:= 	TRB->TRB_VLCON
			cNConsVal	:= 	TRB->TRB_VLNCON
		Else
			cBanco		:= 	SGX->GX_BCO
			cNome		:= 	SGX->GX_NOME
			nLayout	    := 	Val(SGX->GX_LAYO)
			cArqConf	:= 	SGX->GX_CONF
			cRemRet	    := 	SGX->GX_REMR
			cTipoPag	:= 	SGX->GX_TIPOP
			cCPF 		:= 	SGX->GX_POSC
			cParcela	:= 	SGX->GX_POSP
			cValor		:= 	SGX->GX_POSV
			cVerba		:= 	SGX->GX_VERBA
			cConsQtd	:= 	SGX->GX_QTCON
			cNConsQtd	:= 	SGX->GX_QTNC
			cConsVal	:= 	SGX->GX_VLCON
			cNConsVal	:= 	SGX->GX_VLNC
		EndIf

		If fGetArqDados(@cArqDados)
			Processa( { |lEnd| GPM700Processa( nOpcx , nLayout , cArqConf ) , STR0001 } )
		Endif
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Gpm700processa  º Autor ³ Kelly Soares       ³  05/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a tela com as informacoes do arquivo de dados.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM700                                          		      º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gpm700processa(nOpcx,nModelo,cArqConfig)
Local aArea		:= GetArea()
Local aSvKeys		:= GetKeys()
Local bSet15
Local bSet24
Local nLidos    := 0
Local nHdlCampos
Local nHdlDados
Local nHdlSaida
Local nTam
Local nDec
Local nTamLinha
Local nX, nY
Local nComeco
Local nPos
Local nCont 		:= 0
Local nOrdem		:= 0
Local nMaxLin		:= 0
Local cFile
Local cUsado		:= ""
Local cAlerta		:= ""
Local cNovoValor	:= ""
Local cResto		:= ""
Local lFirst
Local cRepasse   := ""
Local cConteudo  := ""

// -- variaveis para modelo SISPAG --------------
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A - Header Arquivo       ³
	//³ B - Header  Lote         ³
	//³ D - Trailer Lote         ³
	//³ F - Trailer Arquivo      ³
	//³ G - Segmento I           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cHeadArq  	:= "A"
Local cTraiArq  	:= "F"
Local cHeadLote 	:= "B"
Local cTraiLote 	:= "D"
Local cDetaG    	:= "G"
Local nHdArq		:=0
Local nHdLt		:=0
Local nTrArq		:=0
Local nTrLt		:=0

// ----------------------------------------------

// -- variaveis para modelo CNAB 2 --------------
Local aHeader2		:= {}
Local aDetalhe2		:= {}
Local aTrailler2 	:= {}
Local nTrailler		:= 0
Local nTag2		   := 0
// ----------------------------------------------

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords 	:= {}
Local aObjSize		:= {}
Local aRegs	      	:= {}
Local cHelp		   := ""

Local nObjX 	:= 0
Local bObjY 	:= {|n|( ( aObjSize[1,4]/100*n ) + 6 )}
Local aSizes 	:= {}
Local nTamTxt	:= 0
Local cDadosTxt:= ""
Local cConfigTxt:= ""
Local cSaidaTxt:= ""

Private cPerg		:= ""

// -- Arrays que armazenam Header e Trailler ----
Private aHDArq		:= {}
Private aTRArq		:= {}
Private	aHdLt		:= {}
Private	aTrlt		:= {}
Private aArqConfig  := {}

// ----------------------------------------------

// -- variaveis para opcao 5 = Gerar Remessa ----
Private cX1Proc	    := ""
Private cX1Periodo  := ""
Private cX1NumPag   := ""
Private cX1Roteiro  := ""
Private cArqSaida   := ""
Private cPergRem    := ""
Private cPergPag    := ""
Private nConsVlr    := 1
Private lHeader     := .F.
Private lDetalhe    := .F.
Private lTrailler   := .F.
Private lExeFormOk  := .T.	// Interrompe processamento se GP700ALT() modificar esta VAR para .F. indicando erro na formula do arquivo

// ----------------------------------------------
Private oGet
Private oLbxArq
Private cLbxArq
Private oCor
Private oOk 		   := LoadBitmap( GetResources(), "LBOK" )
Private oNo 		   := LoadBitmap( GetResources(), "LBNO" )

Private cFormato	   := ""
Private cChave		:= ""
Private cExibe		:= ""
Private nCpCPF		:= 0
Private nCpPAR		:= 0
Private nCpVAL		:= 0
Private nCpCOD		:= 0
Private nOrdCOD		:= 0
Private nTamCOD		:= 0
Private nCpPAG		:= 0
Private nOrdPAG		:= 0
Private nTamPAG		:= 0
Private nCpQTD		:= 0
Private nTamQTD		:= 0
Private nCpQTDN		:= 0
Private nTamQTDN	   := 0
Private nCpVLR		:= 0
Private nTamVLR		:= 0
Private nDecVLR		:= 0
Private nCpVLRN		:= 0
Private nTamVLRN	   := 0
Private nDecVLRN	   := 0
Private nUsado		:= 0
Private nIndSRA		:= 0
Private aCols 		:= {}
Private aColsAux  	:= {}
Private aColsTudo	:= {}
Private aHeader		:= {}
Private aList 		:= {}
Private aHead 		:= {}
Private nCpoRepass	:= 0

Private cFilDesc	:= ""
Private cMatDesc	:= ""
Private nValParcela := 0
Private nValCalc    := 0
Private nValNAplic  := 0
Private nQtConsig	:= 0
Private nQtNConsig	:= 0
Private nVlConsig	:= 0
Private nVlNConsig	:= 0
Private nTipoLay	   := nModelo

Private oBtnRep
Private oBtnNRep
Private oBtnTodos
Private oBtnParcial
Private oBtnDetalhe

Private oAzul 		:= LoadBitmap( GetResources(), "BR_AZUL" )
Private oVerde 		:= LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho		:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oCinza		:= LoadBitmap( GetResources(), "BR_CINZA" )
Private aRotina     := { { "chamada","Ft320Work",0,4} }

If nOpcx == 5 //gerar remessa
	If !Pergunte('GPM700B',.T.)
		Return
	Endif

	cX1Proc	:= mv_par01   // Processo
	cX1Periodo	:= mv_par02   // Periodo
	cX1NumPag	:= mv_par03   // Num. Pagto
	cX1Roteiro	:= mv_par04   // Roteiro
	cArqSaida	:= mv_par05   // Arquivo de Saida
	cPergRem	:= mv_par06   // Codigo Remessa
	cPergPag	:= mv_par07   // Tipo Pagamento
	nConsVlr	:= mv_par08   // Consistir Valores Calculados
	cChave		:= cX1Periodo+cX1Roteiro+cX1NumPag+cVerba
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo de configuracao.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !FILE(cArqConfig)
	Help(" ",1,"NOARQPAR")
	Return
Else
	nHdlCampos:=FOPEN(cArqConfig,0+64)
EndIF

SX3->( DbSelectArea("SX3") )
SX3->( DbSetorder(1) )
SX3->( DbSeek("SRA02") ) // SRA - Matricula
cUsado := SX3->X3_USADO

Do Case
	Case nModelo == 1 // CNAB PADRAO
		cHeader1	:= CHR(1)
		cTrailler1	:= CHR(3)
	Case nModelo == 2 // CNAB MODELO 2
		cHeader1	:= "H"
		cTrailler1	:= "T"
	Case nModelo == 3 // SISPAG
		cHeader1	:= "AB"
		cTrailler1	:= "DF"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega configuracoes do arquivo.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !( nModelo == 2 ) // Cnab Padrao e Sispag
	nCont  := 0
	nLidos := 0
	fSeek(nHdlCampos,0,0)
	nTamArq:=FSEEK(nHdlCampos,0,2)
	fSeek(nHdlCampos,0,0)

	While nLidos <= nTamArq
		xBuffer:=Space(85)
		FREAD(nHdlCampos,@xBuffer,85)
		cConteudo := UPPER(AllTrim( SubStr(xBuffer,24, Len(  xBuffer ) - 24 )))

		IF  ( Empty(AllTrim(xBuffer)) ) .or. ;
			( SubStr(xBuffer,1,1) $ cHeader1 ) .or. ;
			( SubStr(xBuffer,1,1) $ cTrailler1 )

			If ( SubStr(xBuffer,1,1) $ cHeader1 )
				If SubStr(xBuffer,17,3)	= cRemRet
					nCpCOD  := Val(cRemRet)
					nTamCOD := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
					nOrdCOD := 1

				ElseIf SubStr(xBuffer,17,3)	= cTipoPag
					nCpPAG  := Val(cTipoPag)
					nTamPAG := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
				       	If ( nModelo == 3 ) // Sispag
				  			nOrdPAG := 2         // Registro Header de Lote
				  		else  // Cnab Padrao
					  		nOrdPAG := 1         // Registro Header de Arquivo
					  	EndIf
				Endif

				If "GP700ALT(" $ cConteudo
					aAdd( aArqConfig, { "H", Val(SubStr(xBuffer,17,3)), Val(SubStr(xBuffer,20,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
					lHeader := .T.
				EndIf
			ElseIf ( SubStr(xBuffer,1,1) $ cTrailler1 )
				If SubStr(xBuffer,17,3)	= cConsQtd
					nCpQTD  := Val(cConsQtd)
					nTamQTD := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
				ElseIf SubStr(xBuffer,17,3)	= cNConsQtd
					nCpQTDN  := Val(cNConsQtd)
					nTamQTDN := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
				ElseIf SubStr(xBuffer,17,3)	= cConsVal
					nCpVLR  := Val(cConsVal)
					nTamVLR := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
					nDecVLR := Val(SubStr(xBuffer,23,1))
				ElseIf SubStr(xBuffer,17,3)	= cNConsVal
					nCpVLRN  := Val(cNConsVal)
					nTamVLRN := Val(SubStr(xBuffer,20,3)) - Val(SubStr(xBuffer,17,3)) + 1
					nDecVLRN := Val(SubStr(xBuffer,23,1))
				Endif
				If "GP700ALT(" $ cConteudo
					aAdd( aArqConfig, { "T", Val(SubStr(xBuffer,17,3)), Val(SubStr(xBuffer,20,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
					lTrailler := .T.
				EndIf
			Endif

			nLidos+=85
			Loop
		Endif

		If "GP700ALT(" $ cConteudo
			aAdd( aArqConfig, { "D", Val(SubStr(xBuffer,17,3)), Val(SubStr(xBuffer,20,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
			lDetalhe := .T.
		Endif

		nCont++
		nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
		nDec := Val(SubStr(xBuffer,23,1))
		aAdd( aHeader , { Substr(xBuffer,2,15) , ;	// TITULO
						  "campo"+StrZero(nCont,2) , ;	// CAMPO
						  "!@" , ;						// PICTURE
						  nTam , ;						// TAMANHO
						  nDec , ;						// DECIMAL
						  "" , ;						   // VALID
						  cUsado , ;					   // USADO
						  "C" , ;						   // TIPO
						  "" , ;						   // F3
						  "" } )
		nLidos+=85
		nTamLinha := Val(SubStr(xBuffer,20,3)) + 1

		If SubStr(xBuffer,17,3)	= cCPF
			nCpCPF := nCont
		ElseIf SubStr(xBuffer,17,3)	= cValor
			nCpVAL := nCont
		ElseIf SubStr(xBuffer,17,3)	= cParcela
			nCpPAR := nCont
   		ElseIf 'REPAS' $ Upper( Substr(xBuffer,2,15) ) .And. !('NAO' $ Upper( Substr(xBuffer,2,15) )) 		// Valida existencia de campo de REPASSE S/N Conforme Layout
			If nCpoRepass == 0
				nCpoRepass := nCont
			Endif
		Endif
	EndDo

Else // Cnab Modelo 2
	nCont  := 0
	nLidos := 0
	fSeek(nHdlCampos,0,0)
	nTamArq:=FSEEK(nHdlCampos,0,2)
	fSeek(nHdlCampos,0,0)

	While nLidos <= nTamArq
		nTag2 := 0
		xBuffer:=Space(502)
		FREAD(nHdlCampos,@xBuffer,502)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena a estrutura do layout.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While SubStr(xBuffer,1,1) == "1"
			nTag2 := 1
			If SubStr(xBuffer,3,1) == "H"
				aAdd( aHeader2 , SubStr(xBuffer,2,1) )
			Elseif SubStr(xBuffer,3,1) == "D"
				aAdd( aDetalhe2 , SubStr(xBuffer,2,1) )
			Elseif SubStr(xBuffer,3,1) == "T"
				aAdd( aTrailler2 , SubStr(xBuffer,2,1) )
			Endif

			nLidos += 502
			If nLidos <= nTamArq
				xBuffer:=Space(502)
				FREAD(nHdlCampos,@xBuffer,502)
			Endif
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena os dados do layout.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While SubStr(xBuffer,1,1) == "2"
			nTag2 := 1
			cConteudo := UPPER(AllTrim( SubStr(xBuffer,27, Len(xBuffer)-27 )))

			IF  ( Empty(AllTrim(xBuffer)) ) .or. ;
				( SubStr(xBuffer,3,1) $ cHeader1 ) .or. ;
				( SubStr(xBuffer,3,1) $ cTrailler1 )

				If SubStr(xBuffer,3,1) $ cHeader1

					If SubStr(xBuffer,20,3)	= cRemRet
						nCpCOD  := Val(cRemRet)
						nTamCOD := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
						nOrdCOD := Val(SubStr(xBuffer,3,1)) + 1
					ElseIf SubStr(xBuffer,20,3)	= cTipoPag
						nCpPAG  := Val(cTipoPag)
						nTamPAG := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
						nOrdPAG := Val(SubStr(xBuffer,3,1)) + 1
					Endif
					If "GP700ALT(" $ cConteudo
						aAdd( aArqConfig, { "H", Val(SubStr(xBuffer,20,3)), Val(SubStr(xBuffer,23,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
						lHeader := .T.
					EndIf

				ElseIf ( SubStr(xBuffer,3,1) $ cTrailler1 )

					If SubStr(xBuffer,20,3)	= cConsQtd
						nCpQTD  := Val(cConsQtd)
						nTamQTD := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
					ElseIf SubStr(xBuffer,20,3)	= cNConsQtd
						nCpQTDN  := Val(cNConsQtd)
						nTamQTDN := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
					ElseIf SubStr(xBuffer,20,3)	= cConsVal
						nCpVLR  := Val(cConsVal)
						nTamVLR := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
						nDecVLR := Val(SubStr(xBuffer,26,1))
					ElseIf SubStr(xBuffer,20,3)	= cNConsVal
						nCpVLRN  := Val(cNConsVal)
						nTamVLRN := Val(SubStr(xBuffer,23,3)) - Val(SubStr(xBuffer,20,3)) + 1
						nDecVLRN := Val(SubStr(xBuffer,26,1))
					Endif
					If "GP700ALT(" $ cConteudo
						aAdd( aArqConfig, { "T", Val(SubStr(xBuffer,20,3)), Val(SubStr(xBuffer,23,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
						lTrailler := .T.
					EndIf
				Endif

				nLidos += 502
				If nLidos <= nTamArq
					xBuffer:=Space(502)
					FREAD(nHdlCampos,@xBuffer,502)
				Endif
				Loop
			Endif

			If SubStr(xBuffer,3,1) == "D"
 				If "GP700ALT(" $ cConteudo
					aAdd( aArqConfig, { "D", Val(SubStr(xBuffer,20,3)), Val(SubStr(xBuffer,23,3)), SubStr(cConteudo,10,RAT(")",cConteudo)-10)})
					lDetalhe := .T.
				EndIf

				nCont++
				nTam := 1+(Val(SubStr(xBuffer,23,3))-Val(SubStr(xBuffer,20,3)))
				nDec := Val(SubStr(xBuffer,26,1))
				aAdd( aHeader , { Substr(xBuffer,5,15) , ;	// TITULO
								  "campo"+StrZero(nCont,2) , ;	// CAMPO
								  "!@" , ;						// PICTURE
								  nTam , ;						// TAMANHO
								  nDec , ;						// DECIMAL
								  "" , ;						   // VALID
								  cUsado , ;					   // USADO
								  "C" , ;					 	   // TIPO
								  "" , ;						   // F3
								  "" } )
				nTamLinha := Val(SubStr(xBuffer,23,3)) + 1

				If SubStr(xBuffer,20,3)	= cCPF
					nCpCPF := nCont
				ElseIf SubStr(xBuffer,20,3)	= cValor
					nCpVAL := nCont
				ElseIf SubStr(xBuffer,20,3)	= cParcela
					nCpPAR := nCont
				ElseIf 'REPAS' $ Upper( Substr(xBuffer,5,15) )		// Valida existencia de campo de REPASSE S/N Conforme Layout
					nCpoRepass := nCont
				Endif
			Endif

			nLidos += 502
			If nLidos <= nTamArq
				xBuffer:=Space(502)
				FREAD(nHdlCampos,@xBuffer,502)
			Endif
		Enddo

		If nTag2 = 0
			nLidos += 502
		Endif
	Enddo
Endif

If Empty(nCpCPF)
	cAlerta := oEmToAnsi(STR0057) //"CPF"
Endif
If Empty(nCpPAR)
	If Empty(cAlerta)
		cAlerta := oEmToAnsi(STR0085) //"Parcela"
	Else
		cAlerta += ", " + oEmToAnsi(STR0085)
	Endif
Endif
If Empty(nCpVAL)
	If Empty(cAlerta)
		cAlerta := oEmToAnsi(STR0058) //"Valor"
	Else
		cAlerta += ", " + oEmToAnsi(STR0058) //"Valor"
	Endif
Endif

If !Empty(cAlerta)
	Alert(oEmToAnsi(STR0136) + " " + Upper(cAlerta) + " " + oEmToAnsi(STR0137))	//"Posição informada para campo XXXXX inválida. Verifique o arquivo de configuração e acerte o cadastro do layout."
	Return
Endif

nUsado := Len(aHeader)
lFirst := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo de dados.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cArqDados)
	Return
Endif

IF !FILE(cArqDados)
	Alert(STR0006)
	Return
Else
	nHdlDados:=FOPEN(cArqDados,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega dados do arquivo.		                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTrailler	:= nTamLinha * len(aTrailler2) + len(aTrailler2)
nCont		:= 0
nLidos		:= 0
fSeek(nHdlDados,0,0)
nTamArq		:=FSEEK(nHdlDados,0,2)
fSeek(nHdlDados,0,0)

While nLidos <= nTamArq
	xBuffer:=Space(nTamLinha+1)
	FREAD(nHdlDados,@xBuffer,nTamLinha+1)

	// Ignora linha em branco
	If ( Empty(AllTrim(xBuffer)) )
		nLidos+=nTamLinha+1
		Loop
	Endif

	// No CNAB padrao, o detalhe sempre comeca na segunda linha
	If ( nModelo == 1 )
		If( lFirst )

			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lHeader
				xBuffer := GP700ALT("H", xBuffer)
			EndIf

			// Interrompe processamento se GP700ALT() modificou esta VAR para .F. indicando erro na formula do arquivo
			If ! lExeFormOk
				Exit
			EndIf

			aAdd( aHDArq , xBuffer ) // Guarda o Header na Array
			nLidos+=nTamLinha+1
			lFirst := .F.
			Loop
		Else
			If ( nLidos+nTamLinha+1 < nTamArq )
				nCont++
				//Se o Detalhe do arquivo padrao sera alterado conforme o arquivo de layout
				If lDetalhe
					xBuffer := GP700ALT("D", xBuffer)
				EndIf
				fGravaLin(nCont,xBuffer)
			Else
				//Se o Trailler do arquivo padrao sera alterado conforme o arquivo de layout
				If lTrailler
					xBuffer := GP700ALT("T", xBuffer)
				EndIf
				aAdd( aTRArq , xBuffer ) // Guarda o Trailler na Array
			Endif
		Endif
	Endif

	If ( nModelo == 2 )

		If( lFirst ) // Header

			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lHeader
				xBuffer := GP700ALT("H", xBuffer)
			EndIf

			// Interrompe processamento se GP700ALT() modificou esta VAR para .F. indicando erro na formula do arquivo
			If ! lExeFormOk
				Exit
			EndIf

			aAdd ( aHDArq , xBuffer ) // Guarda o Header na Array
			aDel ( aHeader2 , len(aHeader2) )
			aSize( aHeader2 , len(aHeader2)-1 )
			nLidos+=nTamLinha+1

			If len(aHeader2) = 0
				lFirst := .F.
			Endif

			Loop
		Else // Detalhe e Trailler

			If ( nLidos+nTrailler < nTamArq )
				nCont++

				//Se o Detalhe do arquivo padrao sera alterado conforme o arquivo de layout
				If lDetalhe
					xBuffer := GP700ALT("D", xBuffer)
				EndIf

				fGravaLin(nCont,xBuffer)
			Else

				//Se o Trailler do arquivo padrao sera alterado conforme o arquivo de layout
				If lTrailler
					xBuffer := GP700ALT("T", xBuffer)
				EndIf

				aAdd ( aTRArq , xBuffer ) // Guarda o Trailler na Array
				aDel ( aTrailler2 , len(aTrailler2) )
				aSize( aTrailler2 , len(aTrailler2)-1 )
			Endif
		Endif
	Endif

	If 	( nModelo == 3 ) // SISPAG ITAU
		If ( Substr(xBuffer,8,1) == "3" ) .AND. ( Substr(xBuffer,14,1) $ "I/H" )
			ncont++
			//Se o Detalhe do arquivo padrao sera alterado conforme o arquivo de layout
			If lDetalhe
				xBuffer := GP700ALT("D", xBuffer)
			EndIf
			fGravaLin( nCont, xBuffer )
		ElseIf ( Substr(xBuffer,8,1) == "0" )
			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lHeader
				xBuffer := GP700ALT("H", xBuffer)
			EndIf
			aAdd( aHDArq, { xBuffer, Substr(xBuffer,4,4) }) // Guarda o Header na Array
		ElseIf ( Substr(xBuffer,8,1) == "1" )
			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lHeader
				xBuffer := GP700ALT("H", xBuffer)
			EndIf
			aAdd( aHDLt, { xBuffer, If( Substr(xBuffer, 14, 1) == "I", Substr(xBuffer, 4, 4), Substr(xBuffer, 21, 4) ) } ) // Guarda o Header na Array
		ElseIf ( Substr(xBuffer,8,1) == "5" )
			ntrlt++
			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lTrailler
				xBuffer := GP700ALT("T", xBuffer)
			EndIf
			aAdd( aTRLt ,{xBuffer, Substr(xBuffer,4,4), ntrlt, 0, 0, 0, 0}) // Guarda o Trailler de Lote
		ElseIf ( Substr(xBuffer,8,1) == "9" )
			//Se o Header do arquivo padrao sera alterado conforme o arquivo de layout
			If lTrailler
				xBuffer := GP700ALT("T", xBuffer)
			EndIf
			aAdd( aTRArq, {xBuffer,Substr(xBuffer,4,4), ncont } ) // Guarda o Trailler de Arquivo
		Endif
	Endif

	// Interrompe processamento se GP700ALT() modificou esta VAR para .F. indicando erro na formula do arquivo
	If ! lExeFormOk
		Exit
	EndIf

	nLidos += nTamLinha + 1
EndDO

// Interrompe processamento se GP700ALT() modificou esta VAR para .F. indicando erro na formula do arquivo
If ! lExeFormOk
	Return
EndIf

If len(aCols) = 0
	Alert(oEmToAnsi(STR0121))
	Return
Endif

nMaxLin := nCont

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 220 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

If nOpcx == 4  // IMPORTAR ARQUIVO
	aAdd( aHead , "" )
	For nX := 1 to nUsado
		aAdd( aHead , Capital(aHeader[nX,1]))
	Next nX
	nUsado := len(aHead)

	For nX := 1 to len(aCols)
		aAdd( aList , Array(nUsado+2) )
		aList[nX,1] := .T.
		For nY := 1 to nUsado
			aList[nX,nY+1] := aCols[nX,nY]
		Next nY
	Next nX

Elseif nOpcx == 5 // GERAR REMESSA
	aAdd( aHead , {   ""        , ;	// TITULO
					  "campo01" , ;		// CAMPO
					  "!@BMP"   , ;		// PICTURE
					  1         , ;		// TAMANHO
					  0         , ; 	// DECIMAL
					  ""        , ;		// VALID
					  cUsado    , ;		// USADO
					  "C"       , ;		// TIPO
					  ""        , ;		// F3
					  "" } )

	For nX := 1 to nUsado
		aAdd( aHead , { aHeader[nX,1] , aHeader[nX,2] , aHeader[nX,3] , aHeader[nX,4] , aHeader[nX,5] , ;
						aHeader[nX,6] , aHeader[nX,7] , aHeader[nX,8] , aHeader[nX,9] , aHeader[nX,10]} )
	Next nX

	aHeader := {}
	aHeader := aClone(aHead)
	nUsado  := Len(aHeader)

	nVlConsig := 0
	For nX := 1 to len(aCols)
		If ( At( "." , aCols[nX,nCpVAL] ) > 0 , cFormato := "." , If ( At( "," , aCols[nX,nCpVAL] ) > 0 , cFormato := "," , cFormato := "" ) )

		nValParcela := If ( Empty(cFormato) .and. !Empty(aHeader[nCpVal+1][5]) , Val(aCols[nX,nCpVAL])/100 , Val(aCols[nX,nCpVAL]) ) // obter duas casas decimais caso ainda nao as contenha

		aAdd( aList , Array(nUsado+5) )

		fBuscaSRC( aCols[nX,nCpCPF] , cChave )

		if(Empty(oCor))
			aList[nX,1] := oCinza
		else
			aList[nX,1] := oCor
		endIf
		For nY := 1 to nUsado+1
			aList[nX,nY+1] := aCols[nX,nY]
		Next nY

		aList[nX,nUsado+2] := nValParcela	// Valor da Parcela (sem formatacao)
		aList[nX,nUsado+3] := nValCalc		// Valor Descontado (sem formatacao)
		aList[nX,nUsado+4] := cFilDesc		// Filial do registro utilizado para desconto
		aList[nX,nUsado+5] := cMatDesc		// Matricula do registro utilizado para desconto

		nPosLot := If( nModelo==3, Ascan(aTRLt, {|x| x[2]==aCols[nX,2]} ), 0 )

		If nValCalc > 0
			nQtConsig++
			nVlConsig += nValCalc
			cRepasse := "S" 		// INDICADOR DE REPASSE
			If nPosLot > 0
				aTRLt[nPosLot][4] += nValCalc
				aTRLt[nPosLot][5]++
			EndIf
		else
			cRepasse := "N" 		// INDICADOR DE REPASSE
		Endif

		If nValParcela > nValCalc
			nQtNConsig++
			nVlNConsig += ( nValParcela - nValCalc )

			If nPosLot > 0
				aTRLt[nPosLot][6] += ( nValParcela - nValCalc )
				aTRLt[nPosLot][7]++
			EndIf
		Endif

		// Formatar valor a ser enviado no arquivo
		If Empty(cFormato) .and. !Empty(aHeader[nCpVal+1][5])
			cNovoValor := StrZero ( nValCalc*100 , aHeader[nCpVAL+1][4] )
		Else
			If nValCalc > 0
				cResto	:= AllTrim(Str(Mod(nValCalc,NoRound(nValCalc,0))))
			Else
				cResto	:= "00"
			Endif
			cNovoValor := StrZero ( nValCalc , aHeader[nCpVAL+1][4] - aHeader[nCpVAL+1][5] - 1 ) + cFormato + ;
						  SubStr  ( cResto   , At(cFormato,cResto)+1 )
		Endif

		// Cria a informacao de REPASSE S/N somente se a expressao REPAS foi identificada
		// dentro do titulo do xBuffer conforme Layout de cada banco.
		If nCpoRepass <> 0
			aList[ nX, nCpoRepass + 1 ] := cRepasse
		EndIf

		aList[nX,nCpVAL+1]	:= cNovoValor
	Next nX

	aCols := {}
	aCols := aClone(aList)
Endif

nPos := Ascan(aModelo, {|x| x[1] == Str(nModelo,1) })

DEFINE FONT oBold  NAME "Arial" SIZE 0, -11 BOLD
DEFINE FONT oBold1 NAME "Arial" SIZE 0, -11

aSizes := {(aAdvSize[3]- (aAdvSize[3] * 0.15)),(aAdvSize[5]- (aAdvSize[5] * 0.06))}

DEFINE MSDIALOG oDlgMain TITLE oEmToAnsi(STR0024) FROM 0,0 TO aSizes[1],aSizes[2] OF oMainWnd PIXEL
	nObjX := aObjSize[1,1]+05

	@ nObjX, aObjSize[1,2]+0.5 GROUP oGroup1 TO ( aObjSize[1,3]), ( ( aObjSize[1,4]/100*7 ) ) LABEL OemToAnsi(STR0009) OF oDlgMain PIXEL			// "Data Trans."
	oGroup1:oFont:= oBold1

	@ nObjX , ( aObjSize[1,4]/100*07 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*17 )	LABEL OemToAnsi(STR0015) OF oDlgMain PIXEL			// "Layout"
	oGroup1:oFont:= oBold1

	If nOpcx == 4
		@ nObjX , ( aObjSize[1,4]/100*17 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*56 )	LABEL OemToAnsi(STR0007) OF oDlgMain PIXEL			// "Arq. Config."
		oGroup1:oFont:= oBold1
		@ nObjX , ( aObjSize[1,4]/100*56 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*94 )	LABEL OemToAnsi(STR0008) OF oDlgMain PIXEL			// "Arq. Dados"
		oGroup1:oFont:= oBold1
	Elseif nOpcx == 5
		@ nObjX , ( aObjSize[1,4]/100*17 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*45 )	LABEL OemToAnsi(STR0007) OF oDlgMain PIXEL			// "Arq. Config."
		oGroup1:oFont:= oBold1
		@ nObjX , ( aObjSize[1,4]/100*45 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*70 )	LABEL OemToAnsi(STR0008) OF oDlgMain PIXEL			// "Arq. Dados"
		oGroup1:oFont:= oBold1
		@ nObjX , ( aObjSize[1,4]/100*70 ) GROUP oGroup2 TO ( aObjSize[1,3]),( aObjSize[1,4]/100*94 )	LABEL OemToAnsi(STR0016) OF oDlgMain PIXEL			// "Arq. Saida"
		oGroup1:oFont:= oBold1
	Endif

 	nObjX := ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) + 15)

	@ nObjX , ( aObjSize[1,2] + 10 )	SAY Dtoc(date())	SIZE 030,10 OF oDlgMain PIXEL FONT oBold // Data

 	@ nObjX , eVal(bObjY,07)	SAY aModelo[nPos][2]	SIZE ( aObjSize[1,4]/100*15 ),10 OF oDlgMain PIXEL FONT oBold //Layout
	If nOpcx == 4

 		cConfigTxt := FixTxtSize(Upper(AllTrim(cArqConfig)),75)
		@ nObjX , eVal(bObjY,17)	SAY cConfigTxt SIZE ( aObjSize[1,4]/100*55 ),10 OF oDlgMain PIXEL FONT oBold //Arq. Config

		cDadosTxt := FixTxtSize(Upper(AllTrim(cArqDados)), 75 )
	 	@ nObjX , eVal(bObjY,56)	SAY cDadosTxt SIZE ( aObjSize[1,4]/100*85),10 OF oDlgMain PIXEL FONT oBold  //Arq Dados
	Elseif nOpcx == 5
		cConfigTxt := FixTxtSize(Upper(AllTrim(cArqConfig)),50)
		@ nObjX , eVal(bObjY,17)	SAY cConfigTxt SIZE ( aObjSize[1,4]/100*40 ),10 OF oDlgMain PIXEL FONT oBold

	 	cDadosTxt := FixTxtSize(Upper(AllTrim(cArqDados)), 40 )
	 	@ nObjX , eVal(bObjY,46)	SAY cDadosTxt	SIZE ( aObjSize[1,4]/100*70),10 OF oDlgMain PIXEL FONT oBold

		cSaidaTxt := FixTxtSize(Upper(AllTrim(cArqSaida)), 40 )
	 	@ nObjX , eVal(bObjY,70)	SAY cSaidaTxt	SIZE ( aObjSize[1,4]/100*94),10 OF oDlgMain PIXEL FONT oBold
	Endif

	nObjX := ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) + 35)
	If nOpcx == 4	// IMPORTAR ARQUIVO
		@ nObjX , ( aObjSize[2,2] )+5 LISTBOX oLbxArq VAR cLbxArq FIELDS HEADER  "";
		SIZE  (aSizes[2]/2.038), (aSizes[1] * 0.38) ON DBLCLICK (aList:=fMarca(oLbxArq:nAt,aList),oLbxArq:Refresh()) PIXEL

		oLbxArq:SetArray(aList)
		oLbxArq:aHeaders := aHead
		oLbxArq:lHScroll := .T.
		oLbxArq:lVScroll := .T.
		oLbxArq:nFreeze  := 1
		cExibe := "{ || { "
		cExibe += "If( aList[oLbxArq:nAt,1] , oOk , oNo ) , "
		For nX := 1 to nUsado
			cExibe += "aList[oLbxArq:nAt,"+StrZero(nX+1,3)+"]"
			If nX < nUsado
				cExibe += " , "
			Endif
		Next nX
		cExibe += " } }"
		oLbxArq:bLine    := &cExibe
	   	oLbxArq:nAt      := 1
		oLbxArq:nRowPos  := 1
	Else
 		oGet := MsGetDados():New(nObjX,( aObjSize[2,2] )+5,aObjSize[2,3],(aSizes[2]/2.038),1,"gp700LinOk","gp700TudOk",,.F.,,,,nMaxLin)
	Endif

    bSet15	:= {||nOpcA:=1,If(oGet:TudoOk(),oDlgMain:End(),nOpcA:=0)}
    bSet24	:= {||oDlgMain:End()}

ACTIVATE MSDIALOG oDlgMain ON INIT fChoBar700(oDlgMain,bSet15,bSet24,nOpcx) CENTERED

RestArea( aArea )
RestKeys( aSvKeys , .T. )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaLin ºAutor  ³Kelly Soares        º Data ³  15.12.05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Armazena no aCols o conteudo da linha do arquivo           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpm700                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGravaLin(nCont,xBuffer)
Local nX
Local nComeco	:= 1

aAdd( aCOls , Array(nUsado+2) )//1) )
For nX := 1 to nUsado
	aCols[nCont][nX]	:= Substr(xBuffer,nComeco,aHeader[nX][4])
	nComeco 			+= aHeader[nX][4]
Next nX
aCols[nCont][nUsado+1]	:= nCont

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FchoBar700³ Autor ³ KELLY SOARES          ³ Data ³ 11.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a enchoice bar.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FchoBar700(oDlg,bOk,bCancel,nOpcx)
	Local bDetalhes	:= { || fVlrParc( aCols[n,nCpCPF+1] , cChave ) }
	Local aButtons	:= {}

	IF nOpcx == 4
		//Marca
		aAdd( aButtons, {"SDUSETDEL", {|| fSelecionado(.T.)}, OemToAnsi(STR0080), OemToAnsi(STR0082) , {|| .T.}} )
		//Desmarca
		aAdd( aButtons, {"RPMNEW"	, {|| fSelecionado(.F.)}, OemToAnsi(STR0081), OemToAnsi(STR0083) , {|| .T.}} )

		bOk := {||fImpFolha(aList,aHeader)}
	ElseIf nOpcx == 5
		//"Filtrar Repasse"
		aAdd( aButtons, {"SDUSETDEL"	, {|| fFiltraDados(1)}, OemToAnsi(STR0115), OemToAnsi(STR0116) , {|| .T.}} )
		//"Filtrar Nao Repasse"
		aAdd( aButtons, {"SDUSOFTSEEK"	, {|| fFiltraDados(2)}, OemToAnsi(STR0117), OemToAnsi(STR0118) , {|| .T.}} )
		//"Filtrar Valor Descontado Parcialmente"
		aAdd( aButtons, {"SIMULACAO"	, {|| fFiltraDados(3)}, OemToAnsi(STR0123), OemToAnsi(STR0124) , {|| .T.}} )
		//"Mostrar todos"
		aAdd( aButtons, {"SDUPROPR"		, {|| fFiltraDados(4)}, OemToAnsi(STR0119), OemToAnsi(STR0120) , {|| .T.}} )
		//"Detalhes do Lançamento...<F2>"
		aAdd( aButtons, {"MENURUN"		, bDetalhes, OemToAnsi(STR0125), OemToAnsi(STR0126) , {|| .T.}} )
		SetKey (VK_F2,bDetalhes)

		bOk := {||fGeraArq(cArqSaida)}
	Endif

	EnchoiceBar(oDlg,bOk,bCancel,/*lMsgDel*/,aButtons,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/,.T.,.T.)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGetArqDados ³ Autor ³ KELLY SOARES      ³ Data ³ 11.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecionar arquivo de dados.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fGetArqDados(cArq)
Local cType 	:= ""
Local aDir	:= {}
Local nDir	:= 0

cType := STR0077 //## |*.TXT|*.RET|*.REM|*.2RE|*.PAG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comando para selecionar um arquivo.                          ³
//³ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ³
//³            GETF_LOCALHARD - Inclui o Harddisk local.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq 	:= cGetFile(cType, OemToAnsi(STR0078), 0, , .T., GETF_LOCALHARD+GETF_LOCALFLOPPY )  // "Selecione arquivo "
aDir	:= { { cArq } }

For nDir := 1 To Len(aDir)
	cArq := aDir[nDir][1]

	If !Empty(cArq)
		If !File(cArq)
			MsgAlert(oEmToAnsi(STR0079) + cArq)  // "Arquivo nao encontrado "
			Return .F.
		EndIf
	EndIf
Next nDir
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fSelecionado ³ Autor ³ KELLY SOARES      ³ Data ³ 11.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca todos os elementos da listbox.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelecionado(lOpcao)
Local nX

For nX := 1 to len(aList)
	aList[nX,1] := lOpcao
Next nX

oLbxArq:SetArray(aList)
oLbxArq:bLine := &cExibe
oLbxArq:Refresh(.T.)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fMarca   ³ Autor ³ Kelly                 ³ Data ³ 11.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e desmarca itens da ListBox						         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fMarca(nAt,aArray)
aArray[nAt,1]   := If(aArray[nAt,1], .F., .T.)
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpFolha ºAutor  ³Kelly Soares        º Data ³  10.01.06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa os valores da(s) parcela(s) para a folha.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpm700                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fImpFolha(aArray,aCabec)
	Local aArea			:= GetArea()
	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 0
	Local nAux			:= 1
	Local nPos			:= 0
	Local nReg			:= Len(aArray)
	Local nContador		:= 0
	Local nCon			:= 0
	Local nContDoc		:= 0
	Local nNumDoc		:= 0
	Local nValor		:= 0
	Local cFil			:= ""
	Local cMat			:= ""
	Local cCusto		:= ""
	Local cNome			:= ""
	Local cDepto		:= ""
	Local cItem			:= ""
	Local cCLVL			:= ""
	Local cLog			:= ""
	Local cFor			:= ""
	Local cIndCond		:= ""
	Local cSQL			:= ""
	Local aCPF			:= {}
	Local aCPFAux		:= {}
	Local aNaoExiste	:= {}
	Local aImportados	:= {}
	Local aLog			:= {}
	Local aTitle		:= {}
	Local lGerou		:= .F.
	Local lOk			:= .T.
	Local lSeq			:= .F.
	Local lGPM70001		:= ExistBlock("GPM70001")
	// ------- Pergunte -------------

	Local cProcesso		:= ""
	Local cPeriodo		:= ""
	Local cNumPag		:= ""
	Local cRoteiro		:= ""
	Local dDataPag
	Local nDestino		:= 0
	Local nLancamento	:= 0
	Local nTipoVal		:= 0
	Local cSituacoes	:= ""
	Local lItemCLVL		:= SuperGetMv("MV_ITMCLVL ",NIL,"2")  $ "1*3" //variavel que define se os campos "Item Contabil" e Classe de Valor" estão ativos
	Local cRegraPag		:= "1"
	Local cSitfl		:= ""

	// ------------------------------
	Private nQtdeLcto		:= 0
	Private cLctoDiario		:= ""
	Private aNaoImportados	:= {}

	nPos := Ascan( aArray , {|x| x[1] == .T. }  )
	If nPos = 0
		MsgInfo(oEmToAnsi(STR0100))
		Return
	Endif

	If ( nCpCPF = 0 ) .or. ( nCpPAR = 0 ) .or. ( nCpVAL = 0 )
		Alert(oEmToAnsi(STR0105))
		Return
	Endif

	If !MsgYesNo(oEmToAnsi(STR0050),oEmToAnsi(STR0054)) //"Atencao ## Confirma a importacao para a folha?"
		Return
	Endif

	If !Pergunte('GPM700A',.T.)
		Return
	Endif

	cProcesso    := mv_par01
	cPeriodo     := mv_par02
	cNumPag	 	:= mv_par03
	cRoteiro     := mv_par04
	dDataPag	   := mv_par05
	nDestino	   := mv_par06  // 1 = Lanctos Mensais, 2 = Lanctos Futuros
	nLancamento   := mv_par07  // 1 = Substitui, 2 = Adiciona, 3 = Despreza
	cSituacoes	   := mv_par08
	nTipoVal	   := mv_par09  // 1=Parcela, 2=Total
	if!(Empty(MV_PAR10))
		cRegraPag := cValToChar(MV_PAR10) // 1=Folha, 2=Férias
	endIf

	RCH->( DBSELECTAREA('RCH') )
	RCH->( DBSETORDER(1) )
	If RCH->( DBSEEK(xFilial('RCH')+cProcesso+cPeriodo+cNumPag+cRoteiro) ) .Or. ;
	RCH->( DBSEEK(xFilial('RCH')+cProcesso+cPeriodo+cNumPag) )
	If RCH->RCH_PERSEL<>"1"
			Aviso(STR0134,STR0165+Right(cPeriodo,2)+"/"+Left(cPeriodo,4),{'OK'}) //"Alerta"###"A data atual não confere com o Mes/Ano disponível para cálculo ==> XX/XXXX"
		Return
	Else
			dPagto := RCH->RCH_DTPAGO
	Endif
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca o numero do indice na tabela de acordo com a expressao indicada. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIndSRA := RetOrder("SRA","RA_CIC+RA_FILIAL+RA_MAT")

	SRA->( DBSELECTAREA('SRA') )
	SRA->( DBSETORDER(nIndSRA) )

	RGB->( DBSELECTAREA('RGB') )
	RGB->( DBSETORDER(4) )   // FILIAL + MAT + PERIODO + ROTEIRO + NUMPAG + VERBA

	SRK->( DBSELECTAREA('SRK') )
	SRK->( DBSETORDER(4) )   // FILIAL + MAT + VERBA + PERIODO INICIO + NUMPAG

	SRV->( DBSELECTAREA('SRV') )
	SRV->( DBSETORDER(1) )
	SRV->( DBSEEK(xFilial('SRV')+cVerba) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ //Apagar registros dos lancamentos futuros, para tipo de nLancamento == 1 - Substitui  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to nReg
		IF ( !Empty(aArray[nX,nCpCPF+1]) ) .and. ( SRA->( DBSEEK(aArray[nX,nCpCPF+1]) ) )

			aCPF := {}
			While SRA->( !Eof() ) .And. SRA->RA_CIC = aArray[nX,nCpCPF+1]
				if SRA->RA_PROCES == cProcesso
					aAdd(aCPF,{SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,SRA->RA_NOME,SRA->RA_SITFOLH,SRA->RA_DEPTO, SRA->RA_ITEM, SRA->RA_CLVL})
					SRA->( DbSkip() )
				else
					SRA->( DbSkip() )
				endif
			Enddo

			For nZ := 1 to Len(aCPF)
				cFil   := aCPF[nZ,1]
				cMat   := aCPF[nZ,2]
				cCusto := aCPF[nZ,3]
				cNome  := aCPF[nZ,4]
				cDepto := aCPF[nZ,6]
				cItem  := aCPF[nZ,7]
				cCLVL  := aCPF[nZ,8]

				If nDestino == 1	// Lanctos Mensais
					RGB->(DbsetOrder(Retorder("RGB","RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA+RGB_SEQ")))
					If RGB->( DbSeek(cFil+cMat+cVerba+cCusto+cNumPag) )
						If nLancamento == 1  //Substitui
							While RGB->( !Eof() ) .and. ;
								RGB->RGB_FILIAL + RGB->RGB_MAT + RGB->RGB_PD + RGB->RGB_CC + RGB->RGB_SEMANA == cFil + cMat + cVerba + cCusto + cNumPag
							RecLock( "RGB" , .F. , .T. )
							RGB->( DbDelete() )
							RGB->( MsUnlock() )
							dbSkip()
							Enddo
					EndIF
				EndIf

			Else  // Lanctos Futuros
					SRK->(DbsetOrder(Retorder("SRK","RK_FILIAL+RK_MAT+RK_PD+RK_CC")))
					If SRK->( DbSeek(cFil+cMat+cVerba) )
						If nLancamento == 1  //Substitui
							While SRK->( !Eof() ) .and. ;
								SRK->RK_FILIAL + SRK->RK_MAT + SRK->RK_PD == cFil + cMat + cVerba
								RecLock( "SRK" , .F. , .T. )
								SRK->( DbDelete() )
								SRK->( MsUnlock() )
								dbSkip()
							Enddo
						EndIF
					EndIf
				EndIf
			Next nZ
		EndIf
	Next nX


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona os registros, conforme tipo de lacto   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to nReg
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza o funcionario atraves do CPF.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		IF ( !Empty(aArray[nX,nCpCPF+1]) ) .and. ( SRA->( DBSEEK(aArray[nX,nCpCPF+1]) ) )
			aCPF 	 := {}
			aCPFAux := {}
			lGerou  := .F.
			While SRA->( !Eof() ) .And. SRA->RA_CIC = aArray[nX,nCpCPF+1]
				If SRA->RA_CATFUNC == "A"
					aAdd(aCPFAux,{SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,SRA->RA_NOME,SRA->RA_SITFOLH,SRA->RA_DEPTO,SRA->RA_ITEM,SRA->RA_CLVL})
				Else
					if SRA->RA_PROCES == cProcesso
						aAdd(aCPF,{SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,SRA->RA_NOME,SRA->RA_SITFOLH,SRA->RA_DEPTO,SRA->RA_ITEM,SRA->RA_CLVL})
					endif
				EndIf
				SRA->( DbSkip() )
			Enddo
			//Adiciona os autonomos por ultimo para priorizar as validacoes/desconto da matricula do funcionario
			For nY := 1 to Len(aCPFAux)
				aAdd(aCPF, aCPFAux[nY])
			Next
			For nY := 1 to Len(aCPF)
				cFil   := aCPF[nY,1]
				cMat   := aCPF[nY,2]
				cCusto := aCPF[nY,3]
				cNome  := aCPF[nY,4]
				cDepto := aCPF[nY,6]
				cItem  := aCPF[nY,7]
				cCLVL  := aCPF[nY,8]
				cSitfl := aCPF[nY,5]

				If !aCPF[nY,5] $ cSituacoes
					aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0107) + aCPF[nY,5] } )
					Loop
				Endif

				If aArray[nX,1] .And. !lGerou // Se estiver marcado...
					If SRV->( MsSeek( xFilial("SRV",cFil) + cVerba ) )
						nQtdeLcto   := Val( SRV->RV_QTDLANC )
						cLctoDiario := SRV->RV_LCTODIA
					Else
						aAdd( aNaoImportados , { cFil , cMat , cNome , OemToAnsi(STR0173) + cVerba } ) //Verba não cadastrada: 
						Loop
					EndIf

					lGerou := .T.
					If nDestino == 1	// Lanctos Mensais
						lOk := .T.
						RGB->(DbsetOrder(Retorder("RGB","RGB_FILIAL+RGB_MAT+RGB_PERIOD+RGB_ROTEIR+RGB_SEMANA+RGB_PD")))
						If RGB->( DbSeek(cFil+cMat+cPeriodo+cRoteiro+cNumPag+cVerba) )
							If nLancamento == 1 .or. nLancamento == 2  //Substitui ou Adiciona
								If nQtdeLcto > 0
									nContador := 1
									While RGB->( !Eof() ) .and. ;
									RGB->RGB_FILIAL + RGB->RGB_MAT + RGB->RGB_PD + RGB->RGB_CC + RGB->RGB_SEMANA == cFil + cMat + cVerba + cCusto + cNumPag
										RGB->( RecLock('RGB',.F.) )
										RGB->RGB_SEQ := Str(nContador,1)
										RGB->( MsUnlock() )
										RGB->( DBSKIP() )
										nContador ++
									Enddo
									If nContador <= nQtdeLcto
										lSeq := .T.
										RGB->( RecLock('RGB',.T.) )
									Else
										aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0108) + Str(nQtdeLcto,1) } )
										lOk := .F.
									Endif
								Else
									aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0109) + " " + oEmToAnsi(STR0110) + ;
																				Str(nQtdeLcto,1) + " / " + oEmToAnsi(STR0111) + cLctoDiario } )
									lOk := .F.
								Endif
							Elseif nLancamento == 3  //Despreza
								aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0112) } )
								lOk := .F.
							Endif

						Else
							RGB->( RecLock('RGB',.T.) )
						Endif

						If lOk
							RGB->RGB_FILIAL	:= cFil
							RGB->RGB_MAT		:= cMat
							RGB->RGB_PD		:= cVerba
							RGB->RGB_TIPO1	:= 'V' // Valor

							RGB->RGB_VALOR	:= If ( At(".",aArray[nX,nCpVAL+1]) == 0 .AND. At(",",aArray[nX,nCpVAL+1]) == 0 .AND. !Empty(aCabec[nCpVal][5]) , ;
													Val(aArray[nX,nCpVAL+1])/100 , ;
													Val(aArray[nX,nCpVAL+1]) ;
												) // obter duas casas decimais caso ainda nao as contenha

							RGB->RGB_DTREF	:= dDataPag
							RGB->RGB_SEMANA  := cNumPag
							RGB->RGB_CC	:= cCusto
							RGB->RGB_PARCEL := Val(aArray[nX,nCpPAR+1])
							RGB->RGB_TIPO2 	:= 'G'
							RGB->RGB_PROCES 	:= cProcesso
							RGB->RGB_PERIOD := cPeriodo
							RGB->RGB_ROTEIR 	:= cRoteiro
							RGB->RGB_DEPTO 	:= cDepto
							If (lSeq , RGB->RGB_SEQ := Str(nContador,1) , )

							If ( lItemCLVL .AND. (!Empty(aCpf[nY , 7]) .OR. !Empty(aCpf[nY , 8])) )
								fGravaItem("RGB" , aCpf[nY] , 7)
							EndIf

							RGB->( MsUnlock() )

							aAdd( aImportados , { cFil , cMat , cNome , RGB->RGB_PARCEL , RGB->RGB_VALOR } )

						Endif

					Else	// Lanctos Futuros
						nContDoc  	:=  0
						lOk 		:= .T.
						SRK->(DbsetOrder(Retorder("SRK","RK_FILIAL+RK_MAT+RK_PD+RK_CC")))
						If SRK->( DbSeek(cFil+cMat+cVerba) )
							If nLancamento == 1 .or. nLancamento == 2 //Substitui ou Adiciona
								If nQtdeLcto > 0
									nContador := 1
									While SRK->( !Eof() ) .and. ;
										SRK->RK_FILIAL + SRK->RK_MAT + SRK->RK_PD == cFil + cMat + cVerba
										nContDoc:=val(SRK->RK_DOCUMEN)
										nContador ++
										SRK->( DBSKIP() )
									Enddo
									If nContador <= nQtdeLcto
										SRK->( RecLock('SRK',.T.) )
									Else
										aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0108) + Str(nQtdeLcto,1) } )
										lOk := .F.
									Endif
								Else
									aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0109) + " " + oEmToAnsi(STR0110) + Str(nQtdeLcto,1) } )
									lOk := .F.
								Endif

							Elseif nLancamento == 3  //Despreza
								aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0112) } )
								lOk := .F.
							Endif

						Else
							SRK->( RecLock('SRK',.T.) )
						Endif

						If lOk
							SRK->RK_FILIAL	:= cFil
							SRK->RK_MAT		:= cMat
							SRK->RK_PD		:= cVerba

							nValor := If ( At(".",aArray[nX,nCpVAL+1]) == 0 .AND. At(",",aArray[nX,nCpVAL+1]) == 0 .AND. !Empty(aCabec[nCpVal][5]) , ;
										Val(aArray[nX,nCpVAL+1])/100 , ;
										Val(aArray[nX,nCpVAL+1]) ;
										) // obter duas casas decimais caso ainda nao as contenha

							SRK->RK_VALORTO	:= If( nTipoVal == 1 , nValor * Val(aArray[nX,nCpPAR+1]) , nValor )
							SRK->RK_PARCELA := Val(aArray[nX,nCpPAR+1])
							SRK->RK_VALORPA	:= SRK->RK_VALORTO / SRK->RK_PARCELA
							SRK->RK_DTVENC 	:= dDataPag
							SRK->RK_DTMOVI 	:= Date()
							SRK->RK_DOCUMEN := Strzero(nContDoc+1,6)
							SRK->RK_CC		:= cCusto
							SRK->RK_PERINI  := cPeriodo
							SRK->RK_NUMPAGO := cNumPag
							SRK->RK_STATUS  := If( (Empty(cSitfl)).OR. (cSitfl$"F/A"), "2", "4")
							SRK->RK_PROCES  := cProcesso
							SRK->RK_REGRADS := cRegraPag
							//-- Tratamento para desconto do emprestimo consignado
							If cPaisLoc == "BRA"
								SRK->RK_EMPCONS	:= "1"
							EndIf
							If ( lItemCLVL .AND. (!Empty(aCpf[nY , 7]) .OR. !Empty(aCpf[nY , 8])) )
								fGravaItem("SRK" , aCpf[nY] , 7)
								/*Ao preencher o array (aCpf) a posicao do item de classe corresponde a 7 posicao.*/
							EndIf

							SRK->( MsUnlock() )

							aAdd( aImportados , { cFil , cMat , cNome , SRK->RK_PARCELA , SRK->RK_VALORTO/SRK->RK_PARCELA , SRK->RK_VALORTO } )

						Endif

					Endif

					If lGPM70001
						ExecBlock("GPM70001",.F.,.F.,{cFil,cMat,cVerba,nDestino})
					Endif

				Else // Se nao foi marcado

					aAdd( aNaoImportados , { cFil , cMat , cNome , oEmToAnsi(STR0114) } )

				Endif

			Next nY

		Else

			aAdd( aNaoExiste , { oEmToAnsi(STR0102) + StrZero(nX,5) , aArray[nX,nCpCPF+1] } )

		Endif

	Next nX

	// Ordena Cpf's
	aSort( aNaoExiste     ,,, {|x,y| x[1] < y[1] } )
	// Ordena funcionarios por Filial e Chapa
	aSort( aImportados    ,,, {|x,y| x[1] + x[2] < y[1] + y[2] } )
	aSort( aNaoImportados ,,, {|x,y| x[1] + x[2] < y[1] + y[2] } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta LOG com resultado da importacao.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aTitle , oEmToAnsi(STR0092) )
	aAdd( aLog , {} )
	aAdd( aLog[nAux] , oEmToAnsi(STR0093) + Space(15-len(STR0093)) + ": " + If(nDestino==1,oEmToAnsi(STR0094),oEmToAnsi(STR0095)) )
	aAdd( aLog[nAux] , oEmToAnsi(STR0106) + Space(15-len(STR0106)) + ": " + cVerba )
	aAdd( aLog[nAux] , oEmToAnsi(STR0096) + Space(15-len(STR0096)) + ": " + cProcesso )
	aAdd( aLog[nAux] , oEmToAnsi(STR0097) + Space(15-len(STR0097)) + ": " + Right(cPeriodo,2) + "/" + Left(cPeriodo,4) )
	aAdd( aLog[nAux] , oEmToAnsi(STR0098) + Space(15-len(STR0098)) + ": " + cNumPag )
	aAdd( aLog[nAux] , oEmToAnsi(STR0099) + Space(15-len(STR0099)) + ": " + cRoteiro )
	If nDestino == 2
		aAdd( aLog[nAux] , oEmToAnsi(STR0103) + Space(15-len(STR0103)) + ": " + Right(DTOS(dDataPag),2)+"/"+SubStr(DTOS(dDataPag),5,2)+"/"+Left(DTOS(dDataPag),4) )
	Endif

	If len(aNaoExiste) > 0
		nAux ++
		aAdd( aLog , {} )
		aAdd( aTitle , oEmToAnsi(STR0091) )
		For nX := 1 to len(aNaoExiste)
			If Len(AllTrim(aNaoExiste[nX,2])) = 0
				aAdd( aLog[nAux] , aNaoExiste[nX,1] + ":" + STR0101 )
			Else
				aAdd( aLog[nAux] , aNaoExiste[nX,1] + ":" + aNaoExiste[nX,2] )
			Endif
		Next nX
	Endif

	If len(aImportados) > 0
		nAux ++
		aAdd( aLog , {} )
		aAdd( aTitle , oEmToAnsi(STR0086) )
		aAdd( aLog[nAux] , If( nDestino == 1 , oEmToAnsi(STR0087) , oEmToAnsi(STR0104) ) ) //Fil.       Mat.   Nome...
		aAdd( aLog[nAux] , replicate("-",130) )
		For nX := 1 to len(aImportados)
			If nDestino == 1
				aAdd( aLog[nAux] , aImportados[nX,1] + Space(3) + aImportados[nX,2] + Space(2) + aImportados[nX,3] + Space(5) + StrZero(aImportados[nX,4],3) + Space(10) + Str(aImportados[nX,5],12,2) )
			Else
				aAdd( aLog[nAux] , aImportados[nX,1] + Space(3) + aImportados[nX,2] + Space(2) + aImportados[nX,3] + Space(5) + StrZero(aImportados[nX,4],3) + Space(10) + Str(aImportados[nX,5],12,2) + Space(8) + Str(aImportados[nX,6],12,2) )
			Endif
		Next nX
	Endif

	If len(aNaoImportados) > 0
		nAux ++
		aAdd( aLog , {} )
		aAdd( aTitle , oEmToAnsi(STR0088) )
		aAdd( aLog[nAux] , oEmToAnsi(STR0089) )
		aAdd( aLog[nAux] , replicate("-",130) )
		For nX := 1 to len(aNaoImportados)
			aAdd( aLog[nAux] , aNaoImportados[nX,1] + Space(3) + aNaoImportados[nX,2] + Space(2) + aNaoImportados[nX,3] + Space(5) + aNaoImportados[nX,4] )
		Next nX
	Endif

	fMakeLog(aLog,aTitle,,,"GPM700"+DTOS(dDataBase),STR0090,"M","P",,.F.)//  "Log de Ocorrencias - Consignacao em Folha de Pagamento"

	RestArea(aArea)

	RGB->( DBCLOSEAREA() )
	SRK->( DBCLOSEAREA() )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraArq  ºAutor  ³Kelly Soares        º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o arquivo de remessa para o banco, com o resultado     º±±
±±º          ³do processamento.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³gpem700                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fGeraArq(cArquivo)
If nTipoLay == 3
	fGeraMod3(cArquivo)
Else
	fGeraOut(cArquivo)
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp700LinOk³ Autor ³Kelly Soares           ³ Data ³ 03/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³gpem700                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp700LinOk()
Local lRet := .T.
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp700TudOk³ Autor ³Kelly Soares           ³ Data ³ 03/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³gpem700                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp700TudOk()
	Local lRet := .T.
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBuscaSRC ³ Autor ³Kelly Soares           ³ Data ³ 13/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca vinculo do funcionario com SRC.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³gpem700                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBuscaSRC(cCpf,cChave)
Local nX
Local aArea := GetArea()
Local aCPF  := {}
Local nQtdLacto

nValCalc  := 0
nValNAplic	:= 0
cFilDesc	:= ""
cMatDesc	:= ""

nIndSRA	:= RetOrder("SRA","RA_CIC+RA_FILIAL+RA_MAT")
SRV->( DBSELECTAREA('SRV') )
SRV->( DBSETORDER(1) )
SRV->( DBSEEK(xFilial('SRV')+left(cVerba,3) ))
nQtdLacto := VAL(SRV->RV_QTDLANC)   // QTDE O CODIGO PODE SER LANCADO

SRA->( DBSELECTAREA('SRA') )
SRA->( DBSETORDER(nIndSRA) )

SRC->( DBSELECTAREA('SRC') )
SRC->( DbSetOrder(4) )

If SRA->( DBSEEK(cCpf) )
	aCPF := {}
	While SRA->( !Eof() ) .And. SRA->RA_CIC = cCpf
		aAdd(aCPF,{SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,SRA->RA_NOME})
		SRA->( DbSkip() )
	Enddo

	For nX := 1 to Len(aCPF)
		If SRC->( DbSeek(aCPF[nX,1]+aCPF[nX,2]+cChave) )
			While !( SRC->( Eof() ) ) .and. ;
				   ( SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PERIODO+SRC->RC_ROTEIR+SRC->RC_SEMANA+SRC->RC_PD == aCPF[nX,1]+aCPF[nX,2]+cChave )
				If !nQtdLacto > 1 				   // SE A QTD PERMITIDA DE LACTO = 1 OU 0
	 				nValCalc += SRC->RC_VALOR
					nValNAplic	+= SRC->RC_VNAOAPL
						If Empty(cMatDesc)
							cFilDesc := aCPF[nX,1]
							cMatDesc := aCPF[nX,2]
						Endif
				Else
					If SRC->RC_VALOR = nValParcela     // VLR DO LACTO =  VLR PARCELA DA REMESSA
						nValCalc := SRC->RC_VALOR
							If Empty(cMatDesc)
								cFilDesc := aCPF[nX,1]
								cMatDesc := aCPF[nX,2]
							Endif
					else
						If nConsVlr == 2
							If SRC->RC_VALOR > nValParcela .and. SRC->RC_TIPO2 # 'I'   // VLR DO LACTO >  VLR PARCELA DA REMESSA E VERBA NAO FOR INFORMADA
								If !MsgYesNo(oEmToAnsi(STR0159)+ "  " + oEmToAnsi(STR0160)+ "  " + SRC->RC_FILIAL+ " - " + SRC->RC_MAT+ " - " + AllTrim(Upper(aCPF[nX,4])) + " - " + oEmToAnsi(STR0161)+ "  " + Str(SRC->RC_VALOR,10,2)+ "  " + oEmToAnsi(STR0162)+ "  " + str(nValParcela,10,2)) //"Atencao ## Confirma geracao pelo valor da parcela?"
									oCor := oVermelho
									Return
								EndIf
									nValCalc := nValParcela
									If Empty(cMatDesc)
										cFilDesc := aCPF[nX,1]
										cMatDesc := aCPF[nX,2]
									Endif
							EndIf
						EndIf
					EndiF
				Endif
				SRC->( DbSkip() )

			Enddo

		Endif

		If Empty(cMatDesc)
			oCor := oVermelho
		ElseIf nValCalc < nValParcela
			oCor := oAzul
		Else
			oCor := oVerde
		Endif

	Next nX

Else
	oCor := oVermelho
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fFiltraDados³ Autor ³Kelly Soares        ³ Data ³ 13/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra o browse de acordo com a opcao desejada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 = Repasse, 2 = Nao Repasse, 3 = Vlr. Parcial, 4 = Todos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³gpem700                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fFiltraDados(nOpcao,lSoFiltra)
Local nX
Local lCondicao
Local nOrdem := nUsado + 1

Default lSoFiltra := .F.

If !lSoFiltra
	fJuntaTudo()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o filtro                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to len(aColsTudo)
	Do Case
		Case nOpcao == 1
			lCondicao := ( aColsTudo[nX,1] = oVerde )
		Case nOpcao == 2
			lCondicao := ( aColsTudo[nX,1] = oVermelho )
		Case nOpcao == 3
			lCondicao := ( aColsTudo[nX,1] = oAzul )
		Case nOpcao == 4
			lCondicao := .T.
	EndCase

	aAdd( If ( lCondicao , aCols , aColsAux ) , aColsTudo[nX] )
Next nX

	aSort( aCols ,,, {|x,y| x[nOrdem] < y[nOrdem] } )

oGet:Goto(1)
oGet:oBrowse:Refresh(.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fJuntaTudo  ³ Autor ³Kelly Soares        ³ Data ³ 16/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Unifica as arrays                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpem700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fJuntaTudo()
Local nX
Local nOrdem := nUsado + 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Unifica as arrays                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsTudo := aClone(aCols)
If len(aColsAux) > 0
	For nX := 1 to len(aColsAux)
		aAdd( aColsTudo , aColsAux[nX] )
	Next nX
Endif
aSort( aColsTudo ,,, {|x,y| x[nOrdem] < y[nOrdem] } )
aCols	 := {}
aColsAux := {}
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fVlrParc    ³ Autor ³Kelly Soares        ³ Data ³ 17/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra os detalhes dos valores descontados parcialmente.   ³±±
±±³          ³ Acionada com a tecla de atalho F2.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpem700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fVlrParc(cCpf,cChave)

Local aArea := GetArea()

Local oDlg
Local oMain
Local oGroup1
Local oGroup2
Local oGroup3
Local oFont1
Local oFont2a
Local oFont2b
Local oFont3

Local cFil  	:= Replicate('0',FWGETTAMFILIAL)
Local cMat  	:= '000000'
Local cNome		:= oEmToAnsi(STR0133)
Local nPendente := Max(aCols[n,nUsado+2]-aCols[n,nUsado+3],0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

if(Len(aCols) == 0)
	Return
endIf

nIndSRA := RetOrder("SRA","RA_CIC+RA_FILIAL+RA_MAT")

SRA->( DbSelectArea('SRA') )
SRA->( DbSetOrder(nIndSRA) )
If SRA->( DBSEEK(cCpf) )
	While SRA->( !Eof() ) .And. SRA->RA_CIC = cCpf
		If SRA->RA_FILIAL+SRA->RA_MAT = aCols[n,nUsado+4]+aCols[n,nUsado+5]
			cFil  := SRA->RA_FILIAL
			cMat  := SRA->RA_MAT
			cNome := SRA->RA_NOME
		Endif
		SRA->( DbSkip()	)
	Enddo
Endif

DEFINE FONT oFont1     NAME "Arial"    		SIZE 0,-11 BOLD
DEFINE FONT oFont2a    NAME "Arial"    		SIZE 0,-12
DEFINE FONT oFont2b    NAME "Courier New"   SIZE 0,-13 BOLD
DEFINE FONT oFont3     NAME "Arial"    		SIZE 0,-13 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as Dimensoes dos Objetos         					         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*45), (((aObjSize[1,4])/100)*58) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlg TITLE STR0125 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMain PIXEL

	// FUNCIONARIO
	@aGdCoord[1],aGdCoord[2] GROUP oGroup1 TO (((aObjSize[1,3])/100)*15),aGdCoord[4] PROMPT OemToAnsi(STR0127) OF oDlg PIXEL
	oGroup1:oFont := oFont1
	@(((aObjSize[1,3])/100)*9),aGdCoord[2]+10  Say cFil+" / "+cMat+" - "+cNome		PIXEL FONT oFont3 COLOR CLR_BLUE

	// PARCELA
	@(((aObjSize[1,3])/100)*20),aGdCoord[2] GROUP oGroup2 TO aGdCoord[3],(((aObjSize[1,4])/100)*22) PROMPT OemToAnsi(STR0085) OF oDlg PIXEL
	oGroup2:oFont := oFont1

	@(((aObjSize[1,3])/100)*28),aGdCoord[2]+5   Say oEmToAnsi(STR0128)	PIXEL FONT oFont2a COLOR CLR_BLUE 	// Numero
	@(((aObjSize[1,3])/100)*28),aGdCoord[2]+35  Say aCols[n,nCpPAR+1]		PIXEL FONT oFont2b COLOR CLR_BLUE

	@(((aObjSize[1,3])/100)*35),aGdCoord[2]+5   Say OemToAnsi(STR0129)	PIXEL FONT oFont2a COLOR CLR_BLUE	// Valor
	@(((aObjSize[1,3])/100)*35),aGdCoord[2]+35  Say aCols[n,nUsado+2] 	PIXEL FONT oFont2b COLOR CLR_BLUE PICTURE '!@E 999,999.99'

	// FOLHA
	@(((aObjSize[1,3])/100)*20),(((aObjSize[1,4])/100)*24) GROUP oGroup3 TO aGdCoord[3],aGdCoord[4] 		PROMPT OemToAnsi(STR0130) OF oDlg PIXEL
	oGroup3:oFont := oFont1

	@(((aObjSize[1,3])/100)*28),(((aObjSize[1,4])/100)*26)  Say oEmToAnsi(STR0131)	   	PIXEL FONT oFont2a COLOR CLR_BLUE   // Descontado
	@(((aObjSize[1,3])/100)*28),(((aObjSize[1,4])/100)*38)  Say aCols[n,nUsado+3]		PIXEL FONT oFont2b COLOR CLR_BLUE PICTURE '!@E 999,999.99'

	@(((aObjSize[1,3])/100)*35),(((aObjSize[1,4])/100)*26)  Say OemToAnsi(STR0132)		PIXEL FONT oFont2a COLOR CLR_BLUE  // Pendente
	@(((aObjSize[1,3])/100)*35),(((aObjSize[1,4])/100)*38)  Say nPendente				PIXEL FONT oFont2b COLOR CLR_BLUE PICTURE '!@E 999,999.99'

	@(((aObjSize[1,3])/100)*50),(aGdCoord[4]-aGdCoord[1])-40  BUTTON OemToAnsi(STR0042) 	SIZE 040,012 ACTION ( oDlg:End() ) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MyAppend ºAutor  ³Microsiga           º Data ³  12-05-02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MyAppend(cAlias,cFile)
Local aStru, ni, uValue, nTam

DbUseArea(.T.,cRDD,cFile,"XXX",.T.,.F.)
DbGotop()
aStru := DbStruct()
While !XXX->(Eof())
	RecLock(cAlias,.t.)
	For ni := 1 to Len(aStru)
	uValue := XXX->(FieldGet(ni))
	IF aStru[ni,2] == "N"
		ntam := aStru[ni,3] - IIF(aStru[ni,4] > 0,aStru[ni,4]+1,0)
		IF uValue > ((10 ** nTam) - (1/(10**aStru[ni,4])) )
			uValue := 0
		Endif
	Endif
	(cAlias)->(FieldPut(FieldPos(aStru[ni,1]),uValue))
	Next
	(cAlias)->(MsUnlock())
	XXX->(dbSkip())
End
DbSelectArea("XXX")
DbCloseArea()
DbSelectArea(cAlias)
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GP700ALT    ³ Autor ³Marcelo Silveira    ³ Data ³ 23/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera a linha do arquivo conforme na posicao e conteudo   ³±±
±±³          ³ definidos no arquivo de layout.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipo = H, D ou T (Header, Detalhe ou Trailler)            ³±±
±±³          ³ cLine = Linha que sera alterada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpem700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GP700ALT( cTipo, cLine )
Local i         := 0
Local nPos      := 0
Local nPosAnt   := 0
Local nPosIni   := 0
Local nCount    := 0
Local cNewLine  := cLine
Local nTamLine  := Len( cLine )
Local lConteudo := .T.

Private xConteudo

For i := 1 To Len( aArqConfig )
	nPos := aScan( aArqConfig, {|x| x[1] == cTipo }, nCount+1 )
	If nPos > 0 .And. nPos # nPosAnt

		// Interrompe processamento caso a formula do arquivo nao possa ser executada corretamente
		// Se utilizarem a funcao GP700ALT sem conteudo, altera para TEXTO = VAZIO para forcar erro e avisar o usuario
		If Empty( aArqConfig[nPos][4] )
			aArqConfig[nPos][4] := 'VAZIO'
		EndIf
		lExeFormOk	:= CheckExecForm( aArqConfig[nPos][4], .t. )

		IF lExeFormOk
			lConteudo	:= fa150Orig( aArqConfig[nPos][4] )
			If lConteudo
				nPosIni := aArqConfig[nPos][2]
				If nPosIni > 1
					cNewLine := SubStr( cNewLine, 1, nPosIni-1 )
					If ValType( xConteudo ) == "N"
						cNewLine += Alltrim( str( xConteudo ) ) + SubStr( cLine, aArqConfig[nPos][3]+1, nTamLine )
					Else
						cNewLine += xConteudo + SubStr( cLine, aArqConfig[nPos][3]+1, nTamLine )
					EndIf
					nPosAnt  := nPos
				Else
					If ValType( xConteudo ) == "N"
						cNewLine := Alltrim( str( xConteudo ) ) + SubStr( cLine, aArqConfig[nPos][3]+1, nTamLine )
					Else
						cNewLine := xConteudo + SubStr( cLine, aArqConfig[nPos][3]+1, nTamLine )
					EndIf
					nPosAnt  := nPos
				EndIf
			EndIf
		Else
			Exit
		EndIf
	Else
		Exit
	EndIf
	nCount  := nPos
Next

Return( cNewLine )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³18/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM700                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

Local aRotina :=   {  { STR0031   , 'fManutTRB' , 0 , 3 } ,;  	//'Incluir'
					  { STR0032   , 'fManutTRB' , 0 , 4 } ,;   	//'Alterar'
     				  { STR0033   , 'fExcTRB'   , 0 , 4 } ,;  	//'Excluir'
     				  { STR0059   , 'fChamaProc', 0 , 6 } ,;  	//'Importar Dados'
     				  { STR0060   , 'fChamaProc', 0 , 7 } }  	//'Gerar Remessa'
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraOut  ºAutor  ³Kelly Soares        º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o arquivo de remessa para o banco, com o resultado     º±±
±±º          ³do processamento.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³gpem700                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fGeraOut(cArquivo)
Local nX,nY
Local nHdlSaida
Local nCabec 	    := len(aHDArq)
Local nRodape	    := len(aTRArq)
Local nLInha     := 0
Local cLinha	    := ""
Local cConteudo  := ""
Local cNovoValor := ""
Local cParam     := (SuperGetMv("MV_ATCNAB",NIL,.T.) == .T. )

If !MsgYesNo( STR0122 ) //"Confirma a geracao do arquivo remessa ?"
	Return
Endif

If File(cArquivo)
	fErase(cArquivo) // Deleta o arquivo, caso ele ja exista
Endif
nHdlSaida := MSFCREATE(cArquivo,FC_NORMAL)
If nHdlSaida == -1   .or. fError() # 0
	Help(" ",1,"SAVECONS")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o header             	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nCabec
	cConteudo := aHdArq[nX]
	// Atualiza o campo "Codigo Remessa/Retorno" de acordo com pergunte
	If ( nCpCOD > 0 ) .and. ( nX = nOrdCOD ) .and. !Empty(cPergRem)
		cConteudo := SubStr(aHdArq[nX],1,nCpCOD-1) + SubStr(cPergRem,1,nTamCOD) + SubStr(aHdArq[nX],nCpCOD+1)
	Endif
	// Atualiza o campo "Tipo de Pagto" de acordo com pergunte
	If ( nCpPAG > 0 ) .and. ( nX = nOrdPAG ) .and. !Empty(cPergPag)
		cConteudo := SubStr(cConteudo,1,nCpPAG-1) + SubStr(cPergPag,1,nTamPAG) + SubStr(cConteudo,nCpPAG+2)
	Endif
	fWrite( nHdlSaida , cConteudo )
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o detalhe            	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fJuntaTudo()
For nX := 1 to len(aColsTudo)
	For nY := 2 to nUsado
		cLinha += aColsTudo[nX][nY]
	Next nY
	cLinha += Chr(13) + Chr(10)
	fWrite( nHdlSaida , cLinha )
	cLinha := ""
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o trailler           	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nRodape
	cConteudo := aTRArq[nX]
	nLinha    := Len(cConteudo) - 2 //Tamanho da linha sem o retorno

    If  !SubStr(cConteudo,4,4) == "9999"  // atualizar somente quando NAO for registro trailer de arquivo

		IF cParam == .T.
	       	// QTDE DE PARCELAS CONSIGNADAS
			cConteudo := SubStr(cConteudo,1,nCpQTD-1) + StrZero(nQtConsig,nTamQTD) + SubStr(cConteudo,nCpQTD+nTamQTD)
			// QTDE DE PARCELAS NAO CONSIGNADAS
			cConteudo := SubStr(cConteudo,1,nCpQTDN-1) + StrZero(nQtNConsig,nTamQTDN) + SubStr(cConteudo,nCpQTDN+nTamQTDN)
			// VALOR TOTAL DE PARCELAS CONSIGNADAS
			If nDecVLR > 0
				If Empty(cFormato)
					cNovoValor := StrZero ( nVlConsig*100 , nTamVLR )
				Else
					cResto := If(nVlConsig > 0,StrZero(Mod(nVlConsig,NoRound(nVlConsig,0)),4,2),"00")
					cNovoValor := StrZero ( Int(nVlConsig) , nTamVLR - nDecVLR - 1 ) + cFormato + ;
							  	  SubStr  ( cResto , At(cFormato,cResto)+1 )
				Endif
			Else
				cNovoValor := StrZero ( Int(nVlConsig*100) , nTamVLR )


			Endif

			cConteudo	:= SubStr(cConteudo,1,nCpVLR-1) + cNovoValor + SubStr(cConteudo,nCpVLR+nTamVLR)


			// VALOR TOTAL DE PARCELAS NAO CONSIGNADAS
			If nDecVLRN > 0
				If Empty(cFormato)
					cNovoValor := StrZero ( nVlNConsig*100 , nTamVLRN )
				Else
					cResto := If(nVlNConsig > 0,StrZero(Mod(nVlNConsig,NoRound(nVlNConsig,0)),4,2),"00")
					cNovoValor := StrZero ( Int(nVlNConsig) , nTamVLRN - nDecVLRN - 1 ) + cFormato + ;
							      SubStr  ( cResto , At(cFormato,cResto)+1 )
				Endif
			Else
				cNovoValor := StrZero ( Int(nVlNConsig*100) , nTamVLRN )
		  	Endif

			cConteudo	:= SubStr(cConteudo,1,nCpVLRN-1) + cNovoValor + SubStr(cConteudo,nCpVLRN+nTamVLRN)
		Endif

	Else
		cConteudo	:= SubStr(cConteudo,1,nCpVLRN-1) + cNovoValor + SubStr(cConteudo,nCpVLRN+nTamVLRN)

    Endif

	fWrite( nHdlSaida , cConteudo )

Next nX

fClose(nHdlSaida)

MSGINFO( STR0023 + Chr(10) + Upper(cArqSaida) ) //## Arquivo gerado com sucesso!

fFiltraDados(4,.T.)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraMod3 ºAutor  ³Kelly Soares        º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o arquivo de remessa para o banco, com o resultado     º±±
±±º          ³do processamento.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³gpem700                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function fGeraMod3(cArquivo)

Local nX,nY,nZ,nTrlt
Local nHdlSaida
Local nCabec 	:= len(aHDArq)
Local nRodape	:= len(aTRArq)
Local nLInha    := 0
Local cLinha	:= ""
Local cConteudo := ""
Local cNovoValor:= ""
Local nHdLote 	:= len(aHDLt)

If !MsgYesNo( STR0122 ) //"Confirma a geracao do arquivo remessa ?"
	Return
Endif

If File(cArquivo)
	fErase(cArquivo) // Deleta o arquivo, caso ele ja exista
Endif
nHdlSaida := MSFCREATE(cArquivo,FC_NORMAL)
If nHdlSaida == -1   .or. fError() # 0
	Help(" ",1,"SAVECONS")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Unifica as arrays para geracao do Detalhe   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

fJuntaTudo()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o header de arquivo  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nCabec
	cConteudo := aHdArq[nX,1]
	// Atualiza o campo "Codigo Remessa/Retorno" de acordo com pergunte
	If ( nCpCOD > 0 ) .and. ( nX = nOrdCOD ) .and. !Empty(cPergRem)
		cConteudo := SubStr(aHdArq[nX,1],1,nCpCOD-1) + SubStr(cPergRem,1,nTamCOD) + SubStr(aHdArq[nX,1],nCpCOD+1)
	Endif

	fWrite( nHdlSaida , cConteudo )

Next nX


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o header de lote     	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nHdLote
	cConteudo := aHdLt[nX,1]
	nLote	  := aHdLt[nX,2]

	// Atualiza o campo "Tipo de Pagto" de acordo com pergunte
	If ( nCpPAG > 0 ) .and. !Empty(cPergPag)
		cConteudo := SubStr(cConteudo,1,nCpPAG-1) + SubStr(cPergPag,1,nTamPAG) + SubStr(cConteudo,nCpPAG+2)
	Endif

	fWrite( nHdlSaida , cConteudo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o detalhe do lote       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nZ := 1 to len(aColsTudo)
			If aColsTudo[nZ,3] == nLote
				For nY := 2 to nUsado
					cLinha += aColsTudo[nZ][nY]
				Next nY

				cLinha += Chr(13) + Chr(10)
				fWrite( nHdlSaida , cLinha )
				cLinha := ""
			EndIf
		Next nZ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o trailler lote     	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nTrlt := 1 to len(aTRLt)
		If aTRLt[nTrlt,2] == nLote

			cConteudo	:= aTRLt[nTrlt,1]
			nVlConsig	:= aTRLt[nTrlt,4] //Valor Consignado
			nQtConsig	:= aTRLt[nTrlt,5] //Quantidade Consignada
			nVlNConsig	:= aTRLt[nTrlt,6] //Valor Nao Consignado
			nQtNConsig	:= aTRLt[nTrlt,7] //Quantidade Nao Consignada

			nLinha    	:= Len(cConteudo) - 2 //Tamanho da linha sem o retorno

			// QTDE DE PARCELAS CONSIGNADAS
			cConteudo := SubStr(cConteudo,1,nCpQTD-1) + StrZero(nQtConsig,nTamQTD) + SubStr(cConteudo,nCpQTD+nTamQTD)
			// QTDE DE PARCELAS NAO CONSIGNADAS
			cConteudo := SubStr(cConteudo,1,nCpQTDN-1) + StrZero(nQtNConsig,nTamQTDN) + SubStr(cConteudo,nCpQTDN+nTamQTDN)
			// VALOR TOTAL DE PARCELAS CONSIGNADAS
			If nDecVLR > 0
				If Empty(cFormato)
					cNovoValor := StrZero ( nVlConsig*100 , nTamVLR )
				Else
					cResto := If(nVlConsig > 0,StrZero(Mod(nVlConsig,NoRound(nVlConsig,0)),4,2),"00")
					cNovoValor := StrZero ( Int(nVlConsig) , nTamVLR - nDecVLR - 1 ) + cFormato +  SubStr  ( cResto , At(cFormato,cResto)+1 )
				Endif
			Else
				cNovoValor := StrZero ( Int(nVlConsig*100) , nTamVLR )
			Endif

			cConteudo	:= SubStr(cConteudo,1,nCpVLR-1) + cNovoValor + SubStr(cConteudo,nCpVLR+nTamVLR)

			// VALOR TOTAL DE PARCELAS NAO CONSIGNADAS
			If nDecVLRN > 0
				If Empty(cFormato)
					cNovoValor := StrZero ( nVlNConsig*100 , nTamVLRN )
				Else
					cResto := If(nVlNConsig > 0,StrZero(Mod(nVlNConsig,NoRound(nVlNConsig,0)),4,2),"00")
					cNovoValor := StrZero ( Int(nVlNConsig) , nTamVLRN - nDecVLRN - 1 ) + cFormato + ;
							      SubStr  ( cResto , At(cFormato,cResto)+1 )
				Endif
			Else
				cNovoValor := StrZero ( Int(nVlNConsig*100) , nTamVLRN )
			Endif

			cConteudo	:= SubStr(cConteudo,1,nCpVLRN-1) + cNovoValor + SubStr(cConteudo,nCpVLRN+nTamVLRN)

			fWrite( nHdlSaida , cConteudo )

		EndIf

	Next nTrlt

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o trailler de arquivo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nRodape
	cConteudo := aTRArq[nX,1]
	nLinha    := Len(cConteudo) - 2 //Tamanho da linha sem o retorno

	If cTrailler1 $ 'DF' .and. ( SubStr(cConteudo,4,4) == "9999" )   // se for modelo 3 e registro trailler de arquivo, paginar apenas ate a 29 posicao. Demais posicao, de acordo com layout, gerar 'brancos'
	    cConteudo	:= SubStr(cConteudo,1,29) + Space(nLinha-29) + Chr(13) + Chr(10)
	else
		cConteudo	:= SubStr(cConteudo,1,nCpVLRN-1) + cNovoValor + SubStr(cConteudo,nCpVLRN+nTamVLRN)
	EndIf

	fWrite( nHdlSaida , cConteudo )

Next nX

fClose(nHdlSaida)

MSGINFO( STR0023 + Chr(10) + Upper(cArqSaida) ) //## Arquivo gerado com sucesso!

fFiltraDados(4,.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaItemºAutor  ³Luis Artuso         º Data ³  06/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava Item e Classe de valor.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGravaItem(cAlias , aItens , nPos)
Local cItem		:=	""
Local cGrava	:=	""
Local aCampos	:=	{}
Local nX		:=	0
Local nLen		:= 	0

AADD(aCampos , "ITEM")
AADD(aCampos , "CLVL")

nLen	:=	LEN(aCampos)

For nX := 1 to nLen
	If SUBSTR(cAlias , 1 , 3) == "RGB"
		cGrava	:=	cAlias + "->" + SUBSTR(cAlias , 1 , 3) + "_" + aCampos[nX]
	Else
		cGrava	:=	cAlias + "->" + SUBSTR(cAlias , 2 , 2) + "_" + aCampos[nX]
	EndIf

	cItem	:=	aItens[nPos]

	If ( RecLock(cAlias , .F.) )
		&cGrava	:=	cItem
		( cAlias )->( MsUnlock() )
   EndIf

	++nPos
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ Gpem700Per  ³ Autor ³ Equipe RH Inovacao    ³ Data ³22/08/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida os campos periodo e numero de pagamento da pergunte.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo - 1=Periodo e 2=Numero Pagamento		               ³±±
±±³    		 ³                   cPergPro - processo                      ³±±
±±³    		 ³                   cPergPer - Periodo                       ³±±
±±³    		 ³                   cPergPag - Numero de Pagamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Pergunte GPEM700  		 	                                  ³±±
±±ÈÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function Gpem700Per( nTipo, cPergProc, cPergPer, cPergPag, cPergRot)// 1 - Campo RCH_PER, 2 - RCH_NUMPAG e 3 - RCH_ROTEIR
Local cOldAlias := Alias()
Local cFilRCH	   := xFilial("RCH")
Local cMsg      := ""
Local lRet 	   := .T.

Begin Sequence

	If ( nTipo == 1 )
		If !( lRet := NaoVazio() )
			Break
		EndIf
	EndIf

	DbSelectArea("RCH")
	If ( nTipo == 1 )
		RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
		RCH->( dbSeek( cFilRCH + cPergProc + cPergPer + Space(2) + Space(3) , .T. ) )
		While RCH->(!Eof())
			If RCH_FILIAL+RCH_PROCES+RCH_PER == cFilRCH+cPergProc+cPergPer
				Exit
			EndIf
			RCH->( dbSkip() )
		EndDo
	ElseIf nTipo == 2
		RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
		RCH->( dbSeek( cFilRCH + cPergProc + cPergPer + cPergPag + Space(3) , .T. ) )
		While RCH->(!Eof())
			If RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG	== cFilRCH+cPergProc+cPergPer+cPergPag
				Exit
			EndIf
			RCH->( dbSkip() )
		EndDo
	Else
		RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
		RCH->( dbSeek( cFilRCH + cPergProc + cPergPer + cPergPag + cPergRot, .F. ) )
	EndIf

	If RCH->( Eof() )
		lRet := .F.
		If nTipo == 1
			cMsg := STR0163	// "Periodo nao Cadastrado!"
			MsgInfo( cMsg, STR0054)
		Else
			cMsg := STR0164	// "No. Pagamento nao Cadastrado para este Periodo!"
			MsgInfo( cMsg, STR0054)
		EndIf
	EndIf

End Sequence
DbSelectArea(cOldAlias)
Return( lRet )

/*/{Protheus.doc} FixTxtSize
	Corrige o texto para caber dentro do agrupado
@author PHILIPE.POMPEU
@since 05/07/2016
@version P12.1.07
@param cText, caractere, texto original
@param nLen, numérico, tamanho máximo
@return cResult, texto corrigido
/*/
Static Function FixTxtSize(cText, nLen)
	Local cResult := ""

	cResult := cText
	nLen := Int(nLen)
	if(Len(cText) >= nLen)
		cResult := Right(cText,nLen-3)
		cResult := "..." + cResult
	endIf

Return (cResult)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TabNovaDic ³ Autor ³ Oswaldo L      ³ Data ³ 03.10.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Testa existência da tabela no dicionario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           Esta rotina cria a tabela, por isto ela nao existe no banco ³±±
±±³           neste ponto ainda. Entao, verificamos pelo dicionario.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function TabNovaDic ()
Local lRet := .F.

If TCCanOpen(  RETSQLNAME("SGX")   )
	lRet := .T.
EndIf


return lRet
