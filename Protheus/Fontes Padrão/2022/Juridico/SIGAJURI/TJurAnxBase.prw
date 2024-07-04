#INCLUDE "TOTVS.CH"
#INCLUDE "TJURANXBASE.CH"

//Function Dummy
Function __TJurAnxBase()
	ApMsgInfo( I18n(STR0003, {"TJurAnxBase"}) )	//"Utilizar Classe ao inv�s da fun��o #1"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe de anexos da Base de Conhecimento

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
CLASS TJurAnxBase FROM TJurAnexo

	Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, cCajuri, lInterface, lEntPFS) CONSTRUCTOR
	Method NewTHFInterface() CONSTRUCTOR
	Method Importar()
	Method Exportar()
	Method Abrir()

	// Dados
	Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta, cEntBasCon, cCodEntBas)

	Method DeleteNUM(cNumCod)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Inicializador da Classe

@param  cTitulo    - T�tulo da tela
@param  cEntidade  - Entidade utilizada no anexo
@param  cFilEnt    - Filial da entidade
@param  cCodEnt    - C�digo da entidade
@param  nIndice    - �ndice da entidade utilizado para buscar o XXX_CAJURI
@param  cCajuri    - C�digo do assunto jur�dico
@param  lInterface - Indica se demonstra a Interface
@param  lEntPFS    - Indica se � uma entidade do SIGAPFS
                     Necess�rio devido ao uso da fila de sincroniza��o - LegalDesk

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, cCajuri, lInterface, lEntPFS) CLASS TJurAnxBase

	Local aButtons     := {}

	Default cCajuri	   := ""
	Default lInterface := .T.
	Default lEntPFS    := .F.

	_Super:New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, lEntPFS)

	//Seta bot�es
	Aadd(aButtons, {STR0032, {|| Processa({|| Self:Importar()}, STR0035, STR0036, .F.)}, 3})	//"Importar"	"Aguarde"	"Importando arquivos"
	Aadd(aButtons, {STR0033, {|| Processa({|| Self:Exportar()}, STR0035, STR0037, .F.)}, 2})	//"Exportar"	"Aguarde"	"Exportando arquivos"
	Aadd(aButtons, {STR0034, {|| Processa({|| Self:Excluir()} , STR0035, STR0038, .F.)}, 5})	//"Excluir"		"Aguarde"	"Excluindo arquivos"

	Self:SetButton(aButtons)

	Self:SetShowUrl(.F.)

	If lInterface
		Self:Activate()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NewTHFInterface
Inicializador da Classe que ser� chamada pelo Totvs Legal

@author SIGAJUR
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Method NewTHFInterface(cEntidade, cCodEnt, cCodProc, lEntPFS) CLASS TJurAnxBase
Local aButtons     := {}

Default lEntPFS    := .F.

	self:cEntidade := cEntidade
	Self:cCodEnt   := cCodEnt
	self:cCajuri   := cCodProc
	self:lEntPFS   := lEntPFS
	
	//Seta bot�es
	Aadd(aButtons, {STR0032, {|| Processa({|| Self:Importar()}, STR0035, STR0036, .F.)}, 3})	//"Importar"	"Aguarde"	"Importando arquivos"
	Aadd(aButtons, {STR0033, {|| Processa({|| Self:Exportar()}, STR0035, STR0037, .F.)}, 2})	//"Exportar"	"Aguarde"	"Exportando arquivos"
	Aadd(aButtons, {STR0034, {|| Processa({|| Self:Excluir()} , STR0035, STR0038, .F.)}, 5})	//"Excluir"		"Aguarde"	"Excluindo arquivos"

	Self:SetButton(aButtons)

	Self:SetShowUrl(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar()
A��o de importa��o do bot�o

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method Importar() CLASS TJurAnxBase
Local lRet       := .F.
Local nI         := 0
Local cCodObj    := ""
Local cDestino   := MsDocPath()
Local cDirArq    := ""
Local cArq       := ""
Local cNameEncrp := ""
Local cExtension := ""
Local aDadosSE2  := {}
Local cSE2Chave  := ""
Local cCodEnt    := ""
Local cArqEdit   := ""

	Self:setOperation(3)

	If Self:lInterface
		// Chama a tela de sele��o de arquivos
		lRet := _Super:Importar()
	Else
		lRet := .T.
	EndIf

	If lRet
		// Caso tenha selecionado itens
		For nI := 1 to Len(Self:aArquivos)
			IncProc()

			cNameEncrp := CriaVar("ACB_CODOBJ", .T.)
			cCodObj    := ""

			// Diret�rio do arquivo
			cDirArq := Self:aArquivos[nI]

			// Nome do arquivo
			cArq    := Self:RetArquivo(cDirArq, .T.)

			// Gera a c�pia do arquivo na base de conhecimento
		If Self:ManipulaDoc(Self:GetOperation(), cArq,StrTran(cDirArq,cArq,""),cDestino + "\" , cNameEncrp)
				cExtension := SubStr(cArq, Rat(".", cArq))
				// Grava��o da NUM, ACB e  AC9
				If !Self:GravaNUM(cNameEncrp, StrTran(cArq, cExtension, ""), cArq, cExtension, Self:cSubPasta)
				  	lRet := .F.
				  	JurMsgErro( I18n(STR0004, {cArq}) )	//"Erro ao registrar o documento na base de conhecimento: #1"
					Exit
				ElseIf Self:cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1' //caso a entidade seja a NT3 e tenha integra��o com o financeiro 
					//obtemos as informa��es do contas a pagar (SE2)  
					cCodEnt := SubStr(Self:cCodEnt, At(Self:cCajuri,Self:cCodEnt)+10,10)
					aDadosSE2 := JurQryAlc(Self:cEntidade, Self:cCajuri, cCodEnt, IIF(Self:cEntidade == 'NT2','2','3'), .T.)
					If Len(aDadosSE2) > 0
						cSE2Chave := PadR((AllTrim(aDadosSE2[5])),GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))
						cSE2Chave += PadR((AllTrim(aDadosSE2[4])),GetSx3Cache("E2_NUM",    "X3_TAMANHO"))
						cSE2Chave += PadR((AllTrim(aDadosSE2[6])),GetSx3Cache("E2_PARCELA","X3_TAMANHO"))
						cSE2Chave += PadR((AllTrim(aDadosSE2[7])),GetSx3Cache("E2_TIPO",   "X3_TAMANHO"))
						cSE2Chave += PadR((AllTrim(aDadosSE2[8])),GetSx3Cache("E2_FORNECE","X3_TAMANHO"))
						cSE2Chave += PadR((AllTrim(aDadosSE2[9])),GetSx3Cache("E2_LOJA",   "X3_TAMANHO"))
						
						//gravamos o mesmo anexo na AC9 e ACB para o titulo gerado
						cArqEdit := cleanString( StrTran(cArq, cExtension, ""), .F. ) + cExtension //substitui os caracteres especiais para salvar na base de conhecimento do financeiro
						If Self:ManipulaDoc(Self:GetOperation(), cArq, StrTran(cDirArq, cArq, ""), cDestino + "\" , cArqEdit)
							cNameEncrp := CriaVar("ACB_CODOBJ", .T.)
							Self:GravaNUM(cNameEncrp, StrTran(cArqEdit, cExtension, ""), ""/*cArq*/,;
								cExtension, Self:cSubPasta,"SE2"/*cEntBasCon*/, cSE2Chave/*cCodEntBas*/)
						EndIf
					EndIf
				EndIf
			Else
				lRet := .F.
				JurMsgErro( I18n(STR0005, {cArq}) )		//"Erro ao copiar o documento para a base de conhecimento: #1"
				Exit
			EndIf
		Next
	EndIf

	If lRet
		If Self:lInterface
			Self:AtualizaGrid()
		EndIf

		If Len(Self:aArquivos) > 1 .AND. !JurAuto()
			ApMsgInfo(STR0006)		//"Documento(s) anexado(s)"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Exportar()
A��o do bot�o de exporta��o

@Param cCajuri - c�digo do assunto juridico
@Param cDirDestin - diret�rio de destino
@Param cNumDoc - Numero do documento (NUM_NUMERO)
@Param cArquivo - Nome do arquivo com sua extens�o (teste.pdf)

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method Exportar(cCajuri, cDirDestin, cNumDoc, cArquivo, aArquivos) CLASS TJurAnxBase
Local cDirOrigem := MsDocPath()
Local nI         := 0
Local lRet       := .T.
Local cArqComp   := ""
Local aArqZip    := {}
Local cHora      := ""
Local lCriaPast  := .F.
Local aHora      := {}

Default cCajuri    := Self:CCajuri
Default cDirDestin := ""
Default cNumDoc    := ""
Default cArquivo   := ""
Default aArquivos  := {}

	aHora := STRToArray(time(), ':') //Retirando ":" da hora (Ex: 10:50:55)

	//Atribui��o o hor�rio sem pontua��o
	For nI := 1 to Len(aHora)
		cHora += aHora[nI]
	Next

	cNomePst := cCajuri + cHora + "\" // Nome da pasta que ser� criada na temp (N� do processo + Hor�rio atual)

	// Verifica��o para salvar no caminho tempor�rio
	If Self:lSalvaTemp
		cDirDestin := GetTempPath() //Pasta tempor�ria local
		cDirDestin += cNomePst      //adicionando a pasta do processo + hor�rio no caminho da pasta tempor�ria
		
		If !Self:lHtml
			lCriaPast  := JurMkDir(cDirDestin,.F.,.F.) //cria��o da pasta caso ainda n�o exista no diret�rio
		EndIf
	EndIf

	if Empty(cNumDoc) //se n�o tiver arquivo espec�fico, pega marcados
		// Chamada do Exportar da Classe Pai
		lRet := _Super:Exportar(,aArquivos)

		If lRet .And. ;
			(Self:lHtml .Or.;
				(!Self:lSalvaTemp .Or. ;                // Se n�o for Salvar na Tempor�ria
					(Self:lSalvaTemp .And. lCriaPast))) // Se for Salvar na Tempor�ria e a Pasta foi Criada.
	
			//Carrega destino dos arquivos (Html - destino temporario)
			If Self:lHtml
				cDirDestin := cDirOrigem + "\"
			Else
				If Empty(cDirDestin)
					cDirDestin := cGetFile(STR0007 + "|*.*", STR0008, 0, "C:\", .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .F.)	//"Todos os arquivos"	//"Selecione uma pasta"
				EndIf
			EndIf
				
			If !Empty(cDirDestin)
				For nI:=1 To Len(Self:aArquivos)
	
					//Monta nome do arquivo
					cArquivo := AllTrim(Self:aArquivos[nI][4]) + AllTrim(Self:aArquivos[nI][5]) // NUM_DOC + NUM_EXTEN
					cArqComp := GetCaminho(Self:aArquivos[nI][3])	 //NUM_NUMERO
	
					If File(cArqComp)
						//Copia arquivos (Html para pasta temporaria)
						If !__CopyFile(cArqComp, cDirDestin + cArquivo)
							lRet := .F.
							JurMsgErro( I18n(STR0009, {cArqComp}) )		//"Erro ao copiar o documento para: #1"
							Exit
						Else
							aAdd(aArqZip, cDirDestin + cArquivo)
						EndIf
					Else
						lRet := .F.
						JurMsgErro( I18n(STR0010, {cArquivo}) )		//"Arquivo n�o encontrado: #1"
						Exit
					EndIf
				Next nCont
	
				If Self:lHtml .AND. Len(aArqZip) > 0
					Self:ZipFileDownload(aArqZip)
				EndIf
			Else
				lRet := .F.
				JurMsgErro( STR0040 ) //"Caminho de destino n�o foi selecionado. Opera��o cancelada pelo usu�rio!"
			EndIf
		Else
			ApMsgInfo(STR0039) //"N�o h� anexos selecionados para a exporta��o!"
		EndIf
	Else
		//arquivo espec�fico
		cArqComp := GetCaminho(cNumDoc)	 //NUM_NUMERO
		conout("TJURANXBASE")
		If File(cArqComp)
			//Copia arquivos (Html para pasta temporaria)
			If !__CopyFile(cArqComp, cDirDestin + cArquivo)
				lRet := .F.
				JurMsgErro( I18n(STR0009, {cArqComp}) )		//"Erro ao copiar o documento para: #1"
			EndIf
		Else
			lRet := .F.
			JurMsgErro( I18n(STR0010, {cArquivo}) )		//"Arquivo n�o encontrado: #1"
		EndIf
	Endif

	If lRet .And. !Self:lSalvaTemp
		ApMsgInfo(STR0011) //"Documentos exportados com sucesso!"
	ElseIf lRet .And. Self:lSalvaTemp .AND. !Self:lHtml
		Self:cDocumento := cDirDestin + cArquivo
		_Super:Abrir()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Abrir
M�todo Abrir para quando for abrir o arquivo na tempor�ria

@version 2.0
@since   04/04/2019
/*/
//-------------------------------------------------------------------
Method Abrir(cCajuri) CLASS TJurAnxBase
	Self:lSalvaTemp := .T.

	Self:Exportar(cCajuri)

	Self:lSalvaTemp := .F.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaNUM
Grava��o do registro na base de conhecimento NUM, ACB e AC9

@Param cNumero    	- Identificador
@Param cDoc       	- Link do Documento
@Param cDesc      	- Nome do Documento
@Param cExtensao	- Extens�o do Arquivo
@param cSubPasta	- Nome da sub-pasta criada dentro da entidade NSZ
@param cEntBasCon   - Entidade a ser gravada na base de conhecimento
@param cCodEntBas   - C�digo da entidade a ser gravada na base de conhecimento

@author  Rafael Tenorio da Costa
@version 2.0
@since   11/05/2018
/*/
//-------------------------------------------------------------------
Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta, cEntBasCon, cCodEntBas) CLASS TJurAnxBase
	
	Local lRetorno:= .T.
	Local lIntegra := .F. //indica se ser�o gravados anexos na base de conhecimento para as entidades do financeiro 
	
	Default cEntBasCon := ""
	Default cCodEntBas := ""

	Begin Transaction

		//Bancos de Conhecimentos
		lRetorno := Reclock("ACB", .T.)
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := cNumero
			If Empty(cEntBasCon)
				ACB->ACB_OBJETO := cNumero
				ACB->ACB_DESCRI := cDoc + cExtensao
			Else
				ACB->ACB_OBJETO := cDoc + cExtensao
				ACB->ACB_DESCRI := cDoc
				lIntegra := .T.
			EndIf
		ACB->( MsUnLock() )
		
		
		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo

		//Relacao de Objetos x Entidades
		If lRetorno
			lRetorno := Reclock("AC9", .T.)
				AC9->AC9_FILIAL := xFilial("AC9")
				If Empty(cEntBasCon)
					AC9->AC9_FILENT := xFilial(Self:cEntidade)
					AC9->AC9_ENTIDA := Self:cEntidade
					AC9->AC9_CODENT := Self:cCodEnt
				Else
					AC9->AC9_FILENT := xFilial(cEntBasCon)
					AC9->AC9_ENTIDA := cEntBasCon
					AC9->AC9_CODENT := cCodEntBas
				EndIf
				AC9->AC9_CODOBJ := cNumero
			AC9->( MsUnLock() )
		
			While __lSX8
				If lRetorno
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			EndDo
		EndIf

		If lRetorno .AND. !lIntegra
			lRetorno := _Super:GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta)
		EndIf

	End Transaction

	If !lRetorno
		JurMsgErro(STR0014 + Self:GetErro())	//"Erro na grava��o da Base de Conhecimento: "
	EndIf

Return lRetorno



//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteNUM(cNumCod)
Exclus�o de registro na NUM

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method DeleteNUM(cNumCod) CLASS TJurAnxBase
Local lRet     := .T.
Local cChvACB  := ""
Local cChvAC9  := ""
Local aArea    := GetArea()
Local aAreaNUM := NUM->( GetArea() )
Local cChvACB2 := ""

	Begin Transaction

		//Documentos jur�dicos
		NUM->( DbSetOrder(1) ) //NUM_FILIAL + NUM_COD
		If NUM->( DbSeek(xFilial("NUM") + cNumCod))
			cChvACB  := NUM->NUM_NUMERO
			cChvAC9  := NUM->NUM_NUMERO + NUM->NUM_ENTIDA + NUM->NUM_FILENT + NUM->NUM_CENTID
			
			//Chave para exclus�o da base de conhecimento do financeiro 
			cChvACB2 := AllTrim(NUM->NUM_DOC) + AllTrim(NUM->NUM_EXTEN)

			lRet := RecLock("NUM", .F.)
				NUM->( DbDelete() )
			NUM->( MsUnLock() )
		Else
			lRet := .F.
		EndIf
		If lRet
			lRet := JAnxDlBaseCon( cChvACB, cChvAC9 )
		EndIf
		
		//dele��o do anexo na base de conhecimento quando h� integra��o com o financeiro 
		If lRet
			If Self:cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1'
				//deletamos o mesmo anexo na AC9 e ACB para o titulo gerado
				lRet := JAnxDlBaseCon( cChvACB2, /*cChvAC9*/, 2/*nACBIndex*/) //ACB_FILIAL + ACB_OBJETO
				If !lRet
					JurMsgErro(STR0041) //"Erro na exclus�o da Base de Conhecimento do Contas a Pagar."
				EndIf
			EndIf
		EndIf

		If lRet
			_Super:SetNUMCod(cNumCod)
			_Super:FSincAnexo("5") // Exclui os anexos na fila de sincroniza��o - SOMENTE SIGAPFS
		EndIf
		
	End Transaction

	RestArea(aAreaNUM)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J026aErrAr
Retorna a descricao do erro que ocorreu na geracao do arquivo.

@param	nErro		- Codigo do erro retornado pela funcao FError()
@return cMsgErro	- Descricao do erro

@author Rafael Tenorio da Costa
@since 17/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function TJABError( nErro )

	Local cMsgErro := ""

	Do Case

		Case nErro == 0
			cMsgErro := STR0017		//"Opera��o bem-sucedida."
		Case nErro == 2
			cMsgErro := STR0018		//"Arquivo n�o encontrado."
		Case nErro == 3
			cMsgErro := STR0019		//"Diret�rio n�o encontrado."
		Case nErro == 4
			cMsgErro := STR0020		//"Muitos arquivos foram abertos. Verifique o par�metro FILES."
		Case nErro == 5
			cMsgErro := STR0021		//"Imposs�vel acessar o arquivo."
		Case nErro == 6
			cMsgErro := STR0022		//"N�mero de manipula��o de arquivo inv�lido."
		Case nErro == 8
			cMsgErro := STR0023		//"Mem�ria insuficiente."
		Case nErro == 15
			cMsgErro := STR0024		//"Acionador (Drive) de discos inv�lido."
		Case nErro == 19
			cMsgErro := STR0025		//"Tentativa de gravar sobre um disco protegido contra escrita."
		Case nErro == 21
			cMsgErro := STR0026		//"Acionador (Drive) de discos inoperante."
		Case nErro == 23
			cMsgErro := STR0027		//"Erro de dados no disco."
		Case nErro == 29
			cMsgErro := STR0028		//"Erro de grava��o no disco."
		Case nErro == 30
			cMsgErro := STR0029		//"Erro de leitura no disco."
		Case nErro == 32
			cMsgErro := STR0030		//"Viola��o de compartilhamento."
		Case nErro == 33
			cMsgErro := STR0031		//"Viola��o de bloqueio."

	End Case

Return cMsgErro



//-------------------------------------------------------------------
/*/{Protheus.doc} GetCaminho
Retorna o caminho f�sico do arquivo. Pode ser atrav�s do c�digo
ou nome por quest�es de compatibilidade

@param  cCodObj	- C�digo do objeto
@return lRetorno	- Define se existe
@author Willian Kazahaya
@since  05/05/2018
/*/
//-------------------------------------------------------------------
Static Function GetCaminho(cCodObj)
Local cRet := ""
Local cBase := MsDocPath()
//pega o conte�do do campo do nome do arquivo na ACB
Local cArqACB := JurGetDados("ACB",1,xFilial("ACB")+cCodObj,"ACB_OBJETO")

//valida se o c�digo esta gravado no campo ACB_OBJETO ou o nome do arquivo
if (cArqACB == cCodObj)
	cRet := cBase + "\" + cCodObj
Else
	//compatibilidade com a base de conhecimento antiga
	cRet := cBase + "\" + cArqACB
Endif

Return cRet
