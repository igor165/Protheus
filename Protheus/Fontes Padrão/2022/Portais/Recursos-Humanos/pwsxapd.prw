#INCLUDE "PROTHEUS.CH"
Function CriaAvaliacao(nReg)

Local aRdaHeader		:= {}	//01 -> Array com os Campos do Cabecalho da GetDados
Local aRdcHeader		:= {}	//01 -> Array com os Campos do Cabecalho da GetDados
Local aRdbHeader		:= {}	//01 -> Array com os Campos do Cabecalho da GetDados
Local nUsado			:= 0  	//02 -> Numero de Campos em Uso
Local aVirtual			:= {}	//03 -> [@]Array com os Campos Virtuais
Local aVisual			:= {}	//04 -> [@]Array com os Campos Visuais
Local aRecnos			:={}	//07 -> [@]Array unidimensional contendo os Recnos
Local cKey				:=""	//09 -> Chave para o Posicionamento no Alias Filho
Local aFieldsAux		:={}	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
Local aArea				:= GetArea()
Local aRdaCols			:= {}
Local aRdcCols			:= {}
Local aRdbCols			:= {}
Local aAltera			:= {}
Local aNaoAltera		:= {}

Local nCodAdo 			:= 0
Local nCodDor	 		:= 0
Local nTpAv 			:= 0
Local nCodTip 			:= 0
Local nLoop				:= 0
Local nC				:=0
Local nPos				:=0
Local nDtRet	 		:= 0

Private nGetSX8Len		:= GetSX8Len()

DEFAULT  nReg		:=1
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Informacoes - RDA - Itens Avaliados vs Avaliadores                                       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
dbselectArea("RDA")
dbSetOrder(RetOrdem("RDA","RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+RDA_CODDOR+DTOS(RDA_DTIAVA)+RDA_CODNET+RDA_NIVEL+RDA_TIPOAV"))
dbGoto(nReg)
cKey:=RDA_CODAVA+RDA_CODADO+RDA_CODPRO+RDA_CODDOR+DTOS(RDA_DTIAVA)+RDA_CODNET+RDA_NIVEL+RDA_TIPOAV
cKeyAux:=""
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Reinicializa as Variaveis									   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdaCols		:= {}
aAltera			:= {}
aNaoAltera		:= { "RDA_CODAVA" , "RDA_CODADO" , "RDA_DTIAVA" , "RDA_DTFAVA" , "RDA_CODTIP" , "RDA_CODNET" , "RDA_NIVEL" }
aRecnos			:= {}
aFields			:= {}
bSkip			:= { || .F. }
bKey			:= NIL

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carregando as Informacoes                                    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdaCols := GdBuildCols(	@aRdaHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
					@nUsado			,;	//02 -> Numero de Campos em Uso
					@aVirtual		,;	//03 -> [@]Array com os Campos Virtuais
					@aVisual 		,;	//04 -> [@]Array com os Campos Visuais
					"RDA"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
					NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
					@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
					"RDA"			,;	//08 -> Alias do Arquivo Pai
					xFilial("RDA")+cKey,;	//09 -> Chave para o Posicionamento no Alias Filho
					NIL				,;	//10 -> Bloco para condicao de Loop While
					NIL				,;	//11 -> Bloco para Skip no Loop While
					.T.				,;	//12 -> Se Havera o Elemento de Delecao no aRdaCols
					.T.				,;	//13 -> Se Sera considerado o Inicializador Padrao
					.F.				,;	//14 -> Opcional, Carregar Todos os Campos
					.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
					NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
					.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					aFieldsAux		,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
					.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
					.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
					.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
					.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aRdaCols
					NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
					NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
					NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
					NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
					.T.				 ;	//28 -> Utiliza Numeracao na GhostCol
				 )

nCodAdo := GdFieldPos( "RDA_CODADO" , aRdaHeader )
nCodDor := GdFieldPos( "RDA_CODDOR" , aRdaHeader )
aRdaCols[1,nCodDor]:=aRdaCols[1,nCodAdo]

nTpAv := GdFieldPos( "RDA_TIPOAV" , aRdaHeader )

aRdaCols[1,nTpAv]:="2"

nCodTip := GdFieldPos( "RDA_CODTIP" , aRdaHeader )
nCodNet := GdFieldPos( "RDA_CODNET" , aRdaHeader )
nNivel  := GdFieldPos( "RDA_NIVEL"  , aRdaHeader )

cKeyAux := RDA->( RDA_CODAVA + aRdaCols[1,nCodAdo] + RDA_CODPRO + aRdaCols[1,nCodDor] + DTOS(RDA_DTIAVA) + aRdaCols[1,nCodNet] + aRdaCols[1,nNivel] + aRdaCols[1,nTpAv] )

//Se ja existir avaliacao, nao grava outra
IF DbSeek( xFilial("RDA")+cKeyAux )
	RestArea(aArea)
	Return Nil
EndIF

dbSelectArea("RDH")
dbSetOrder(1)    		//RDH_FILIAL+RDH_CODTIP+RDH_CODNET+RDH_NIVEL
dbSeek(xFilial("RDH")+aRdaCols[1,nCodTip],.f.)
While RDH->(!Eof()).And.xFilial("RDH")+aRdaCols[1,nCodTip]==RDH_FILIAL+RDH_CODTIP
	If RDH->RDH_NIVEL=="1"
		aRdaCols[1,nCodNet]:=RDH->RDH_CODNET
		aRdaCols[1,nNivel] :=RDH->RDH_NIVEL
		Exit
	EndIf
	RDH->(dbSkip())
End
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Informacoes - RDC - Itens Avaliados vs Avaliadores                                       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdcHeader		:= {}	//01 -> Array com os Campos do Cabecalho da GetDados
nUsado			:= 0  	//02 -> Numero de Campos em Uso
aVirtual		:= {}	//03 -> [@]Array com os Campos Virtuais
aVisual			:= {}	//04 -> [@]Array com os Campos Visuais
aRecnos			:= {}	//07 -> [@]Array unidimensional contendo os Recnos
aFieldsAux		:={}	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
nLoop			:= 0

RDC->(dbSetOrder(RetOrdem( "RDC" , "RDC_FILIAL+RDC_CODAVA+RDC_CODADO+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV")))
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Reinicializa as Variaveis									   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdcCols		:= {}
aAltera			:= {}
aNaoAltera		:= {}
aRecnos			:= {}
aFields			:= {}
bSkip			:= { || .F. }
bKey			:= NIL
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Informacoes   									   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdcCols := GdBuildCols(	@aRdcHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
					@nUsado			,;	//02 -> Numero de Campos em Uso
					@aVirtual		,;	//03 -> [@]Array com os Campos Virtuais
					@aVisual		,;	//04 -> [@]Array com os Campos Visuais
					"RDC"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aRdaCols
					NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
					@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
					"RDC"			,;	//08 -> Alias do Arquivo Pai
					xFilial("RDC")+cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
					NIL				,;	//10 -> Bloco para condicao de Loop While
					NIL				,;	//11 -> Bloco para Skip no Loop While
					.T.				,;	//12 -> Se Havera o Elemento de Delecao no aRdaCols
					.T.				,;	//13 -> Se Sera considerado o Inicializador Padrao
					.F.				,;	//14 -> Opcional, Carregar Todos os Campos
					.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
					NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
					.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					aFieldsAux		,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
					.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
					.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
					.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
					.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aRdaCols
					NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
					NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
					NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
					NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
					.T.				 ;	//28 -> Utiliza Numeracao na GhostCol
				 )

nCodAdo := GdFieldPos( "RDC_CODADO" , aRdcHeader )
nCodDor := GdFieldPos( "RDC_CODDOR" , aRdcHeader )
aRdcCols[1,nCodDor]:=aRdcCols[1,nCodAdo]

//nDtRet	 := GdFieldPos( "RDC_DATRET" , aRdcHeader )
//aRdcCols[1,nDtRet]:=cToD("//")

nTpAv := GdFieldPos( "RDC_TIPOAV" , aRdcHeader )
aRdcCols[1,nTpAv]:="2"

nCodTip := GdFieldPos( "RDC_CODTIP" , aRdcHeader )
nCodNet := GdFieldPos( "RDC_CODNET" , aRdcHeader )
nNivel  := GdFieldPos( "RDC_NIVEL"  , aRdcHeader )

dbSelectArea("RDH")
dbSetOrder(1)    		//RDH_FILIAL+RDH_CODTIP+RDH_CODNET+RDH_NIVEL
dbSeek(xFilial("RDH")+aRdcCols[1,nCodTip],.f.)
While RDH->(!Eof()).And.xFilial("RDH")+aRdcCols[1,nCodTip]==RDH_FILIAL+RDH_CODTIP
	If RDH->RDH_NIVEL=="1"
		aRdcCols[1,nCodNet]:=RDH->RDH_CODNET
		aRdcCols[1,nNivel] :=RDH->RDH_NIVEL
		Exit
	EndIf
	RDH->(dbSkip())
End
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Informacoes - RDB - Itens Respostas de Avaliacoes                                        ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdbHeader		:= {}	//01 -> Array com os Campos do Cabecalho da GetDados
nUsado			:= 0  	//02 -> Numero de Campos em Uso
aVirtual		:= {}	//03 -> [@]Array com os Campos Virtuais
aVisual			:= {}	//04 -> [@]Array com os Campos Visuais
aRecnos			:= {}	//07 -> [@]Array unidimensional contendo os Recnos
aFieldsAux		:={}	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
nLoop			:= 0
aAltera			:= {}
aNaoAltera		:= {}
aRecnos			:= {}
aFields			:= {}
bSkip			:= { || .F. }
bKey			:= NIL

dbselectArea("RDA")
dbgoto(nReg)
cKey:=RDA_CODAVA+RDA_CODADO+RDA_CODPRO+RDA_CODDOR+DTOS(RDA_DTIAVA)+RDA_CODNET+RDA_TIPOAV

RDB->(dbSetOrder(RetOrdem( "RDB" , "RDB_FILIAL+RDB_CODAVA+RDB_CODADO+RDB_CODPRO+RDB_CODDOR+DTOS(RDB_DTIAVA)+RDB_CODNET+RDB_TIPOAV")))
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Informacoes   									   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
aRdbCols := GdBuildCols(	@aRdbHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
					@nUsado			,;	//02 -> Numero de Campos em Uso
					@aVirtual		,;	//03 -> [@]Array com os Campos Virtuais
					@aVisual		,;	//04 -> [@]Array com os Campos Visuais
					"RDB"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aRdbCols
					NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
					@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
					"RDB"			,;	//08 -> Alias do Arquivo Pai
					xFilial("RDB")+cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
					NIL				,;	//10 -> Bloco para condicao de Loop While
					NIL				,;	//11 -> Bloco para Skip no Loop While
					.T.				,;	//12 -> Se Havera o Elemento de Delecao no aRdaCols
					.T.				,;	//13 -> Se Sera considerado o Inicializador Padrao
					.F.				,;	//14 -> Opcional, Carregar Todos os Campos
					.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
					NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
					.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					aFieldsAux		,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
					.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
					.F.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
					.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
					.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aRdaCols
					NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
					NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
					NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
					NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
					.T.				 ;	//28 -> Utiliza Numeracao na GhostCol
				 )

nCodAdo := GdFieldPos( "RDB_CODADO" , aRdbHeader )
nCodDor := GdFieldPos( "RDB_CODDOR" , aRdbHeader )
nTpAv	:= GdFieldPos( "RDB_TIPOAV" , aRdbHeader )
nCodTip := GdFieldPos( "RDB_CODTIP" , aRdbHeader )
nCodNet := GdFieldPos( "RDB_CODNET" , aRdbHeader )
nCodMem := GdFieldPos( "RDB_CODMEM" , aRdbHeader )

//Posicionando o registro da rede
dbSelectArea("RDH")
dbSetOrder(1)    		//RDH_FILIAL+RDH_CODTIP+RDH_CODNET+RDH_NIVEL
dbSeek(xFilial("RDH")+aRdbCols[1,nCodTip],.F.)
While RDH->(!Eof()).And.xFilial("RDH")+aRdbCols[1,nCodTip]==RDH_FILIAL+RDH_CODTIP
	If RDH->RDH_NIVEL=="1"
		Exit
	EndIf
	RDH->(dbSkip())
End
nLoops:=Len(aRdbCols)
For nLoop := 1 To nLoops
	aRdbCols[nLoop,nCodDor]	:=aRdbCols[nLoop,nCodAdo]
	aRdbCols[nLoop,nTpAv]	:="2"
	aRdbCols[nLoop,nCodNet]	:=RDH->RDH_CODNET
Next nLoop
/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Duplicacoes das avaliacoes Iniciar gravacoes                 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Begin Transaction
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ RDA - Itens Avaliados vs Avaliadores                         ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	nLoops := RDA->(FCount())
	RDA->( RecLock( "RDA" , .T. ) )
	For nLoop := 1 To nLoops
		If (nPos := GdFieldPos( RDA->(Field(nLoop)), aRdaHeader ))<>0
			RDA->( FieldPut(nLoop, aRdaCols[1,nPos]))
		EndIf
	Next nLoop
	RDA->( MsUnLock() )
	RDA->( FkCommit() )
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ RDC - Itens Envio/Retorno Avaliacoes                         ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	nLoops := RDC->(FCount())
	RDC->( RecLock( "RDC" , .T. ) )
	For nLoop := 1 To nLoops
		If (nPos := GdFieldPos( RDC->(Field(nLoop)), aRdcHeader ))<>0
			RDC->( FieldPut(nLoop, aRdcCols[1,nPos]))
		EndIf
	Next nLoop
	RDC->(FieldPut(FieldPos("RDC_ID"),RdcIdInit()))
	RDC->(FieldPut(FieldPos("RDC_ATIVO"),RdcAtivoInit()))
	RDC->(MsUnLock())
	RDC->(FkCommit())
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ RDB - Itens Respostas de Avaliacoes                          ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	nLoops := RDB->(FCount())
	For nC:=1 to Len(aRdbCols)
		RDB->( RecLock( "RDB" , .T. ) )
		For nLoop := 1 To nLoops
			If (nPos := GdFieldPos( RDB->(Field(nLoop)), aRdbHeader ))<>0
				If RDB->(Field(nLoop)) == "RDB_ID"
				    RDB->( FieldPut(nLoop, RDC->RDC_ID ))
				Else
					RDB->( FieldPut(nLoop, aRdbCols[nC,nPos]))
				EndIf
			EndIf
		Next nLoop
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Gravando so memos                                            ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
        If !empty(aRdbCols[nC,nCodMem])
			cRdbMem := ApdMsMm( aRdbCols[nC,nCodMem] )
			cCodMem:=ApdMsmm(,,,cRdbMem,1,,,"RDB","RDB_CODMEM")
		EndIf
		RDB->( MsUnLock() )
		RDB->( FkCommit() )
    Next nC
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Confirmando a Numeracao Automatica          				   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While
End Transaction
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetNivelCarreira บAutor  ณAlexandre Silva      บ Data ณ  28/03/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o nivel da carreira e o nivel hierarquico	     		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             		  บฑฑ
ฑฑบ          ณ                                                             		  บฑฑ
ฑฑบ          ณ                                                             		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   		  บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function getNivelCarreira(cCodParticipante,; // Codigo do Participante
									lDemitido) // Se considera funcionario demitido
	default cCodParticipante = ""
	Local aRet				:= {}
	local aFuncDetail		:= {}
	local aAreaSRA			:= {}
	local aArea				:= getArea()
	local cCargo			:= ""
	local cClasse			:= ""
	local lPosSq3 			:= .t.  
	
	Default lDemitido	:= .F.

	dbSelectArea("SRA")
	aAreaSRA := getArea()

	If ! Empty(cCodParticipante) .and. Participant(cCodParticipante,aRet,lDemitido)
   	    If len(aRet) > 0
	   		SRA->(dbSetOrder(1))
			SRA->(MsSeek(aRet[3]+aRet[1]))//SRA->RA_MAT
	
			If ! Empty(SRA->RA_CARGO)
				IF Empty((cCargo := AllTrim(FDesc("SQ3"   ,SRA->RA_CARGO+SRA->RA_CC,"Q3_DESCSUM" , NIL , SRA->RA_FILIAL))))  
						  cCargo := AllTrim(FDesc("SQ3",SRA->RA_CARGO,"Q3_DESCSUM", NIL, SRA->RA_FILIAL))
				Endif
			Else
				cCodCargo := FDesc("SRJ", SRA->RA_CODFUNC ,"RJ_CARGO", NIL, SRA->RA_FILIAL)
				If !Empty(cCodCargo)
					IF Empty((cCargo := AllTrim(FDesc("SQ3",cCodCargo+SRA->RA_CC,"Q3_DESCSUM", NIL, SRA->RA_FILIAL))))
						  cCargo := AllTrim(FDesc("SQ3",cCodCargo,"Q3_DESCSUM", NIL, SRA->RA_FILIAL))
					Endif
				Else
					lPosSq3 := .f.
					cCargo := FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC", NIL, SRA->RA_FILIAL)
				EndIf
			Endif
		
				If(lPosSq3)
					cClasse := AllTrim(Fdesc("RBF",SQ3->Q3_CLASSE,"RBF_DESC", NIL, SRA->RA_FILIAL))
				Endif
				                  
		EndIf	
	Endif	
	aadd(aFuncDetail,cClasse)
	aadd(aFuncDetail,cCargo) 		
	
	restArea(aAreaSRA)
	restArea(aArea)

Return aFuncDetail


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetFunCCDesc     บAutor  ณAlexandre Silva      บ Data ณ  28/03/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao do centro de custo do funcionario     		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             		  บฑฑ
ฑฑบ          ณ                     x                                         		  บฑฑ
ฑฑบ          ณ                                                             		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   		  บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function getFunCCDesc(CodParticipante,;// Codigo do Participante
							lDemitido) // Se considera funcionario demitido
	default CodParticipante = ""

	local cCCDes	 	:= ""
	local cCC			:= ""
	local aArea			:= getArea()
	local aAreaSRA		:= {}
	local aRet			:= {}    
	
	Default lDemitido	:= .F.

	dbSelectArea("SRA")
	aAreaSRA := getArea()

	If ! Empty(CodParticipante) .and. Participant(CodParticipante,aRet, lDemitido)
		If len(aRet)> 0
		
			SRA->(dbSetOrder(1))
			SRA->(MsSeek(aRet[3]+aRet[1]))
		
			cCC 	:= EntGetInfo("SRA","RA_CC",RD0->RD0_CODIGO,,SRA->RA_FILIAL)
			dbselectArea("CTT")
			If !Empty(cCC)
				cCCDes	:= FDesc("CTT"   , cCC    , "CTT_DESC01" , NIL, SRA->RA_FILIAL)
			EndIf

		EndIf
	Endif
	restArea(aAreaSRA)
	restArea(aArea)

return cCCDes


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณRhTreeRecursivณ Autor ณEmerson Grassi RochaณData ณ12.05.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณMetodo que consulta item de competencia para montar tree	   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ												               ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpL1: Array com retorno da tree					           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ APD/RH/Portais                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function RhTreeRecursiv( cCodigo, cTree, cItem, aTree )
Local lRetorno	:= .T.
Local aArea 	:= RD2->( GetArea() )
Local cAliasRD2 := "RD2"
Local nLen 		:= 0

DEFAULT cItem := "000000"

( cAliasRD2 )->( DbSetOrder( 2 ) )

If ( cAliasRD2 )->( MsSeek( xFilial( "RD2" ) + cCodigo + cItem ) )
	While !( cAliasRD2 )->( EOF() ) .AND. ;
		( cAliasRD2 )->RD2_FILIAL == xFilial( "RD2" ) .AND. ;
		( cAliasRD2 )->RD2_CODIGO == cCodigo .AND. ;
		( cAliasRD2 )->RD2_TREE == cItem

		If Empty( aTree )
			aTree := {}
		EndIf
		aAdd( aTree,{"","","","","" } )
		nLen := Len( aTree )
		aTree[nlen][1]		:= ( cAliasRD2 )->RD2_CODIGO 		//Competencia
		RDM->(DbSetOrder(1))
		If RDM->( MsSeek(xFilial("RDM")+( cAliasRD2 )->RD2_CODIGO) )
			aTree[nlen][2] 	:= RDM->RDM_DESC					//Desc. Competencia
		EndIf
		aTree[nlen][3]	:= ( cAliasRD2 )->RD2_ITEM				//Item competencia
		aTree[nLen][4] 	:= AllTrim( ( cAliasRD2 )->RD2_DESC )  //Desc. item competencia
		aTree[nLen][5] 	:= ( cAliasRD2 )->RD2_TREE				//Tree

		RhTreeRecursiv( cCodigo, ( cAliasRD2 )->RD2_TREE, ( cAliasRD2 )->RD2_ITEM, aTree[nLen] )

		( cAliasRD2 )->( DbSkip() )
	EndDo
EndIf

RestArea( aArea )

Return lRetorno


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RhRetItem 	ณ Autor ณEmerson Grassi RochaณData ณ12.05.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณRetorna Array com todos os itens de competencia da estrutura ณฑฑ
ฑฑณ			 ณdo aTree na ordem da estrutura.							   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ												               ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpL1: Array com retorno da tree					           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ APD/RH/Portais                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function RhRetItem(aTreeItem, aListItem)
Local nX		:= 0
Local nLoops 	:= Len(aTreeItem) - 5

aadd(aListItem,aTreeItem[3])
For nX:= 1 to nLoops
	RhRetItem(aTreeItem[nX+5],@aListItem)
Next nx

Return Nil
