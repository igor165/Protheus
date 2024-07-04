////////////////
// Versao 010 //
////////////////

#include "protheus.ch"
#include "VEICLSAL.CH"

Function VEICLSAL()
Return()


/*/{Protheus.doc} DMS_Logger
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Cria Logs facilmente
/*/
Class DMS_Logger
	Data cLogFileName
	Data cLogDir
	Data aLines
	Data lVQL_MSGLOG

	Method New() CONSTRUCTOR
	Method Log()
	Method LogSysErr()
	Method LogToTable()
	Method SimpleLogToTable()
	Method GetArray()
	Method CloseOpened()
	Method GetFile()
	Method LogPilhaChamada()
	Method _GetSxe()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_Logger

	@param cFileName, String, Nome do arquivo que será aberto/criado para escrever o log
	@param cFileDir,  String, Pasta para colocar o log
	@author Vinicius Gati
	@since 21/05/2014
/*/
Method New(cFileName, cFileDir) class DMS_Logger
	// cria tabela de log
	Local cAliasBck := alias()
	Local cLogFolder := ""
	Local nFolder
	Default cFilename := "GERAL.LOG"
	Default cFileDir := ""
	dbSelectArea("VQL")
	If !Empty(cAliasBck)
		dbSelectArea(cAliasBck)
	EndIf
	//
	If Empty(cFileDir)
		cLogFolder := "logsmil"
		makeDir( curdir() + cLogFolder )
		::cLogDir := curdir()
	Else
		//cLogFolder += "\" + Lower(cFileDir)
		aFolders := StrTokArr( cFileDir , "\" ) //"
		For nFolder := 1 to Len(aFolders)
			cLogFolder += "\" + AllTrim(aFolders[nFolder]) //"
			makeDir( cLogFolder )
		Next nFolder
		::cLogDir := ""
	EndIf
	::cLogFileName := cLogFolder + ALLTRIM(" \ ") + cFileName

	::lVQL_MSGLOG := VQL->(FieldPos("VQL_MSGLOG")) > 0

Return SELF

/*/{Protheus.doc} Log
	Loga as mensagens no arquivo

	@author Vinicius Gati
	@since  21/05/2014
	@param  aLines, Array, Array com Strings que serão gravadas 1 em cada linha
/*/
Method Log(aLines) Class DMS_Logger
	Local nIdx       := 1
	Local oArquivo   := Self:GetFile()
	Local cPulaLinha := chr(13) + chr(10)

	For nIdx := 1 To Len(aLines)
		cLine := aLines[nIdx]
		If cLine == 'TIMESTAMP'
			FWRITE( oArquivo, DTOS(DATE()) + " " + TIME() + ":" + LEFT(CVALTOCHAR( SECONDS() ), 8) + " " )
		Else
			FWRITE(oArquivo, cLine + cPulaLinha)
		EndIf

		If FERROR() # 0
			MSGALERT(STR0001 + str(ferror())) // "ERRO GRAVANDO ARQUIVO, ERRO: "
			Return
		Endif
	Next
	FCLOSE(oArquivo)
Return

/*/{Protheus.doc} GetFile
	Cria/Abre arquivo e retorna o mesmo

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method GetFile() Class DMS_Logger
	Local cFullFilePath := ::cLogDir + ::cLogFileName
	Local oFileStream   := Nil
	If FILE(cFullFilePath)
		oFileStream := FOPEN( cFullFilePath, 1 ) // 1 = write FO_WRITE
	Else
		oFileStream := FCREATE( cFullFilePath )
	EndIf
	// 0 FS_SET Ajusta a partir do inicio do arquivo. (Default)
	// 1 FS_RELATIVE Ajuste relativo a posição atual do arquivo.
	// 2 FS_END Ajuste a partir do final do arquivo.
	nFinalPos := FSEEK(oFileStream,0,2)
	FSEEK(oFileStream, nFinalPos)
Return oFileStream

/*/{Protheus.doc} _GetSxe
	Gera e retorna um numero sxe valido tentando evitar erro de 
	chave duplicada

	@type function
	@author Vinicius Gati
	@since 14/06/2019
/*/
Method _GetSxe() Class DMS_Logger
	Local cQuery := ''
	Local cNum   := ''
	Local nTry   := 0

	while nTry <= 10000
		cNum := GetSxeNum("VQL", "VQL_CODIGO")

		cQuery := " SELECT COALESCE(count(*), 0) FROM " + RetSQLName("VQL")
		cQuery += "  WHERE VQL_FILIAL = '"+xFilial("VQL")+"' AND VQL_CODIGO = '" + cNum + "' AND D_E_L_E_T_ = ' ' "
		if FM_SQL(cQuery) > 0
			ConfirmSx8()
		else
			ConfirmSx8()
			return cNum
		end
		nTry += 1
	end
Return 'problemaSXE9999999' // se retornar isso é porque não encontrou sxe valido em mais de 100mil tentativas, sendo assim é melhor ajustar

/*/{Protheus.doc} LogSysErr
	Mostra erro de sistema e grava no hd, porem o problema é que o
	mostra erro grava somente o ultimo erro	criei este metodo para mostrar
	normalmente o mostra erro porem gravando tambem em um arquivo
	separado que guarda todos os erros passados

	@param cFilename, nome do arquivo que o erro será loggado via append

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method LogSysErr(cFileName, lSendMail, cAssunto) Class DMS_Logger
	Local   cEmail     := ""
	
	Local   oEmailHlp  := DMS_EmailHelper():New()
	Default cFileName  := "ultimo_erro_sistema.log"
	Default lSendMail  := .T.
	Default cAssunto   := STR0006 /*"Erro de sistema detectado em "*/ + dtoc(ddatabase) + " " + TIME()

	cPath := ALLTRIM("\system\logsmil\ ")
	oLog  := DMS_Logger():New(cFileName)
	self:aLines := {}

	MostraErro(cPath, cFileName)
	if ! File(cPath+cFileName, 0)
		FCREATE(cPath+cFileName, 0)
	Endif

	if File(cPath+cFileName, 0)
		FT_FUse( cPath+cFileName )
		While ! FT_FEof()
			if LEN(cEmail) > 5000
				Exit
			end
			cLinha := FT_FReadLN()
			AADD(self:aLines, cLinha)
			cEmail += cLinha + "<br/>"
			FT_FSkip()
		EndDo
		FT_FUse()

		if lSendMail
			oEmailHlp:SendTemplate({;
				{'template'           , 'mil_sys_err'                                                                },;
				{'origem'             , GetNewPar("MV_MIL0088", "")                                                  },;
				{'destino'            , GetNewPar("MV_MIL0102", "")                                                  },;
				{'assunto'            , cAssunto                                                                     },;
				{':titulo'            , STR0006 /*"Erro de sistema detectado em "*/ + dtoc(ddatabase) + " " + TIME() },;
				{':cabecalho1'        , STR0007/*"Lamentamos o ocorrido, seguem detalhes do mesmo:"*/                },;
				{':dados_cabecalho1'  , cEmail                                                                       } ;
			})
		endif

		oLog:Log(self:aLines)
	end
Return .F.

/*/{Protheus.doc} LogToTable
	Loga para nova tabela VQL (rodar update UPDVEIHU para adiciona-la ao x3)


	@param aData, Dados que serão usados para logar no modelo:
		{
			{'VQL_FILORI' ,    '01'},
			{'VQL_AGROUP' , 'XXXXX'},
			{'VQL_TIPO'   , 'XXXXX'},
			{'VQL_DADOS'  , 'XXXXX'},
			{'VQL_FILORI' , 'XXXXX'},
			{'VQL_DATAI'  , 'XXXXX'}, => padrao data/hora atual
			{'VQL_HORAI'  , 'XXXXX'}, => padrao data/hora atual
			{'VQL_DATAF'  , 'XXXXX'},
			{'VQL_HORAF'  , 'XXXXX'}
		}
	@return VQL_CODIGO, retorna o codigo do log gerado

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method LogToTable(aData) Class DMS_Logger
	Local oData := DMS_DataContainer():New(aData)
	Reclock("VQL", .T.)
	VQL->VQL_CODIGO := self:_GetSxe()
	VQL->VQL_FILIAL := xFilial('VQL')
	VQL->VQL_CODVQL := oData:GetValue('VQL_CODVQL', "")
	VQL->VQL_AGROUP := oData:GetValue('VQL_AGROUP', "")
	VQL->VQL_TIPO   := oData:GetValue('VQL_TIPO'  , "")
	VQL->VQL_DADOS  := oData:GetValue('VQL_DADOS' , "")
	VQL->VQL_FILORI := oData:GetValue('VQL_FILORI', "")
	VQL->VQL_DATAI  := oData:GetValue('VQL_DATAI' , dDatabase)
	VQL->VQL_HORAI  := oData:GetValue('VQL_HORAI' , VAL(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" )) )
	VQL->VQL_DATAF  := oData:GetValue('VQL_DATAF' , nil)
	VQL->VQL_HORAF  := oData:GetValue('VQL_HORAF' , nil)
	If ::lVQL_MSGLOG .and. ! Empty(oData:GetValue('VQL_MSGLOG',""))
		VQL->VQL_MSGLOG := oData:GetValue('VQL_MSGLOG',"")
	EndIf
	msunlock()
Return VQL->VQL_CODIGO

/*/{Protheus.doc} SimpleLogToTable
	Loga para nova tabela VQL (rodar update UPDVEIHU para adiciona-la ao x3)


	@param cGrupo, Agrupador
	@param cMensagem, Mensagem que será gravada
	@author Vinicius Gati
	@since  21/05/2014
/*/
Method SimpleLogToTable(cGrupo, cMensagem) Class DMS_Logger
	If LEN(cGrupo) > 4 .AND. LEN(cMensagem) > 1
		Self:LogToTable({ ;
			{'VQL_AGROUP' , cGrupo   }, ;
			{'VQL_DADOS'  , cMensagem}  ;
		})
	Else
		Return .F. // não fez por falta de dados
	EndIf
Return .T.

/*/{Protheus.doc} CloseOpened
	Loga para nova tabela VQL (rodar update UPDVEIHU para adiciona-la ao x3)

	@param cCodigo, Codigo do VQL
	@param dDataF, Data do fechamento
	@param nHoraF, Hora do fechamento
	@example oLogger:CloseOpenned('000001') => desse jeito o padrao pega data e hora atual do sistema
	@example oLogger:CloseOpenned('000001', STOD('20150106'), 1430) => fecha com data passada por parametro
	@return .T.|.F. true se alterou e false se o codigo nao existe e nao alterou

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method CloseOpened(cCodigo, dDataF, nHoraF) Class DMS_Logger
	Default dDataF := dDatabase
	Default nHoraF := VAL(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ))

	dbSelectArea("VQL")
	dbSeek(xFilial("VQL") + cCodigo)
	If FOUND()
		Reclock("VQL", .F.) // altera
		VQL->VQL_DATAF := dDataF
		VQL->VQL_HORAF := nHoraF
		msunlock()
	Else
		Return .F. // nao existe o codigo
	EndIf
Return .T.

/*/{Protheus.doc} GetArray
	Pega todos os campos VQL_DADOS das chaves passadas e retorna o resultado em array

	@author Vinicius Gati
	@since  08/07/2015
/*/
Method GetArray(cAgroup, cTipo) Class DMS_Logger
	Local aRet := {}
	Local cAl := GetNextAlias()

	cQuery := " SELECT VQL.VQL_DADOS FROM " + RetSqlName('VQL') + " VQL WHERE VQL.D_E_L_E_T_ = ' ' "
	cQuery += " AND VQL.VQL_AGROUP = '" +cAgroup+ "' AND VQL.VQL_TIPO = '" +cTipo+ "' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	//
	While !(cAl)->(EOF())
		AADD( aRet, (cAl)->VQL_DADOS )
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} LogPilhaChamada
	@author Renato Vinicius
	@since  19/10/2018
	@param  cRotina, caracter, Nome da rotina
	@param  cCodStr, caracter, Código STR da mensagem apresentrada
	@description  Cria o arquivo txt contendo a pilha de chamada até a apresentação da mensagem
/*/
Method LogPilhaChamada(cRotina, cCodStr) Class DMS_Logger

	Local cArq  := "\logsmil\"
	Local cPulaLinha := chr(13) + chr(10)
	Local nCont := 1
	Local nHdl  := 0

	cArq += cRotina
	cArq += "_"+cCodStr
	cArq += "_"+DtoS(Date())
	cArq += "_"+Strtran(Time(),":","")
	cArq += ".txt"

	nHdl := FCreate(cArq)

	While !Empty(ProcName(nCont))
		fWrite(nHdl, StrZero(nCont, 6)+' - '+ProcName(nCont)+"("+cValToChar(ProcLine(nCont))+")"+cPulaLinha)
		nCont++
	EndDo

	FClose(nHdl)

Return








/*/{Protheus.doc} DMS_LinhasDeCredito
	Representa tabela do VX5

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class DMS_LinhasDeCredito
	Method New() CONSTRUCTOR
	Method GetTbCode()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class DMS_LinhasDeCredito
Return Self

Method GetTbCode() Class DMS_LinhasDeCredito
Return '032'











/*/{Protheus.doc} DMS_LoginHelper
	@author       Rubens Takahashi
	@since        18/03/2016
	@description  Classe para manipulacao de usuario do produto
/*/
Class DMS_LoginHelper

	Data cUser
	Data cPass
	Data cId

	Data cName

	Method New() CONSTRUCTOR
	Method GetUserPass()
	Method IsAdmin()

	Method GetID()
	Method GetName()

EndClass

/*/{Protheus.doc} New
	Construtor de Classe

	@author       Rubens Takahashi
	@since        18/03/2016

/*/
Method New() Class DMS_LoginHelper
 	Self:cUser := Self:cPass := Self:cId := ""
Return Self

/*/{Protheus.doc} GetUserPass
	@author       Rubens Takahashi
	@since        18/03/2016
	@description  Exibe uma tela solicitando usuario e senha, e valida com o arquivo de senha
/*/
Method GetUserPass() Class DMS_LoginHelper
	Local aParamBox := {}
	Local aRetParam := {}

	PswOrder(2)

	AADD( aParamBox , { 1 , STR0002 , Space(25) , "" , "PswSeek( IIF( AllTrim(Upper(MV_PAR01)) == 'ADMIN' , 'ADMINISTRADOR' , AllTrim(MV_PAR01) ) , .T.)" , "" , "" , 50 , .T.}) // "Usuário"
	AADD( aParamBox , { 8 , STR0003 , Space(25) , "" , "" , "" , "!Empty(MV_PAR01)" , 50 , .T.}) // "Senha"

	While .t.
		If !ParamBox(aParamBox,STR0002 + " / " +STR0003,@aRetParam,,,,,,,,.f.)
 			Self:cUser := Self:cPass := Self:cId := self:cName := ""
 			Return .f.
		EndIf

		MV_PAR01 := IIF( AllTrim(Upper(MV_PAR01)) == 'ADMIN' , 'ADMINISTRADOR' , AllTrim(MV_PAR01) )
		If !PswSeek(MV_PAR01,.t.)
			MsgInfo(STR0004) // "Usuário não encontrado."
			Loop
		EndIf
		If !PswName(MV_PAR02)
			MsgStop(STR0005) // "Senha incorreta."
			Loop
		EndIf

		Self:cUser := AllTrim(MV_PAR01)
		Self:cPass := AllTrim(MV_PAR02)
		Self:cId := PswId()
		self:cName := UsrRetName(self:cId)
		Exit
	End

Return .t.

/*/{Protheus.doc} IsAdmin
	@author       Rubens Takahashi
	@since        18/03/2016
	@description  Verifica se o usuario informado é ADMINISTRADOR
/*/
Method IsAdmin() Class DMS_LoginHelper
	If Empty(Self:cUser) .or. !FWIsAdmin(Self:cId)
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} GetUserID
	@author       Rubens Takahashi
	@since        18/03/2016
	@description  Retorna Nome do Usuario 
/*/
Method GetID() Class DMS_LoginHelper
Return self:cId

Method GetName() Class DMS_LoginHelper
Return self:cName

