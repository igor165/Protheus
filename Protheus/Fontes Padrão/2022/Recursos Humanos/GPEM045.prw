#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM045.CH"

#DEFINE TAMIMP  120
#DEFINE TAMTELA 086

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEM045    � Autor � Alessandro Santos     	      � Data � 06/12/13 ���
���������������������������������������������������������������������������������������Ĵ��
���Descricao 	� Qualificacao cadastral do eSocial.                           			���
���             � Rotina para exportar informacoes de funcionarios e gerar arquivo txt	���
���             � na integracao com eSocial conforme parametros informados pelo usuario.���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM045()                                                    			���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico (DOS e Windows)                                   			���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               			���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������Ĵ��
���Claudinei S. �16/10/2015� TTNOIN         �Criacao novo fonte.                        ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/

Function GPEM045()
Local aOfusca	  := If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel	  := {"RA_CIC", "RA_PIS", "RA_NOMECMP", "RA_NOME"}
Local lBlqAcesso  := aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Local cPerg       := "GPEM045"
Local nOpca       := 0
Local nContSays   := 1
Local aSays       := {}
Local aButtons	  := {} //Arrays locais de preferencia
Local aTitle      := {}
Local aArea	      := GetArea()
Local aAliasSRA   := SRA->(GetArea()) //Salva area SRA
Local bProcesso   := {|oSelf| fGp45Pro(oSelf, aTitle, cPerg)}
Local cCadastro   := OemToAnsi(STR0012) + " " + OemToAnsi(STR0013) + " " + OemToAnsi(STR0014)
/*"Gera��o de Arquivo txt para realizar valida��o dos CPF, NIS, Nome e data de nascimento em lote para n�o"
"comprometer o cadastramento inicial ou admiss�es de trabalhadores no eSocial."
"Se qualquer um dos campos CPF, NIS, Nome e data de nascimento do trabalhador, n�o possuir conte�do,  a linha de registro do mesmo n�o ser� gerada."
*/

Private oProcess		:= Nil

	If lBlqAcesso	//Tratamento de acesso a dados pessoais
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Else
		//Adiciona titulo para Log
		Aadd(aTitle, OemToAnsi(STR0011)) //"Log de Ocorrencias - Qualifica��o Cadastral"

		Pergunte(cPerg, .F.)

		oProcess := tNewProcess():New(cPerg, OemToAnsi(STR0002), bProcesso, cCadastro, cPerg,,,,, .T., .T.) //"Qualifica��o cadastral eSocial"

		//Restaura Areas
		RestArea(aAliasSRA)
		RestArea(aArea)

	EndIf
Return()

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � fGp45Pro		�Autor�  Alessandro Santos� Data �06/12/2013�
�����������������������������������������������������������������������Ĵ
�Descricao �Processo de exportacao para txt e gravacao do arquivo.      �
�          �O controle dos campos que serao gravados sera pelo array    �
�          �aCposTxt, caso seja necessario incluir novos campos         �
�          �adicionar nesse array.                                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM045                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function fGp45Pro(oProcess, aTitle, cPerg)

Local nHdl      	:= Nil
Local cLin 	   	:= ""
Local cArqTxt		:= Alltrim(MV_PAR09)		// Diretorio + Nome do arquivo
Local nI        	:= 0
Local nX      	:= 0
Local cEOL  		:= CHR(13) + CHR(10)
Local aInfoSRA  	:= {}
Local aLogProc  	:= {}
Local aCposTxt  	:= {"RA_CIC", "RA_PIS", "RA_NOMECMP", "RA_NASC"}
Local cTime 		:= Time()
Local cFormat 		:= ".txt"

Private nOpc     	:= MV_PAR10 	// Opcao de Processamento

oProcess:SaveLog(OemToAnsi(STR0005)) //"Inicio do processamento"

If !("." $ cArqTxt)
	cTime := StrTran(cTime,":","_")
	cArqTxt	+= "QualiCad_" + Dtos(Date()) + "_" + cTime + cFormat
EndIf

//Efetua validacoes
If !fGp45Vld(nOpc, @nHdl, aCposTxt, @cArqTxt, aLogProc, oProcess)
	Return()
EndIf

//Busca informacoes
fGp45Info(oProcess, aInfoSRA, aCposTxt, aLogProc)

If nOpc == 1 //Geracao de arquivo txt
	If Len(aInfoSRA) > 0
		/*
		��������������������������������������������������������������Ŀ
		� Gravacao do registro   									   �
		����������������������������������������������������������������*/

		//Loop para geracao do arquivo
		For nI := 1 To Len(aInfoSRA)
			//Prepara buffer para receber os dados
			cLin := ""

			//Busca todos os campos para geracao do arquivo
			For nX := 1 To Len(aCposTxt)
				If nX < Len(aCposTxt)
					cLin += aInfoSRA[nI, nX] + ";"
				Else
					cLin += aInfoSRA[nI, nX]
				EndIf
			Next nX

			//Grava o buffer no arquivo de saida
			cLin += cEOL

			//Efetua gravacao
			fWrite(nHdl, cLin, Len(cLin))
		Next nI

		oProcess:SaveLog(OemToAnsi(STR0019) + " - " + cArqTxt) //"Arquivo de Qualifica��o Cadastral gerado"
	EndIf

	//Encerramento
	fClose(nHdl)
	nHdl := Nil

	 //Imprime inconsistencias
	If Len(aLogProc) > 0 //Imprime inconsistencias
		/*
		���������������������������������������������������������Ŀ
		� Apresenta com Log de erros                              �
		�����������������������������������������������������������*/
   		fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg, OemToAnsi(STR0011), "M", "P",, .F.) //"Log de Ocorrencias - Qualifica��o Cadastral"
	EndIf
Else //Impressao de Inconsistencias
	//Apresentacao de Log
	If Len(aLogProc) > 0
		oProcess:SaveLog(OemToAnsi(STR0018)) //"Impress�o do Relat�rio de Inconsist�ncias do eSocial"
		/*
		���������������������������������������������������������Ŀ
		� Apresenta com Log de erros                              �
		�����������������������������������������������������������*/
   		fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg, OemToAnsi(STR0011), "M", "P",, .F.) //"Log de Ocorrencias - Qualifica��o Cadastral"
	Else
		MsgAlert(OemToAnsi(STR0017)) //"N�o existem informa��es para serem impressas, verifique os par�metros de impress�o"
	EndIf
EndIf

Return()

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � fGp45Vld       �Autor�  Alessandro Santos� Data �06/12/2013�
�����������������������������������������������������������������������Ĵ
�Descricao �Validacoes para geracao do arquivo txt ou impressao de incon�
�          �cistencias.                                                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM045                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function fGp45Vld(nOpc, nHdl, aCposTxt, cArqTxt, aLogProc, oProcess)

Local nI        := 0
Local lNivelSRA := .T.

//Validacao do nivel do usuario, caso nao seja suficiente nao entra no processo
For nI := 1 To Len(aCposTxt)
	If !CpoChkNivel(aCposTxt[nI])
		lNivelSRA := .F.
	EndIf
Next nI

//Campo SRA_NOME verificado a parte pois utilizado somente se RA_NOMECMP vazio, portando nao pode estar no array aCposTxt
If !CpoChkNivel("RA_NOME")
	lNivelSRA := .F.
EndIf

If nOpc == 1 .And. !lNivelSRA //Geracao de arquivo txt porem sem permissao de acesso a tabela SRA
	oProcess:SaveLog(OemToAnsi(STR0015) + " - " +  OemToAnsi(STR0016)) //"N�vel do usu�rio n�o permite acessar a rotina"##"Consulte o administrador do sistema"
	Return(.F.)
ElseIf nOpc == 2 .And. !lNivelSRA //Impressao de Inconsistencias porem sem permissao de acesso a tabela SRA
	MsgAlert(OemToAnsi(STR0016) + " - " +  OemToAnsi(STR0017))

	Return(.F.)
EndIf

//Cria o Arquivo de Saida
If nOpc == 1
	Ferase(cArqTxt)
	nHdl := fCreate(cArqTxt)

	If nHdl == -1
		oProcess:SaveLog(OemToAnsi(STR0003) + " - " +  OemToAnsi(STR0004)) //"N�o foi possivel criar o arquivo de sa�da"##"Favor verificar parametros"
		Return(.F.)
	EndIf
EndIf

Return(.T.)

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � fGp45Info      �Autor�  Alessandro Santos� Data �06/12/2013�
�����������������������������������������������������������������������Ĵ
�Descricao �Busca informacoes dos funcionarios e verifica a existencia  �
�          �de inconsistencias conforme parametros informados.          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM045                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function fGp45Info(oProcess, aInfoSRA, aCposTxt, aLogProc)

Local nI         := 0
Local nGera	   := 0
Local cAliasSRA  := ""
Local cCposQuery := ""
Local cCatQuery  := ""
Local cSitQuery  := ""
Local cMsgErro   := ""
Local cCpoAux    := ""
Local cCpo       := ""
Local cFilDe     := MV_PAR01 //Filial De
Local cFilAte    := MV_PAR02 //Filial Ate
Local cMatDe     := MV_PAR03 //Matricula De
Local cMatAte    := MV_PAR04 //Matricula Ate
Local cCCDe      := MV_PAR05 //Centro de Custo De
Local cCCAte     := MV_PAR06 //Centro de Custo Ate
Local cCategoria := MV_PAR07 //Categoria
Local cSituacao  := MV_PAR08 //Situacao
Local cLogGera   := ""
Local aLogGera   := {}
Local cFilNoExec := ""
Local cUltFil	 := ""

SX3->(dbSetOrder(2)) //Indice por campo

//Busca informacoes dos usuarios

cAliasSRA := "QSRA"

//Verifica se alias esta em uso
If (Select(cAliasSRA) > 0)
	(cAliasSRA)->(dbCloseArea())
EndIf

//Adiciona campos da consulta
cCposQuery 	:= "%RA_FILIAL,RA_MAT, RA_NOME, RA_CATFUNC,"

For nI := 1 To Len(aCposTxt)
	If nI < Len(aCposTxt) //Verifica se ultimo registro
		cCposQuery += aCposTxt[nI] + ","
	Else
		cCposQuery += aCposTxt[nI] + "%"
	EndIf
Next nI

//Tratamento categorias
If Empty(cCategoria)
	cCatQuery := "%'" + "*" + "'%"
Else
	cCatQuery := Upper("%" + fSqlIN(cCategoria, 1) + "%")
EndIf

//Tratamento situacoes
If Empty(cSituacao)
	cSitQuery := "%'" + " " + "'%"
Else
	cSitQuery := Upper("%" + fSqlIN(cSituacao, 1) + "%")
EndIf

//Sempre que alterar esta query, a query abaixo (count), tb devera ser alterada.
BeginSql alias cAliasSRA
	SELECT %exp:cCposQuery%
	FROM %table:SRA% SRA
	WHERE  SRA.RA_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte%
		   AND SRA.RA_MAT BETWEEN %exp:cMatDe% AND %exp:cMatAte%
		   AND SRA.RA_CC BETWEEN %exp:cCCDe% AND %exp:cCCAte%
		   AND SRA.RA_CATFUNC IN (%exp:cCatQuery%)
		   AND SRA.RA_SITFOLH IN (%exp:cSitQuery%)
		   AND SRA.%notDel%
	ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
EndSql

dbSelectArea(cAliasSRA)


//Layout do Arquivo de Saida

oProcess:SetRegua1((cAliasSRA)->(RecCount()))

//Posicionamento do primeiro registro e Loop Principal
While (cAliasSRA)->(!Eof())

	/*������������������������������������������������������������Ŀ
	� Posiciona na tabela SRA - Fisica                    	 	   �
	����������������������������������������������������������������*/
	dbSelectArea("SRA")
	dbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_MAT"))
	dbSeek((cAliasSRA)->(RA_FILIAL+RA_MAT),.F.)

	//IncProc para melhor performance
	oProcess:IncRegua1(OemToAnsi(STR0006) + "  " + (cAliasSRA)->RA_FILIAL + " - " + (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_NOME) //"Gerando o registro de:"

	If (cAliasSRA)->RA_FILIAL != cUltFil
		cUltFil := (cAliasSRA)->RA_FILIAL
		If !(cAliasSRA)->( (cAliasSRA)->RA_FILIAL $ fValidFil() )
			cFilNoExec += (cAliasSRA)->RA_FILIAL + "/"
			(cAliasSRA)->(dbSkip())
			Loop
		EndIf
	ElseIf (cAliasSRA)->RA_FILIAL $ cFilNoExec
		(cAliasSRA)->(dbSkip())
		Loop
	EndIf

	/*
	��������������������������������������������������������������Ŀ
	� Validacoes do funcionario  								   �
	����������������������������������������������������������������*/
    cMsgErro := "" //Limpa variavel que armazena erros

	//CPF
	If Empty((cAliasSRA)->RA_CIC)
		cMsgErro += OemToAnsi(STR0007) + " / " //"CPF esta vazio"
	EndIf

	//PIS
	If Empty((cAliasSRA)->RA_PIS)
		cMsgErro += OemToAnsi(STR0008) + " / " //"PIS est� vazio"
	EndIf

	//Nome Completo e Nome
	If Empty((cAliasSRA)->RA_NOMECMP) .And. Empty((cAliasSRA)->RA_NOME)
		cMsgErro += OemToAnsi(STR0009) + " / " //"Nome completo e Nome est�o vazios"
	EndIf

	//Data Nascimento
	If Empty((cAliasSRA)->RA_NASC) //Data nascimento vazia
		cMsgErro += OemToAnsi(STR0010) + " / " //"Data de nascimento esta vazia"
	EndIf

	If Empty(cMsgErro) //Adiciona informacoes no array
		aAdd(aInfoSRA, Array(Len(aCposTxt))) //Inicializa array para adicionar informacoes do funcionario

		//Busca todos os campos para geracao do arquivo
		For nI := 1 To Len(aCposTxt)
			If SX3->(dbSeek(aCposTxt[nI]))
				//Inicializa as variaveis de informacoes
				cCpoAux := ""
				cCpo    := ""

				If SX3->X3_TIPO == "D" //Campo Data
					cCpoAux := DToS(FieldGet(FieldPos(aCposTxt[nI])))

					If !Empty(cCpoAux)
						//Tratamento para gravacao em formato dia/mes/ano
						cCpo := Subs(cCpoAux, 7, 2)
						cCpo += Subs(cCpoAux, 5, 2)
						cCpo += Subs(cCpoAux, 1, 4)
					EndIf
				ElseIf SX3->X3_TIPO == "C" // Campo Caractere
					cCpoAux := AllTrim(FieldGet(FieldPos(aCposTxt[nI])))

					//Tratamento de tamanho das informacoes e gravacao de Nome caso Nome completpo esteja vazio
					If SX3->X3_CAMPO == "RA_NOMECMP" .And. Len(cCpoAux) > 60
						cCpo := Subs(cCpoAux, 1, 60)
					ElseIf SX3->X3_CAMPO == "RA_NOMECMP" .And. Empty(cCpoAux) //Nome completo vazio grava nome
						cCpo := AllTrim((cAliasSRA)->RA_NOME)
					Else
						cCpo := cCpoAux
					EndIf
				Else  //Campo Numerico
					cCpoAux := CValToChar(FieldGet(FieldPos(aCposTxt[nI])))
					cCpo    := cCpoAux
				EndIf
			EndIf

			aInfoSRA[Len(aInfoSRA), nI] := cCpo
		Next nI

		//Tratamento para funcionarios gerados no arquivo - LOG
 		cLogGera	:= 	DToC(dDataBase) + " - " + AllTrim((cAliasSRA)->RA_FILIAL) + " - "
 		cLogGera	+= 	AllTrim((cAliasSRA)->RA_MAT) + " - " + AllTrim((cAliasSRA)->RA_NOME)

		//Tratamento para tamanho do Log de funcionarios gerados no arquivo.
 		If Len(cLogGera) <= TAMIMP
 			aAdd(aLogGera, cLogGera)
 		Else
 			aAdd(aLogGera, Subs(cLogGera, 1, TAMIMP))
 			aAdd(aLogGera, Subs(cLogGera, TAMIMP + 1, Len(cLogGera) - TAMIMP))
 		EndIf
	Else //Adiciona registro no Log
		cMsgAux := DToC(dDataBase) + " - " + AllTrim((cAliasSRA)->RA_FILIAL) + " - "
		cMsgAux += AllTrim((cAliasSRA)->RA_MAT) + " - " + AllTrim((cAliasSRA)->RA_NOME) + " - "
		cMsgAux += Subs(cMsgErro, 1, Len(cMsgErro) - 3) //Remove barra " / " do final da string

		cMsgErro := cMsgAux

		//Tratamento para tamanho do Log
		If Len(cMsgErro) <= TAMIMP
			aAdd(aLogProc, cMsgErro)
		Else
			aAdd(aLogProc, Subs(cMsgErro, 1, TAMIMP))
			aAdd(aLogProc, Subs(cMsgErro, TAMIMP + 1, Len(cMsgErro) - TAMIMP))
		EndIf
    EndIf

	(cAliasSRA)->(dbSkip())
EndDo

//Se algum funcionario foi gerado no arquivo adiciona no log.
If Len(aLogGera) > 0
	Aadd( aLogProc,{})
	If nOpc == 1
		Aadd( aLogProc, OemToAnsi(STR0020))
	Else
		Aadd( alogProc, OemToAnsi(STR0021))
	Endif
	Aadd( aLogProc,{})
	For nGera = 1 to Len(aLogGera)
		aAdd(aLogProc,aLogGera[nGera])
	Next nGera
Endif

//Fecha alias que esta em uso
If (Select(cAliasSRA) > 0)
	(cAliasSRA)->(dbCloseArea())
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GetDire  �Autor  � Claudinei Soares   � Data � 26/06/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado no Pergunte para indicar o diretorio a ser gerado o  ���
���          � arquivo texto.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM024                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetDir()

Local mvRet:=Alltrim(ReadVar())
Local cFile

oWnd   := GetWndDefault()
cFile  := cGetFile("Arquivo Texto","Informe o nome do arquivo com a extens�o TXT:",,"C:\",.F.,GETF_LOCALHARD + GETF_RETDIRECTORY) ////"Arquivo Texto"###"Informe o nome do arquivo com a extens�o TXT:"

If Empty(cFile)
	Return(.F.)
Endif

cDrive := Alltrim(Upper(cFile))

&mvRet := cFile

If oWnd != Nil
	GetdRefresh()
EndIf

Return( .T. )
