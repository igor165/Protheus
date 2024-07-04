#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA855.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LOJA855	 ³ Autor ³ Vendas Cliente       ³ Data ³ 28/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina que abre o DBF importado na retaguarda Para PDA     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aDados[A]: registros que serao importados na lista de 	  ³±±
±±³          ³           presentes 					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA855()
Local cDirOri		:= Alltrim(SuperGetMV("MV_LJDRPDA",.F.,""))	//Diretorio definido em parametro
Local cDiretorio	:= IIf(Empty(cDirOri),"PDA",cDirOri)			//Diretorio onde serao salvos os arquivos para o PDA
Local cNomArq		:= "LISTA"										//Prefixo do nome do arquivo da lista, sera concatenado ao codigo da lista de presente
Local aDados		:= {}											//array contendo os registros que serao importados na lista de presentes
Local cAlias		:= GetNextAlias()								//Proximo nome de alias disponivel
Local cArqTMP		:= ""											//Nome do arquivo temporario
Local cTpArq		:= "Arquivos DBF (*.DBF)|*.DBF|"				//Tipo de arquivo
Local cDrive		:= ""											//Drive - SplitPath
Local cDir			:= ""											//Diretorio - SplitPath
Local cArqP			:= ""											//Nome arquivo - SplitPath
Local cExt			:= ""											//Extensao do arquivo - SplitPath
Local cSepDir		:= IIf(IsSrvUnix(),"/","\")					//Separador de diretorios
Local oTempTable	:= Nil		//Objeto da tabela temporária
Local aStruct		:= {}

//Verifico se o ultimo caracter e "\"
If SubStr(cDiretorio,Len(cDiretorio) - 1 ,1) <> cSepDir
	cDiretorio	:= cDiretorio + cSepDir
EndIf
//Verifico se o primeiro caracter e "\"
If SubStr(cDiretorio,1,1) <> cSepDir
	cDiretorio	:= cSepDir + cDiretorio
EndIf
//Crio o diretorio base da estrutura de arquivos
If !ExistDir(cDiretorio)
	MakeDir(cDiretorio)
	If Empty(cDirOri)
		PutMV("MV_LJDRPDA",cDiretorio)
		MsgAlert(STR0001 + " " + Upper(cDiretorio) + CRLF + STR0002 + " " + Upper(cDiretorio))  //"Foi criado um diretório para armazenamento de lista : "  //"O parâmetro MV_LJDRPDA foi configurado com : "
	Else
		MsgAlert(STR0003 + Upper(cDiretorio))
	Endif
Endif
//Verifico se a variavel de memoria existe e esta preenchida
If Type("M->ME1_CODIGO") == "U" .OR. ValType(M->ME1_CODIGO) <> "C"
	MsgInfo(STR0004,STR0005)
	Return aDados
Else
	cNomArq := cNomArq + Alltrim(M->ME1_CODIGO) + GetDBExtension()
EndIf
//verifico se o arquivo existe fisicamente no caminho especificado
If !File(cDiretorio + cNomArq)
	If !ApMsgYesNo(STR0006 + cDiretorio + cNomArq + STR0007,STR0008)    ///"O arquivo ("   ///") não foi encontrado, deseja procurar outro arquivo?"   ///  "Importacao dos registros do PDA"
		Return aDados
	Else
		If Empty(cArqTMP := cGetFile(cTpArq,,1,IIf(At(":",cDiretorio) == 0,cSepDir + STR0009 + cDiretorio,cDiretorio),.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE))  //"SERVIDOR"
			Return aDados
		Endif
		SplitPath(RTrim(cArqTMP),@cDrive,@cDir,@cArqP,@cExt)
		//Definir nome do arquivo
		cNomArq := cArqP + cExt
		//Se o diretorio for diferente do estabelecido, mover para pasta de destino de arquivos PDA
		If PadR(StrTran(Upper(cDrive + cDir),cSepDir,""),250) <> PadR(StrTran(Upper(cDiretorio),cSepDir,""),250)
			If !CpyT2S(cArqTMP,cDiretorio,.F.)
				MsgAlert(STR0006 + AllTrim(cArqTMP) + STR0010)              ///"O arquivo ("   ///") não pode ser copiado para o servidor, operação cancelada!"
				Return aDados
			Endif
		Endif		
	Endif
EndIf

aAdd(aStruct,{"PRODUTO" ,"C",TamSX3("B1_COD")[1]	,TamSX3("B1_COD")[2]	})
aAdd(aStruct,{"QUANT" 	,"N",TamSX3("ME2_QTDSOL")[1],TamSX3("ME2_QTDSOL")[2]})
aAdd(aStruct,{"VEND"	,"C",TamSX3("A3_COD")[1]	,TamSX3("A3_COD")[2]	})
aAdd(aStruct,{"LISTA"	,"C",TamSX3("ME1_CODIGO")[1],TamSX3("ME1_CODIGO")[2]})
aAdd(aStruct,{"EMPRESA"	,"C",Len(cEmpAnt)			,0						})
aAdd(aStruct,{"FILIAL"	,"C",Len(cFilAnt)			,0						})
			
//Cria tabela temporária
oTempTable := LjCrTmpTbl(cAlias, aStruct) 

//Sobe os registros na temporaria
dbUseArea( .T., "TOPCONN", (cDiretorio + cNomArq), cAlias, .F., .T.)

//Verifico se o alias foi aberto corretamente
If Select(cAlias) <> 0
	//Percorro todo o alias incluindo os itens no array
	While !(cAlias)->( Eof() )
		/*======================================================\
		|Estrutura da tabela de Lista importada do PDA			|
		|_______________________________________________________|
		|PRODUTO	-> Codigo do Produto						|
		|QUANT		-> Quantidade requisitada por produto		|
		|VEND		-> Codigo do Vendedor						|
		|LISTA		-> Codigo da Lista de Presentes				|
		|EMPRESA	-> Codigo da Empresa que realizou a leitura	|
		|FILIAL		-> Codigo da FIlial que realizou a leitura	|
		\======================================================*/
		aAdd(aDados,{	(cAlias)->PRODUTO,;
						(cAlias)->QUANT,;
						(cAlias)->VEND})
		
		(cAlias)->( DbSkip() )
	End		
	
	If( ValType(oTempTable) == "O")
	  oTempTable:Delete()
	  FreeObj(oTempTable)
	  oTempTable := Nil
	EndIf

Else
	MsgInfo(STR0011 + cDiretorio + cNomArq)
EndIf

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ855Imp  ºAutor  ³Vendas Cliente      º Data ³  03/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que efetua a importacao dos dados do PDA e grava um  º±±
±±º          ³arquivo DBF no diretorio especifico						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cEquip - Equipamento						 				  º±±
±±º			 ³ cItem  - Produto											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet[C]: mensagem 										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automacao Comercial										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ855Imp(cEquip,cItem)

Local cRet		:= STR0012											//Funcao usado como retorno  ///ok
Local cNomArq	:= "LISTA"											//Nome do arquivo na retaguarda
Local cArqTmp	:= ""												//Arquivo temporario
Local aStruct	:= {}												//Estrutura do arquivo na retaguarda
Local cProduto	:= ""												//Codigo do Produto
Local nQuant	:= 0												//Quantidade
Local cVend		:= ""												//Codigo do Vendedor
Local cLista	:= ""												//Codigo da Lista de Presentes
Local cEmpArq	:= ""												//Codigo da Empresa que efetuou a leitura dos itens
Local cFilArq	:= ""												//Codigo da Filial que efetuou a leitura dos itens
Local aItem		:= {}												//Array contendo os itens 
Local cDiretorio:= Alltrim(SuperGetMV("MV_LJDRPDA",,"PDA"))			//Diretorio onde serao salvos os arquivos para o PDA
Local cCaminho	:= ""												//Caminho do arquivo DBF contendo os itens lidos no PDA
Local oTempTable	:= Nil		//Objeto da tabela temporária

Default cEquip	:= ""
Default cItem	:= ""
               
ConOut(STR0013)    ////"LJ855Imp - Iniciando RPC - PDA "
//Verifico se o ultimo caracter e "\"
ConOut(STR0014 + cDiretorio)    ///"LJ855Imp - 1 - cDiretorio -> "
If SubStr(cDiretorio,Len(cDiretorio) - 1 ,1) <> "\"
	cDiretorio	:= cDiretorio + "\"
	ConOut(STR0015 + cDiretorio)    ////"LJ855Imp - 2 - cDiretorio -> "
EndIf

//Verifico se o primeiro caracter e "\"
If SubStr(cDiretorio,1,1) <> "\"
	cDiretorio	:= "\" + cDiretorio
	ConOut(STR0016 + cDiretorio)   ///"LJ855Imp - 3 - cDiretorio -> "
EndIf

//Crio o diretorio base da estrutura de arquivos
cCaminho := cDiretorio
MakeDir(cCaminho)

ConOut(STR0017)     ///"LJ855Imp - ConecTou na Retaguarda"

If Empty(cItem)
	cRet	:= STR0018      ////"ERRO - Item em Branco"
Else
	ConOut(STR0019)   ///"LJ855Imp - Item Preenchido"
	//Transformo a string em array para melhor tratamento
	aItem	:= StrToKarr(cItem,"|")
	If Len(aItem) <> 6
		Return STR0020     ////"ERRO - Quantidade de colunas diferente da preparada"
	Else
		ConOut(STR0021)     ////"LJ855Imp - Array com 6 itens"
		
		cProduto:= PadR(aItem[1],TamSX3("B1_COD")[1])
		nQuant	:= Val(aItem[2])
		cVend	:= PadR(aItem[3],TamSX3("A3_COD")[1])
		cLista	:= PadR(aItem[4],TamSX3("ME1_CODIGO")[1])
		cEmpArq	:= PadR(aItem[5],Len(cEmpAnt))
		cFilArq	:= PadR(aItem[6],Len(cFilAnt))
		
		//Determina o nome do arquivo como "LISTA" mais o codigo da lista
		cNomArq	:= cNomArq + Alltrim(cLista)
		ConOut(STR0022 + cNomArq)     ///"LJ855Imp - Nome do arquivo " 
	EndIf
	
	//Verifico se o Produto e valido
	DbSelectArea("SB1")
	DbSetOrder(1)
	If SB1->( DbSeek( xFilial("SB1") + cProduto ) )
		If SB1->( FieldPos("B1_MSBLQL") ) > 0
			If SB1->B1_MSBLQL == "1"
				Return STR0023      ////"ERRO - Produto bloqueado"
			EndIf
		EndIf
	Else
		Return STR0024     ////"ERRO - Produto nao encontrado"
	EndIf
	
	//Verifico se a quantidade é valida
	If nQuant <= 0
		Return STR0025    /////"ERRO - Quantidade Invalida"
	EndIf
	
	//Verifico se o Vendedor é Valido
	DbSelectArea("SA3")
	DbSetOrder(1)
	If SA3->( DbSeek( xFilial("SA3") + cVend) )
		If SA3->( FieldPos("A3_MSBLQL") ) > 0
			If SA3->A3_MSBLQL == "1"
				Return STR0026     ///"ERRO - Vendedor bloqueado"
			EndIf
		EndIf
	Else
		Return STR0027      ////"ERRO - Vendedor nao encontrado"
	EndIf
	ConOut(STR0028)    ///"LJ855Imp - Nenhum retorno falso nas validacoes"
	ConOut(STR0029 + cCaminho + cNomArq + GetDBExtension() )   ////"LJ855Imp - Verifica se o arquivo existe "
	
	If !File(cCaminho + cNomArq + GetDBExtension() )
		ConOut(STR0030)     ////"LJ855Imp - nao encontrou o arquivo"
		aAdd(aStruct,{"PRODUTO" ,"C",TamSX3("B1_COD")[1]	,TamSX3("B1_COD")[2]	})
		aAdd(aStruct,{"QUANT" 	,"N",TamSX3("ME2_QTDSOL")[1],TamSX3("ME2_QTDSOL")[2]})
		aAdd(aStruct,{"VEND"	,"C",TamSX3("A3_COD")[1]	,TamSX3("A3_COD")[2]	})
		aAdd(aStruct,{"LISTA"	,"C",TamSX3("ME1_CODIGO")[1],TamSX3("ME1_CODIGO")[2]})
		aAdd(aStruct,{"EMPRESA"	,"C",Len(cEmpAnt)			,0						})
		aAdd(aStruct,{"FILIAL"	,"C",Len(cFilAnt)			,0						})
		
		//Cria tabela temporária
		oTempTable := LjCrTmpTbl("LISTA", aStruct)

		ConOut(STR0031 + cArqTmp)        ///"LJ855Imp - Criou o arquivo "
		
		__CopyFile("\system\" + cArqTmp + GetDBExtension(),cCaminho + cNomArq + GetDBExtension() )
        ConOut(STR0032 + "\system\" + cArqTmp + GetDBExtension() + " para " + cCaminho + cNomArq + GetDBExtension())    //"LJ855Imp - Copia o arquivo de "

		fErase( "\system\" + cArqTmp + GetDBExtension() )
		ConOut(STR0033 + cArqTmp + GetDBExtension() )   ///"LJ855Imp - Exclui o arquivo "
	EndIf     

	ConOut(STR0034)   ///"LJ855Imp - Gravando Lista "
	RecLock("LISTA",.T.)
	LISTA->PRODUTO	:= cProduto
	LISTA->QUANT	:= nQuant
	LISTA->VEND		:= cVend
	LISTA->LISTA	:= cLista
	LISTA->EMPRESA	:= cEmpArq
	LISTA->FILIAL	:= cFilArq
	LISTA->( MsUnLock() )          
	ConOut(STR0035)     ///"LJ855Imp - Lista gravada"
EndIf

If( ValType(oTempTable) == "O")
  oTempTable:Delete()
  FreeObj(oTempTable)
  oTempTable := Nil
EndIf

Return cRet