#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA020.CH"

Static lTrm020Hab 	:= ExistBlock("TRM020HAB")
Static lIntTAF    	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lCargSQ3	  	:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVersGPE   	:= ""
Static cVersEnvio 	:= "" 
Static lMsbql

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ TRMA020  ³ Autor ³ Mauro Sergio      		      ³ Data ³ 12.11.1998   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o    ³ Controle dos programas do Cargo		  			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ Nenhum                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC            ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr.  ³18/07/2014³          TPUT21³Subindo fonte para P12. Retirada de ajustas³±±
±±³Sidney O.    ³18/09/2014³          TQFBV1³Removido os campos Q3_DESCDET, Q3_DRESP,   ³±±
±±³             ³          ³                ³Q3_DRELINT e Q3_DHABILI. Deixado apenas os ³±±
±±³             ³          ³                ³MEMOS desses campos                        ³±±
±±³Allyson M    ³28/10/2014³          TQWABB³Ajuste p/ efetuar carga inicial dos dados  ³±±
±±³             ³          ³                ³da tabela SQ4.	 							³±±
±±³Renan Borges ³22/01/2015³          TRIEOJ³Ajuste para incluir cargo no módulo de trei³±±
±±³             ³          ³                ³namento corretamente, pois campo de pontos ³±±
±±³             ³          ³                ³dos fatores de avaliações é utilizado ape- ³±±
±±³             ³          ³                ³nas no módulo de cargos e salários.        ³±±
±±³Thiago Y.M.N ³02/02/2015³          TRGFX2³Ajuste para carregar os fatores de avalia- ³±±
±±³             ³          ³                ³coes corretamente, ao realizar a carga ini-³±±
±±³             ³          ³                ³cial tanto na inclusão quanto na alteracao ³±±
±±³             ³          ³                ³sistema trara apenas 1 registro de cada fa-³±±
±±³             ³          ³                ³tor.                                       ³±±
±±³Luis Artuso  ³21/10/2015³          TTJKCZ³Ajuste para retirar limite de inclusão de  ³±±
±±³             ³          ³                ³registros por Fator na tabela SQ4          ³±±
±±³Allyson M    ³24/06/2016³          TVLFGZ³Ajuste p/ exibir campos de classe salarial ³±±
±±³Renan T.M.   ³09/03/2017³        MRH-8130³Ajustada a função Tr020CC para nao gerar   ³±±
±±³             ³          ³                ³erro no cadastro sem interface             ³±±
±±³Marcelo F.   ³14/03/2017³        MRH-7343³Ajuste no campo de pontuação dos fatores do³±±
±±³             ³          ³      Tkt 526498³cargo para permitir atualização após carga ³±±
±±³             ³          ³                ³inicial do grupo                           ³±±
±±³Oswaldo L    ³30-05-17  ³DRHPONTP-71     ³Evitar duplicar RDY ao alterar campo MEMO ³±±
±±³Isabel N.    ³14/06/2017³  DRHPONTP-832  ³Ajuste p/exibir campo Q3_MSBLQL se existir.³±±
±±³Renan Borges ³23/06/2017³    DRHPONTP-999³Ajuste para que seja permitido alterar os  ³±±
±±³             ³          ³                ³campos de grupo e de centro de custo do ca-³±±
±±³             ³          ³                ³dastro de cargos caso não haja registros ca³±±
±±³             ³          ³                ³dastrados, com essas informações, nas tabe-³±±
±±³             ³          ³                ³las SQ4, RA5 e RBH.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMA020()
	LOCAL cFiltra := ""    //Variavel para filtro
	LOCAL aIndFil := {}    //Variavel Para Filtro
	Local nErro   := 0
	Local cErros  := ""

	Private bFiltraBrw	:= {|| Nil}                         //Variavel para Filtro
	Private cCadastro	:= OemToAnsi(STR0001)               //"Cargos"
	Private aRotina    	:= MenuDef()                        // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	Private lRspHab		:= SuperGetMv( "MV_RSPHAB",, .F. )  //Exibe Habilidades no cadastro de cargos do SIGARSP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste o Modo de Acesso dos Arquivos                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nErro := 0

   If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) <> ;
      (FWModeAccess( "SQ4", 1) + FWModeAccess( "SQ4", 2) + FWModeAccess( "SQ4", 3))
       //"O Modo de Acesso do relacionamento para a tabela de Fatores do Cargo deve seguir o mesmo modo que o cadastro de cargos!"
       //"Altere o modo de acesso atraves do Configurador. Arquivos SQ4 e SQ3."
       MsgInfo( oEmToAnsi( STR0050 ) + CRLF + CRLF + oEmToAnsi( STR0051 ) )
       nErro := 1
    EndIf

   If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) <> ;
      (FWModeAccess( "RA5", 1) + FWModeAccess( "RA5", 2) + FWModeAccess( "RA5", 3))
       //"O Modo de Acesso do relacionamento para a tabela de Cursos do Cargo deve seguir o mesmo modo que o cadastro de cargos!"
       //"Altere o modo de acesso atraves do Configurador. Arquivos RA5 e SQ3."
       MsgInfo( oEmToAnsi( STR0052 ) + CRLF + CRLF + oEmToAnsi( STR0053 ) )
       nErro := 1
    EndIf

   If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) <> ;
      (FWModeAccess( "RBH", 1) + FWModeAccess( "RBH", 2) + FWModeAccess( "RBH", 3))
       //"O Modo de Acesso do relacionamento para a tabela de Habildades do Cargo deve seguir o mesmo modo que o cadastro de cargos!"
       //"Altere o modo de acesso atraves do Configurador. Arquivos RBH e SQ3."
       MsgInfo( oEmToAnsi( STR0054 ) + CRLF + CRLF + oEmToAnsi( STR0055 ) )
       nErro := 1
   EndIf

    If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
       (FWModeAccess( "SQ0", 1) + FWModeAccess( "SQ0", 2) + FWModeAccess( "SQ0", 3)) // Grupos
	    cErros += STR0059 + CRLF
    	nErro := 1
    EndIf

    If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
      (FWModeAccess( "SQ1", 1) + FWModeAccess( "SQ1", 2) + FWModeAccess( "SQ1", 3)) // Fatores de avaliação
	    cErros += STR0060 + CRLF
        nErro := 1
    EndIf

    If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
       (FWModeAccess( "SQ2", 1) + FWModeAccess( "SQ2", 2) + FWModeAccess( "SQ2", 3)) // Graduação dos fatores
		cErros += STR0061 + CRLF
        nErro := 1
    EndIf

   If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
      (FWModeAccess( "RBK", 1) + FWModeAccess( "RBK", 2) + FWModeAccess( "RBK", 3)) //Escala grau de importância
	   cErros += STR0062 + CRLF
       nErro := 1
   EndIf

   If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
      (FWModeAccess( "RDM", 1) + FWModeAccess( "RDM", 2) + FWModeAccess( "RDM", 3)) //Competências
	   cErros += STR0063 + CRLF
       nErro := 1
   EndIf

	If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
      (FWModeAccess( "RD2", 1) + FWModeAccess( "RD2", 2) + FWModeAccess( "RD2", 3)) //Itens da Competências
	   cErros += STR0064 + CRLF
       nErro := 1
    EndIf

    If (FWModeAccess( "SQ3", 1) + FWModeAccess( "SQ3", 2) + FWModeAccess( "SQ3", 3)) < ;
      (FWModeAccess( "SQV", 1) + FWModeAccess( "SQV", 2) + FWModeAccess( "SQV", 3)) // Fatores de avaliação geral
	   cErros += STR0065 + CRLF
       nErro := 1
    EndIf

	If !Empty(cErros)
		MsgInfo( oEmToAnsi( STR0066 ) + CRLF + CRLF + oEmToAnsi( cErros ) )
	End if

   If nErro > 0
      Return (.F.)
   Endif  

	If lIntTAF .And. FindFunction("fVersEsoc") .And. lCargSQ3
		fVersEsoc("S1030", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
		If FindFunction("ESocMsgVer") .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
			//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento não será integrado com o TAF, e consequentemente, não será enviado ao RET.
			//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
			If ESocMsgVer(.F.,"S-1030", cVersGPE, cVersEnvio)
				lIntTaf := .F.
			Else
				Return
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQ3")
	dbSetOrder(1)

	cFiltra 	:= CHKRH(FunName(),"SQ3","1")
	bFiltraBrw 	:= {|| FilBrowse("SQ3", @aIndFil, @cFiltra) }
	Eval(bFiltraBrw)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQ3")
	dbGoTop()

	//mBrowse( 6, 1,22,75,"SQ3")
	MBrowse(NIL, NIL, NIL, NIL, "SQ3")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SQ3", aIndFil)

	dbSelectArea("SQ3")
	dbSetOrder(1)

	dbSelectArea("SRJ")
	dbSetOrder(1)

	dbSelectArea("RA5")
	dbSetOrder(1)

	dbSelectArea("RBH")
	dbSetOrder(1)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TRM020Rot ³ Autor ³ Mauro Sergio         ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra o Tree dos Cargos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TRM020Rot(cAlias,nReg,nOpcx,aCpos)
	Local oDlgMain
	Local oTree
	Local nOpca 	:= 0
	Local lVerFat 	:= .T.
	Local aFields	:= {}
	Local aAC		:= { STR0007,STR0008 }		//"Abandona"###"Confirma"
	Local aAlter	:= {}
	Local nx		:= 0
	Local nUsaHab	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para Dimensionar Tela		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aTreeCoords	:= {}
	Local aEnchCoords	:= {}
	Local aGetDCoords	:= {}

	Local cMmField    	:= "Q3_DESCDET, Q3_DRESP, Q3_DRELINT, Q3_DHABILI"
	Local nPosRec

	Local aAcho := {}

	Private lExistCargo := .F.

	Private nOpcao		:= nOpcx
	Private nRecno		:= nReg
	Private lCopy		:= (nOpcx == 6)

	Private lObj2		:= .F.
	Private lObj3		:= .F.
	Private lObj4		:= .F.
	Private aLisPast	:= Array(4)

	//-- Private da Getdados
	Private aCols  	:= {}
	Private aHeader	:= {}
	Private nUsado 	:= 0
	Private Continua:= .F.

	//-- Variaveis para Ponto de Entrada
	Private lVisual := (nOpcx == 2)
	Private lInclui := (nOpcx == 3)
	Private lExclui := (nOpcx == 5)

	//-- Controle do Treinamento
	Private cChave	:= ""
	Private cChavRBH:= ""
	Private cCargo1	:= ""
	Private cCC1	:= ""
	Private cDesc	:= ""
	Private cGrupo	:= ""
	Private nRecSq3	:= Recno()
	Private cEstou	:= "1"
	Private cIndo	:= ""
	Private oObjAtu, oSay1, oGet1
	Private oEnchoice

	Private nRegMaxSQ4:= ( 36 ^ GetSx3Cache("Q4_GRAU","X3_TAMANHO") )
	// Private dos objetos da Graduacao
	Private o2Get

	// Private dos objetos do Cursos do Cargo
	Private o3Get

	// Private dos objetos das Habilidades do Cargo
	Private o4Get

	// Private dos objetos da Enchoice
	Private aTELA[0][0],aGETS[0]
	bCampo := {|nCPO| Field(nCPO) }

	// Verifica se existem todos os Fatores de Avaliacao no SQV.
	// Considera apenas alteracao
	If 	nOpcx == 4
		Processa({||Tr020VerF(@lVerFat,SQ3->Q3_FILIAL,SQ3->Q3_CARGO,SQ3->Q3_CC)},OemToAnsi(STR0029)) // "Aguarde... Verificando Fat. Avaliacao no Cad. Geral Avaliacao"
		If !lVerFat
			Help("",1,"Tr020SQ4")	// Verifique os fatores de avaliacao no cadastro geral
			Return .F.
		EndIf
	EndIf

	If nOpcx != 3 	// Diferente de Inclusao
		cChave	:= SQ3->Q3_FILIAL + SQ3->Q3_CARGO + SQ3->Q3_CC
		cChavRBH:= SQ3->Q3_FILIAL + SQ3->Q3_GRUPO + SQ3->Q3_CARGO + SQ3->Q3_CC
		cCargo1	:= SQ3->Q3_CARGO
		cCC1	:= SQ3->Q3_CC
		cGrupo 	:= SQ3->Q3_GRUPO

		If lCopy  	//Copia de Cargo

			M->Q3_CARGO := CriaVar("Q3_CARGO")
		EndIf

	Else
		cCargo1	:= CriaVar("Q3_CARGO")
		cCC1	:= CriaVar("Q3_CC")
		RollBackSX8()	//Retornar Numero anterior devido InitPad abaixo.

		cChave	:= xFilial("SQ3") + cCargo1 + cCC1
		cGrupo 	:= CriaVar("Q3_GRUPO")
		cChavRBH:= xFilial("SQ3") + cGrupo + cCargo1 + cCC1
	EndIf

	//-- 1- Especificacao dos Cargos - SQ3
	If nOpcx == 3
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SQ3")

		While ( !Eof() .And. (SX3->X3_ARQUIVO == "SQ3") )
			cCampo := SX3->X3_CAMPO
			M->&(cCampo) := CriaVar(SX3->X3_CAMPO)
			dbSelectArea("SX3")
			dbSkip()
		EndDo
	Else
		cCampo := {|nCPO| Field(nCPO) }

		For nx := 1 TO FCount()
			If !lCopy .Or. (lCopy .And. EVAL(cCampo,nx) != "Q3_CARGO")
				If !( EVAL(cCampo,nx) $ cMmField )
					M->&(EVAL(cCampo,nx)) := FieldGet(nx)
				Else
					M->&(EVAL(cCampo,nx)) := Space( GetSx3Cache( EVAL(cCampo,nx), "X3_TAMANHO" ) )
				EndIf
			EndIf
		Next nx
	EndIf

	//-- 2- Graduacao dos Cargos - SQ4

	aAlter	:= {"Q4_FATOR","Q4_GRAU","Q4_PONTOS"}
	TrmUsrAlter(@aAlter, "SQ4")	//Adiciona campos de Usuario no array de Alteracao

	cDesc := SQ3->Q3_CARGO + " - " + SQ3->Q3_DESCSUM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio do bloco de inicializacao de variaveis para qdo a     ³
	//³ opcao "Copiar" for acionada.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lCopy
		aHeader := {}
	    aCols 	:= {}
		Tr020obter(2, Nil, Nil,4 )
		IF (nPosRec		:= GdFieldPos("Q4_REC_WT")	) > 0
		   Aeval(aLisPast[2][2],{|x| x[nPosRec] := 0 } )

		Endif
		If 	cModulo = "CSA"
			Tr020Pontos(aLisPast[2][1],aLisPast[2][2],4)
		EndIf

		//-- 3- Cursos do Cargo - RA5
		If cModulo == "TRM"
			aHeader := {}
	 	   	aCols 	:= {}
			Tr020obter(3, Nil, Nil,4 )

			IF (nPosRec		:= GdFieldPos("RA5_REC_WT")	) > 0
		   		Aeval(aLisPast[3][2],{|x| x[nPosRec] := 0 } )
			Endif
		EndIf

		//-- 4- Habilidades do Cargo - RBH
		If cModulo != "RSP" .Or. lRspHab
			aHeader := {}
	    	aCols 	:= {}
		   	Tr020obter(4, Nil, Nil,4 )
			IF (nPosRec		:= GdFieldPos("RBH_REC_WT")	) > 0
		   		Aeval(aLisPast[4][2],{|x| x[nPosRec] := 0 } )
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria as Variaveis de Memoria - Habilidades (RBH)			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nUsaHab := Len(aLisPast[4][1])
			For nX := 1 To Len(aLisPast[4][1])
				Private &( "M->"+aLisPast[4][1][ nX, 2 ] ) := aLisPast[4][2][ 1,nX ]
			Next nX
		EndIf

		aHeader := {}
	    aCols 	:= {}

    Endif

    //Monta o array com os campos a serem exibidos
	aAcho := {"Q3_CARGO","Q3_DESCSUM","Q3_CC","Q3_DESCCC","Q3_MEMO1","Q3_MEMO2","Q3_MEMO3","Q3_MEMO4","Q3_GRUPO","Q3_DGRUPO","Q3_DEPTO","Q3_PONTOSI","Q3_TABELA","Q3_TABNIVE","Q3_CLASSE","Q3_DESCLAS","Q3_MSBLQL"}

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
	aAdd( aObjCoords , {0, 0, .T., .T.} )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	//aTreeCoords		:= { (aObjSize[1,1]+2)	, (aObjSize[1,2])			, (aObjSize[1,3]), (aObjSize[1,4]*0.2) }
	//aEnchCoords		:= { (aObjSize[1,1]+2)	, (aObjSize[1,4]*0.2 + 2)	, (aObjSize[1,3]), (aObjSize[1,4]) }
	//aGetDCoords		:= { (aObjSize[1,1]+20), (aObjSize[1,4]*0.2 + 2)	, (aObjSize[1,3]), (aObjSize[1,4]) }

	aTreeCoords		:= { aObjSize[1,1],			aObjSize[1,2], 			aObjSize[1,3],	(aObjSize[1,4]*0.2)		}
	aEnchCoords		:= { aObjSize[1,1],			(aObjSize[1,4]*0.2+5),	aObjSize[1,3],	aObjSize[1,4] 			}
	aGetDCoords		:= { (aObjSize[1,1]+20),	(aObjSize[1,4]*0.2+5),	aObjSize[1,3],	aObjSize[1,4]			}

	DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

		@ aGetDCoords[1]-18,aGetDCoords[2] Say oSay1 PROMPT OemToAnsi(STR0009) SIZE 20,7 PIXEL		//"Cargo : "
		@ aGetDCoords[1]-18,aGetDCoords[2]+30 Get oGet1 VAR cDesc SIZE 150,7 WHEN .F. PIXEL

		DEFINE DBTREE oTree FROM aTreeCoords[1],aTreeCoords[2] TO aTreeCoords[3],aTreeCoords[4] CARGO OF oDlgMain;
			ON CHANGE (Tr020Principal(cAlias,nReg,nOpcx,oTree,oDlgMain, aGetDCoords,aAlter))

			//--Validacao da Saida do dbTree
			oTree:bValid 	:= {|| TreeVal020(nOpcx,nReg) }
			oTree:lValidLost:= .f.
			oTree:lActivated:= .T.

			DBADDTREE oTree PROMPT OemToAnsi(STR0010)+Space(30);	//"Descri‡„o Cargo"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "1"
			DBENDTREE oTree

			DBADDTREE oTree PROMPT OemToAnsi(STR0011)+Space(30);	//"Fatores Avaliacao"
							 RESOURCE "FOLDER5","FOLDER6";
							 CARGO "2"
			DBENDTREE oTree

			If cModulo == "TRM"
				DBADDTREE oTree PROMPT OemToAnsi(STR0012);	//"Cursos"
									 RESOURCE "FOLDER5","FOLDER6";
									 CARGO "3"
				DBENDTREE oTree
			EndIf

			If cModulo != "RSP" .Or. lRspHab
				DBADDTREE oTree PROMPT OemToAnsi(STR0044)+Space(30);	//"Habilidades"
								 RESOURCE "FOLDER5","FOLDER6";
								 CARGO "4"
				DBENDTREE oTree
			EndIf

			// CARGO
			Zero()

			oEnchoice:= MsMGet():New(cAlias, nReg, if(lCopy,3,nOpcx), aAC,"AC",STR0013,aAcho,aEnchCoords, , , , , , , , ,.T. )	//"Quanto a exclusao"

			// Graduacao de Cargos - SQ4

			o2Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],if(lCopy,3,nOpcx),"TrQ4LiOk()","TrQ4LiOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),aAlter,,,nRegMaxSQ4, , , , ,oDlgMain)
			o2Get:oBrowse:Default()


			If cModulo == "TRM"
				// CURSOS DO CARGO - RA5

				o3Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],if(lCopy,3,nOpcx),"TrR5LiOk()","TrR5LiOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1,,9999, , , , ,oDlgMain)
				o3Get:oBrowse:Default()

			EndIf

			If cModulo != "RSP" .Or. lRspHab
				// HABILIDADES DO CARGO - RBH

				o4Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],if(lCopy,3,nOpcx),"TrRHLiOk()","TrRHTudOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1,,300, , , , ,oDlgMain)
				o4Get:oBrowse:Default()
			EndIf


	ACTIVATE MSDIALOG oDlgMain ON INIT (o2Get:Hide(),o2Get:oBrowse:Hide(),;
										If(cModulo=="TRM",(o3Get:Hide(),o3Get:oBrowse:Hide()),Nil),;
										If(cModulo!="RSP" .Or. lRspHab,(o4Get:Hide(),o4Get:oBrowse:Hide()),Nil),;
										oSay1:Hide(),oGet1:Hide(),;
										oObjAtu:= oEnchoice,;
				EnchoiceBar(oDlgMain,	{|| If(TreeVal020(nOpcx,nReg),(fTransf(cEstou), nOpca:=1,oDlgMain:End()),)},;
										{|| nOpca:=2,oDlgMain:End()},,;
										{{"COLINC",{||Tr020Copia(cGrupo,cCargo1,cCC1,nOpcx) },;
										If( cModulo == "TRM", OeMToAnsi(STR0021),OemToAnsi(STR0049) )}})) //"Copiar Fatores / Cursos",#"Copiar Fatores"

	If nOpca == 1

		If cEstou == "2" .OR. cEstou == "1"
			If 	cModulo = "CSA"
			    If cEstou == "1"
			    	aHeader := {}
				    aCols 	:= {}
					Tr020obter(2, Nil, Nil,4 )
					IF (nPosRec		:= GdFieldPos("Q4_REC_WT")	) > 0   .and. ( nOpcx = 3 .or. lCopy)
					   Aeval(aLisPast[2][2],{|x| x[nPosRec] := 0 } )
					Endif
			    Endif
				Tr020Pontos(aLisPast[2][1],aLisPast[2][2],nOpcx)
			EndIf
		EndIf

		//--Gravacao dos Arquvios
		If nOpcx != 5 .And. nOpcx != 2  // Se nao for Exclusao e Visualizacao

			//------ Verifica Necessidade Treinamento
			If cModulo == "TRM"

				aHeader	:=  If( aLisPast[3]<> nil, aClone(aLisPast[3][1]), {})
				aCols	:=  If( aLisPast[3]<> nil, aClone(aLisPast[3][2]), {})

				For nx := 1 to Len(aCols)
					If aCols[nx][Len(aCols[nx])]
						Tr020Neces(nx)
					EndIf
				Next nx
			EndIf
			//------
			IF ExistBlock("TRM020GTL")
				ExecBlock("TRM020GTL",.F.,.F.)
			EndIF
			Begin Transaction
				Tr020Grava(nOpcx)
			End Transaction
			If __lSX8 .And. nOpcx == 3 .Or. (lCopy	 .and. !lExistCargo)	// Inclusao
				ConfirmSX8()
			Else
				If (lCopy .and. lExistCargo)	// Inclusao
					//-- Se chave ja existia nao desperdica numeracao automatica
					RollBackSX8()
				endif
			EndIf
		ElseIf nOpcx == 5		// Exclusao
			Begin Transaction
				Tr020Dele(cCargo1, nReg)
			End Transaction
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 		Ponto de Entrada Apos Gravacao do Cargo 				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Este ponto de Entrada sera executado apos a gravacao do Cargo. 	  ³
		//³ Pode utilizar as variaveis INCLUI, ALTERA, lVisual e lExclui.	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock("TRM020DG")
			ExecBlock("TRM020DG",.F.,.F.)
		EndIF
	Else
		If __lSX8 .And. nOpcx == 3 .Or. nOpcx == 6
			RollBackSX8()
		EndIf
	EndIf

	Release Object oTree

	dbSelectArea(cAlias)
	dbGoto(nReg)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TreeVal020³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Saida do dbTree                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TreeVal020(nOpcx,nReg)
	Local lRet 		:= .t.
	Local aSQ3Area	:= SQ3->(GetArea())

	DEFAULT lMsbql	:= SQ3->( ColumnPos( "Q3_MSBLQL" ) ) > 0

	If nOpcx != 2 .And. nOpcx != 5
		If cEstou == "1"
			lRet:= Obrigatorio(aGets,aTela)
			If lRet
				lRet := Tr020CC()
			EndIf

			If lRet .And. lMsbql .And. nOpcx == 4 .And. M->Q3_MSBLQL == "1" .And. M->Q3_MSBLQL != SQ3->Q3_MSBLQL .And. fVldAtiv( M->Q3_CARGO )
				lRet := .F.	
				Help( " ", 1, OemToAnsi(STR0031), Nil, OemToAnsi(STR0072), 1, 0 )//"Atenção"###"Não é possivel efetuar o bloqueio do cargo pois há funcionários ativos vinculados"
			EndIf

			If lRet
				//-- Verifica se o cargo ja existia para nao desperdicar
				//-- nunmeracao automaticas
				If lCopy
				   If dbseeK(xFilial("SQ3")+ M->Q3_CARGO)
				      lExistCargo:= .T.
				   else
					   lExistCargo:= .F.
				   Endif
				Endif
			Endif
			cGrupo := M->Q3_GRUPO
		ElseIf cEstou = "2"
			lRet := TrQ4LiOk("S")
		Elseif cEstou = "3"
			lRet := TrR5LiOk("S")
		Elseif cEstou = "4"
			lRet := TrRHTudOk("S")
		Endif
	EndIf

	RestArea(aSQ3Area)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fTransf   ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTransf(cEstou)
	IF ( cEstou <> "1" )
		aLisPast[Val(cEstou)][2] := aClone(aCols)
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tr020Princ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle dos programas do Cargo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias,nReg,nOpcx,oTree,oDlgMain						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr020Principal(cAlias,nReg,nOpcx,oTree,oDlgMain,aGetDCoords,aAlter)
	//	1- Descricao Cargo
	//	2- Graduacao do Cargo
	//	3- Cursos do Cargo
	//	4- Habilidades do Cargo


	IF ( cEstou <> "1") .and. !Empty(aCols)
		//-- Descarrega o aCols ativo para o aLisPast
		fTransf(cEstou)
	Endif


	cIndo:= oTree:GetCargo()

	If cEstou == "1"
		oEnchoice:Hide()
		cDesc	:= M->Q3_CARGO +" - "+ M->Q3_DESCSUM
		cCargo1 := M->Q3_CARGO
		cCC1	:= M->Q3_CC
		cChave	:= M->Q3_FILIAL + M->Q3_CARGO + M->Q3_CC
		cChavRBH:= M->Q3_FILIAL + M->Q3_GRUPO + M->Q3_CARGO + M->Q3_CC

	ElseIf cEstou == "2"
		o2Get:Hide()
		o2Get:oBrowse:Hide()
		If 	cModulo = "CSA"
			Tr020Pontos(@aHeader, @aCols,nOpcx )
		EndIf
	ElseIf cEstou == "3"
		o3Get:Hide()
		o3Get:oBrowse:Hide()

	ElseIf cEstou == "4"
		o4Get:Hide()
		o4Get:oBrowse:Hide()
	EndIf

	If cIndo == "1"
		oEnchoice:EnchRefreshAll()
		oEnchoice:Show()
		oSay1:Hide()
		oGet1:Hide()
		oObjAtu:= oEnchoice

	ElseIf cIndo == "2"
		aHeader	:= {}
		aCols	:= {}
	   	Tr020obter(val(cIndo), @aHeader, @aCols,nOpcx )

		If o2Get <> nil .and. !lObj2
			Freeobj(o2Get)
			o2Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],nOpcx,"TrQ4LiOk()","TrQ4LiOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),aAlter,,,nRegMaxSQ4, , , , ,oDlgMain)
			o2Get:oBrowse:Default()
			lObj2:=.T.
	    EndIf

		n	:= 1

	  	If nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 2
	  		TR020NewSq4()	// Preenche GetDados Vazia.
	  	EndIf

		o2Get:Show()
		o2Get:oBrowse:Show()
		oSay1:Show()
		oGet1:Show()
		oGet1:cText(cDesc)
		oObjAtu  := o2Get

		If 	cModulo = "CSA"
			Tr020Pontos(aHeader,aCols,nOpcx)
		EndIf

	ElseIf cIndo == "3"
		aHeader	:= {}
		aCols	:= {}
		Tr020obter(val(cIndo), @aHeader, @aCols,nOpcx)

		If o3Get <> nil .and. !lObj3
			Freeobj(o3Get)
	   		o3Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],nOpcx,"TrR5LiOk()","TrR5LiOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1,,9999, , , , ,oDlgMain)
			o3Get:oBrowse:Default()
			lObj3:=.T.
	    EndIf

		n		:= 1
		o3Get:Show()
		o3Get:oBrowse:Show()
		oSay1:Show()
		oGet1:Show()
		oGet1:cText(cDesc)
		oObjAtu  := o3Get

	ElseIf cIndo == "4"
		aHeader	:= {}
		aCols	:= {}
		Tr020obter(val(cIndo), @aHeader, @aCols, nOpcx)


		If o4Get <> nil .and. !lObj4
			Freeobj(o4Get)
			o4Get 	:= MSGetDados():New(aGetDCoords[1],aGetDCoords[2],aGetDCoords[3],aGetDCoords[4],nOpcx,"TrRHLiOk()","TrRHTudOk()","",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1,,300, , , , ,oDlgMain)
			o4Get:oBrowse:Default()
			lObj4:=.T.
	    EndIf

		n		:= 1

	  	If nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 2
	  		TR020NewRbh()	// Preenche GetDados Vazia.
	  	EndIf

		o4Get:Show()
		o4Get:oBrowse:Show()
		oSay1:Show()
		oGet1:Show()
		oGet1:cText(cDesc)
		oObjAtu  := o4Get

	EndIf

	cEstou := cIndo

	If cEstou == "1"
		oEnchoice:Refresh()
	Else
		oObjAtu:Refresh()
	EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TrR5LiOk  ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Linha Ok do arquivo RA5 Cursos do Cargo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lVldTree = Deve passar c/uma linha em branco               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrR5LiOk(cVldTree)
	Local lRet 		:= .T.
	Local nPosCur 	:= GdFieldPos("RA5_CURSO")
	Local nCont 	:= 0
	Local nUsaRA5	:= Len(aCols[n])

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree== "S" .And. Len(aCols) = 1
		// Verifica se a primeira linha esta totalmente em branco
		If Tr020Linha()
			Return(.T.)
		EndIf
	Endif

	If aCols[n,nUsaRA5] == .F. .And. nPosCur > 0
		Aeval(aCols,{ |X| If( X[nPosCur]==aCols[N,nPosCur] .And. x[nUsaRA5] == .F. , nCont ++ , nCont ) } )
		If nCont > 1
			Help(" ",1,"TRA020CCUR")
			lRet := .F.
		Endif

		If Empty(aCols[n,nPosCur]) .And. lRet
			Help(" ",1,"TRA020SCUR")
		   lRet := .F.
		Endif
	EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TrQ4LiOk  ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Linha Ok do arquivo SQ4 Graduacoes do Cargo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lVldTree = Deve passar c/uma linha em branco               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrQ4LiOk(cVldTree)
	Local lRet 		:= .T.
	Local nPosFat 	:= GdFieldPos("Q4_FATOR")
	Local nPosGra 	:= GdFieldPos("Q4_GRAU")
	Local nCont  	:= 0
	Local nUsaSq4 	:= Len(aCols[n])

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree== "S" .And. Len(aCols) = 1
		// Verifica se a primeira linha esta totalmente em branco
		If Tr020Linha()
			Return(.T.)
		EndIf
	Endif

	If aCols[n,nUsaSq4] == .F.

		Aeval(aCols,{ |X| If( (X[nPosFat] == aCols[N,nPosFat] .Or. ;
			 x[nPosFat]+x[nPosGra] == aCols[n,nPosFat]+aCols[n,nPosGra]) .And.;
			 x[nUsaSq4] == .F. , nCont ++ , nCont ) } )

		If nCont > 1
			Help(" ",1,"TRA020CFAT")
			lRet := .F.
		Endif

		If lRet .And. (Empty(aCols[n,nPosFat] ) .Or. Empty(aCols[n,nPosGra]))
			Help(" ",1,"TRA020FATG")
			lRet := .F.
		Endif

	EndIf
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TrRHLiOk  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 23/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Linha Ok do arquivo RBH Habilidades do Cargo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lVldTree = Deve passar c/uma linha em branco               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrRHLiOk(cVldTree)
	Local lRet 		:= .T.
	Local nx		:= 0

	cVldTree := If (cVldTree == Nil ,"N" , If (ValType(cVldTree) == "C",cVldTree, "N"))

	If cVldTree== "S" .And. Len(aCols) == 1
		// Verifica se a primeira linha esta totalmente em branco
		If Tr020Linha()
			Return(.T.)
		EndIf
	Endif

	If !aCols[n,Len(aCols[n])] 		// Verifico deletado a linha
		If Empty( GDFieldGet("RBH_CODCOM") )
			Aviso(STR0031, STR0038, {"Ok"})	//"Atencao"###"Codigo da Estrutura de Competencia deve ser informado."
			lRet := .F.

		ElseIf Empty( GDFieldGet("RBH_ITECOM") )
			Aviso(STR0031, STR0039, {"Ok"})	//"Atencao"###"Codigo do Item de Competencia deve ser informado."
			lRet := .F.

		ElseIf Empty( GDFieldGet("RBH_HABIL") )
			Aviso(STR0031, STR0040, {"Ok"})	//"Atencao"###"Nao existe nenhuma Habilidade relacionada a este Item de Competencia"
			lRet := .F.

		ElseIf Empty( GDFieldGet("RBH_ITESCA") )
			Aviso(STR0031, STR0041, {"Ok"})	//"Atencao"###"Item de Escala deve ser informado."
			lRet := .F.

		ElseIf Empty( GDFieldGet("RBH_ITIMPO") )
			Aviso(STR0031, STR0042, {"Ok"})	//"Atencao"###"Item de Grau de Importancia deve ser informado."
			lRet := .F.

		EndIf
	EndIf

	If lRet
		For nx := 1 To Len(aCols)
			If 	GDFieldGet("RBH_CODCOM"	, n) == GDFieldGet("RBH_CODCOM"	, nx) .And.;
				GDFieldGet("RBH_ITECOM"	, n) == GDFieldGet("RBH_ITECOM"	, nx) .And.;
				GDFieldGet("RBH_HABIL"	, n) == GDFieldGet("RBH_HABIL"	, nx) .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n != nx .And. !aCols[n,Len(aCols[n])]
				Aviso(STR0031, STR0043, {"Ok"})	// "Atencao"###"Item ja cadastrado"
				lRet:= .F.
				Exit
			EndIf
		Next nx
	EndIf
Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TrRHTudOk ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tudo Ok do arquivo RBH Habilidades do Cargo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrRHTudOk(cVldTree)
	Local lRet 		:= .T.
	Local nx		:= 0

	For nx := 1 To Len(aCols)
		n := nx
		If !( lRet := TrRhLiOk(cVldTree) )
			Exit
		EndIf
	Next nx
Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tr020Grava³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao dos Dados do Cargo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx					                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr020Grava(nOpcx)
	Local ny 		:= 0
	Local nx		:= 0
	Local nt 		:= 0
	Local ni 		:= 0
	Local nPosRec	:= 0
	Local nPosCod	:= 0
	Local nOperation:= nOpcX
	Local cCampo	:= ""
	Local xConteudo	:= ""
	Local aAlias	:= {"SQ3","SQ4","RA5","RBH"}
	Local aCposVal  := {}
	Local aErros    := {}
	Local cCamp		:= ""
	Local bCampo    := { |nCPO| Field(nCPO) }
	Local cAux1		:= ""
	Local cAux2		:= ""
	Local cAux3		:= ""
	Local cDescDet  := ""
	Local cDresp    := ""
	Local cDrelint  := ""
	Local cDhabili  := ""
	Local cFilEnv   := ""
	Local cCargo 	:= ""
	Local cDescr 	:= ""
	Local cCBO	 	:= ""
	Local cChave 	:= ""
	Local cData     := cValToChar( StrZero( Month(dDataBase), 2 ) ) + cValToChar( Year(dDataBase))
	Local cAnoMes   := cValToChar( Year(dDataBase)) + "-" + cValToChar( StrZero( Month(dDataBase), 2 ) )
	Local lTravou	:= .F.
	Local lIntegra  := .F.
	Local lSemFilial:= .F.
	Local cDescDet  := Iif (nOpcx == 4 .And. FieldPos("Q3_DESCDET") > 0 ,  SQ3->Q3_DESCDET, '')
	Local cDresp    := Iif (nOpcx == 4 .And.  FieldPos("Q3_DRESP"  ) > 0 ,  SQ3->Q3_DRESP  , '')
	Local cDRelInt  := Iif (nOpcx == 4 .And.  FieldPos("Q3_DRELINT") > 0 ,  SQ3->Q3_DRELINT, '')
	Local cDHabili  := Iif (nOpcx == 4 .And.  FieldPos("Q3_DHABILI") > 0 ,  SQ3->Q3_DHABILI, '')

	IF nOpcx == 6	//Copia
		cCargo1		:= M->Q3_CARGO
		cCC1		:= M->Q3_CC
	EndIF

	//Verificando versão do GPE
	lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-1030", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio, @cVersGPE ), .F. )

	//----------------------------------
	//| E X T E M P O R Â N E O  S-1030
	//----------------------------------
	//Se a integração estiver ativa e não for consistência de tabela
	If lInttaf  .And. cVersGPE < "9.0" .And. FUNNAME() <> "GPEM035"   .And. ( IIF(FindFunction("fChkFMat"),lRet:=fChkFMat("S-1030"),.T.)) .And. lCargSQ3

		If SQ3->(ColumnPos( 'Q3_CBO' )) > 0
			If SRJ->(ColumnPos( 'Q3_ACUM' )) > 0 .And. !Empty(M->Q3_ACUM)
				aAdd(aCposVal,M->Q3_ACUM)
				aAdd(aCposVal,M->Q3_CTESP)
				aAdd(aCposVal,M->Q3_DEDEXC)
				aAdd(aCposVal,M->Q3_LEI)
				aAdd(aCposVal,M->Q3_DTLEI)
				aAdd(aCposVal,M->Q3_SIT)
			EndIf
		Else
			Help(,,,"",OemToAnsi(STR0057)+ CRLF + CRLF + OemToAnsi(STR0058),1,0)//"O Parâmetro MV_CARGSQ3 está ativo, portanto o envio do evento S-1030-Cargos será feito por esta rotina. "##"Mas, não foram encontrados os novos campos para o eSocial, como por exemplo o CBO, favor executar o UPDDISTR."
			Return .F.
		EndIf

		//Identificando Filial de Envio
		fGp23Cons(/*@aFilInTaf*/, /*@aArrayFil*/,@cFilEnv)
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		//Tratamento de compartilhamento da tabela SQ3
		If Empty( xFilial("SQ3") )
			lSemFilial := .T.
		EndIf

		//Montando as variaveis utilizadas na chave de pesquisa
		cCargo := IIf(lSemFilial, AllTrim( M->Q3_CARGO ),  AllTrim(If(Empty(SQ3->Q3_FILIAL),cFilEnv,SQ3->Q3_FILIAL) + M->Q3_CARGO ) )
		cDescr  := AllTrim( M->Q3_DESCSUM )
		cCBO    := M->Q3_CBO
		cChave  := cCargo + ";" + cData

		//-------------------------------------------------
		//| Função centralizadora para gerar Extemporâneos
		//| Extemporâneo S-1035: GY_CODIGO + MMAAAA
		//-------------------------------------------------
		nOperation := fVerExtemp( "S-1030", cChave, nOperation, /*@cStatus*/ )

		//-------------------------------------------------
		//| Baseado no evento de retorno, geramos o nOpc
		//| nOpc irá variar de 3 <inclusao>, 4 <alteracao> e 5 <exclusao>
		//----------------------------------------------------------------
		If ( nOperation > 0 )
			//Realizando integração do evento
			lRet := fCarrFun( cCargo, cDescr, cCBO, nOperation, cAnoMes,@aErros,cFilEnv,aCposVal, .F. )

			If( !lRet )
				Help(,,,OemToAnsi(STR0031),aErros[1],1,0)//##"Atenção"
				Return(.F.)
			ElseIf FindFunction("fEFDMsg") .AND. lRet
				fEFDMsg()
			EndIf
		Else
			Return(.F.)
		EndIf
	EndIf

	For nt:=1 To Len(aAlias)
	 	If nt == 1
			If (aLisPast[nt] != Nil) .Or. nOpcx ==3 .Or. nOpcx == 4 .Or. lCopy
				//-- Cargo
				dbSelectArea("SQ3")
				RecLock("SQ3",IIf(nOpcx != 3 .And. nOpcx != 6, .F., .T.))
					For nI:=1 To FCount()
						If "_FILIAL"$Field(ni)
							FieldPut(nI,cFilial)
						Else
							FieldPut(nI,M->&(EVAL(bCampo,nI)))
						EndIf
					Next nI
				MsUnlock()


				// Grava campos Memo
				If FieldPos("Q3_DESCDET") > 0
					If !Empty(cDescDet)
						SQ3->Q3_DESCDET := cDescDet
					EndIf

					If !Empty(M->Q3_MEMO1)
						MSMM(Q3_DESCDET,,,M->Q3_MEMO1,1,,,"SQ3","Q3_DESCDET","RDY")
					Else
						MSMM(Q3_DESCDET	,,,,2,,,,,"RDY")
						If !Empty(cDescDet)
							SQ3->Q3_DESCDET := ''//deixar campo limpo ja que nao havero texto
		            EndIf
				EndIf
				EndIf

				If FieldPos("Q3_DRESP") > 0
					If !Empty(cDresp)
						SQ3->Q3_DRESP := cDresp
					EndIf

					If !Empty(M->Q3_MEMO2)
						MSMM(Q3_DRESP ,,,M->Q3_MEMO2,1,,,"SQ3","Q3_DRESP","RDY")
					Else
						MSMM(Q3_DRESP	,,,,2,,,,,"RDY")

						If !Empty(cDresp)
							SQ3->Q3_DRESP := ''//deixar campo limpo ja que nao havero texto
						EndIf
					EndIf
				EndIf

				If FieldPos("Q3_DRELINT") > 0
					If !Empty(cDRelInt)
						SQ3->Q3_DRELINT := cDRelInt
					EndIf

					If !Empty(M->Q3_MEMO3)
						MSMM(Q3_DRELINT ,,,M->Q3_MEMO3,1,,,"SQ3","Q3_DRELINT","RDY")
					Else
						MSMM(Q3_DRELINT	,,,,2,,,,,"RDY")
						If !Empty(cDRelInt)
							SQ3->Q3_DRELINT := ''//deixar campo limpo ja que nao havero texto
						EndIf
					EndIf
				EndIf

				If FieldPos("Q3_DHABILI") > 0
					If !Empty(cDHabili)
						SQ3->Q3_DHABILI := cDHabili
					EndIf

					If !Empty(M->Q3_MEMO4)
						MSMM(Q3_DHABILI	,,,M->Q3_MEMO4,1,,,"SQ3","Q3_DHABILI","RDY")
					Else
						MSMM(Q3_DHABILI	,,,,2,,,,,"RDY")
						If !Empty(cDHabili)
							SQ3->Q3_DHABILI := ''//deixar campo limpo ja que nao havero texto
						EndIf
					EndIf
				EndIf

				Loop
			Else
				Loop
			EndIf
		ElseIf nt == 2
			If (aLisPast[nt] != Nil) .Or. nOpcx ==3 .Or. lCopy
				//Faz a delecao antes de gravar
				If nOpcx != 3
					cChave := SQ3->Q3_FILIAL + SQ3->Q3_CARGO + SQ3->Q3_CC
					dbSelectArea("SQ4")
					dbSetOrder(2)
					Begin Transaction
						If dbSeek(cChave)
							While !Eof() .And. cChave == SQ4->Q4_FILIAL + SQ4->Q4_CARGO + SQ4->Q4_CC
								RecLock("SQ4",.F.)
									dbDelete()
								MsUnlock()
								dbSkip()
							EndDo
						EndIf
					End Transaction
				EndIf
				//-- Graduacao de Cargo
				aHeader		:= If( aLisPast[2] <> Nil, aClone(aLisPast[2][1]), {})
				aCols		:= If( aLisPast[2] <> Nil, aClone(aLisPast[2][2]), {})
				nPosCod		:=  GdFieldPos("Q4_FATOR")
			Else
				Loop
			EndIf
		ElseIf nt == 3
			If (aLisPast[nt] != Nil) .Or. nOpcx ==3 .Or. lCopy
				//--  Cursos do Cargo
				If cModulo == "TRM"
					aHeader		:= If( aLisPast[3] <> Nil, aClone(aLisPast[3][1]), {})
					aCols		:= If( aLisPast[3] <> Nil, aClone(aLisPast[3][2]), {})
					nPosCod		:=  GdFieldPos("RA5_CURSO")
				Else
					Loop
				EndIf
			Else
				Loop
	        EndIf
		ElseIf nt == 4
			If (aLisPast[nt] != Nil) .Or. nOpcx ==3 .Or. lCopy
				//-- Habilidades do Cargo
				If cModulo != "RSP" .Or. lRspHab
					aHeader		:= If( aLisPast[4] <> Nil, aClone(aLisPast[4][1]), {})
					aCols		:= If( aLisPast[4] <> Nil, aClone(aLisPast[4][2]), {})
					nPosCod		:=  GdFieldPos("RBH_CODCOM")
				Else
					Loop
				EndIf
			Else
				Loop
			EndIf
		EndIf

		nPosRec :=GdfieldPos(If(aAlias[nt] == "SQ4", right(aAlias[nt],2), aAlias[nt]) +"_REC_WT")

		If Len(aCols) == 1
			Tr020Zera()
		EndIf

		cCamp := If (Subs(aAlias[nt],1,1) = "S" ,Subs(aAlias[nt],2,2),Subs(aAlias[nt],1,3))
		cAux1:= aAlias[nt]+"->"+cCamp+"_FILIAL"
		cAux2:= aAlias[nt]+"->"+cCamp+"_CARGO"
		cAux3:= aAlias[nt]+"->"+cCamp+"_CC"


		dbSelectArea(aAlias[nt])

		For nx:=1 to Len(aCols)
			Begin Transaction
				lTravou:= .F.
				If aCols[nx][nPosRec]> 0 .And. nOpcx != 6 .And. nt != 2
					MsGoto(aCols[nx][nPosRec])
					RecLock(aAlias[nt],.F.,.T.)
					lTravou:=.T.
				Else
					//--Verifica se Nao esta Deletado no aCols
					If !aCols[nx][Len(aCols[nx])] .And. !Empty(aCols[nx][nPosCod])
						RecLock(aAlias[nt],.T.,.T.)
						lTravou:=.T.
					EndIf
				EndIf
				If lTravou
					//--Verifica se esta deletado
					If aCols[nx][Len(aCols[nx])] .And. nt != 2
						dbDelete()
					Else
						Replace &cAux1 	WITH xFilial(aAlias[nt])
						Replace &cAux2  WITH cCargo1
						Replace &cAux3  WITH cCC1
					EndIf

					For ny := 1 To Len(aHeader)
						If aHeader[ny][10] != "V"
							(aAlias[nt])->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
						EndIf
					Next ny

					If aAlias[nt] == "SQ4"
						SQ4->Q4_GRUPO := cGrupo
					EndIf

					If aAlias[nt] == "RBH"
						RBH->RBH_GRUPO := cGrupo
					EndIf
				EndIf

				MsUnlock()
			End	 Transaction
		Next nx
	Next nt

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tr020Dele ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao dos Dados do Cargo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr020Dele(cCargo, nReg)
	Local aSaveArea	:= GetArea()
	Local aSaveSQ3	:= SQ3->( GetArea() )
	Local aSaveSRJ	:= SRJ->( GetArea() )
	Local aSaveSRA	:= SRA->( GetArea() )
	Local nCnt 		:= 0
	Local lChkDelOk	:= .F.
	Local aNoChk	:= {"RA5","SQ4","RBH"}

	dbSelectArea("SQ3") 	//Verificar se existe apenas um Cargo com este codigo
	dbSetOrder(1)
	dbSeek(xFilial("SQ3") + cCargo)
	While !Eof() .And. SQ3->Q3_CARGO == cCargo
		nCnt ++
		dbSkip()
	EndDo

	If nCnt == 1
		dbSelectArea("SRA")
		dbSetOrder(12)
		If dbSeek(xFilial("SRA")+cCargo)
			Aviso(STR0031, STR0046, {"Ok"},, STR0047+SRA->RA_MAT)	//"Atencao###"Este cargo esta sendo utilizado no Cadastro de funcionario."###"Matricula: "
			RestArea(aSaveSRA)
			RestArea(aSaveSRJ)
			RestArea(aSaveSQ3)
			RestArea(aSaveArea)
			Return .F.
		EndIf

		dbSelectArea("SRJ")
		dbSetOrder(4)
		If dbSeek(xFilial("SRJ")+cCargo)
			Help("",1,"TR020NPODE")	// Este cargo nao pode ser excluido. Verifique os cargos na funcao
			RestArea(aSaveSRA)
			RestArea(aSaveSRJ)
			RestArea(aSaveSQ3)
			RestArea(aSaveArea)
			Return .F.
		EndIf

		dbSelectArea("SQ3")
		dbSetOrder(1)
		dbSeek(cChave)

		lChkDelOk  := ChkDelRegs(	"SQ3"				,;	//01 -> Alias do Arquivo Principal
									nReg				,;	//02 -> Registro do Arquivo Principal
									NIL					,;	//03 -> Opcao para a AxDeleta
									NIL					,;	//04 -> Filial do Arquivo principal para Delecao
									NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
									NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
									NIL					,;	//07 -> Mensagem para MsgYesNo
									NIL					,;	//08 -> Titulo do Log de Delecao
									NIL					,;	//09 -> Mensagem para o corpo do Log
									NIL				 	,;	//10 -> Se executa AxDeleta
									NIL					,;	//11 -> Se deve Mostrar o Log
									NIL					,;	//12 -> Array com o Log de Exclusao
									NIL		 			,;	//13 -> Array com o Titulo do Log
									NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
									NIL					,;	//15 -> Bloco para a Condicao While
									NIL					,;	//16 -> Bloco para Skip/Loop no While
									.T.					,;	//17 -> Verifica os Relacionamentos no SX9
									aNoChk				 ;	//18 -> Alias que nao deverao ser Verificados no SX9
							    )

		If !lChkDelOk
			RestArea(aSaveSRA)
			RestArea(aSaveSRJ)
			RestArea(aSaveSQ3)
			RestArea(aSaveArea)
			Return .F.
		Endif

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apagando arquivos filhos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("RA5")
	dbSetOrder(2)
	If dbSeek(cChave)
		While !Eof() .And. cChave == RA5->RA5_FILIAL+RA5->RA5_CARGO+RA5->RA5_CC
			RecLock("RA5",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	dbSelectArea("SQ4")
	dbSetOrder(2)
	If dbSeek(cChave)
		While !Eof() .And. cChave == SQ4->Q4_FILIAL+SQ4->Q4_CARGO+SQ4->Q4_CC
			RecLock("SQ4",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	dbSelectArea("RBH")
	dbSetOrder(2)
	If dbSeek(cChavRBH)
		While !Eof() .And. cChavRBH == RBH->RBH_FILIAL+RBH->RBH_GRUPO+RBH->RBH_CARGO+RBH->RBH_CC
			RecLock("RBH",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apagando arquivo pai	                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQ3")
	If dbSeek(cChave)
		While !Eof() .And. cChave == SQ3->Q3_FILIAL+SQ3->Q3_CARGO+SQ3->Q3_CC
			If FieldPos("Q3_DESCDET") > 0
				MSMM(Q3_DESCDET	,,,,2,,,,,"RDY")
			EndIf
			If FieldPos("Q3_DRESP") > 0
				MSMM(Q3_DRESP	,,,,2,,,,,"RDY")
			EndIf
			If FieldPos("Q3_DRELINT") > 0
				MSMM(Q3_DRELINT	,,,,2,,,,,"RDY")
			EndIf
			If FieldPos("Q3_DHABILI") > 0
				MSMM(Q3_DHABILI,,,,2,,,,,"RDY")
			EndIf

			RecLock("SQ3",.F.)
				dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf

	RestArea(aSaveSRA)
	RestArea(aSaveSRJ)
	RestArea(aSaveSQ3)
	RestArea(aSaveArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³FTr020Traz³ Autor ³ Mauro Sergio          ³ Data ³ 01.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trazer as Descricoes dos campos Virtuais e Inic.Padrao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ (cAlias,cCpoRet,cCodPesq,lRelac)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FTr020Traz(cAlias,cCpoRet,cCodPesq,lRelac)
	Local aSaveArea := GetArea()
	Local cPesq		:= ""
	Local nPosHead	:= 0
	Local nPos		:= 0
	Local cRet		:= ""
	Local lRet		:= .F.
	Local cContFat 	:= ""
	Local cGrupo	:= ""

	Private cConteudo := ""
	cPesq 	:= If (lRelac,cCodPesq,ReadVar())
	nPosHead:= GdFieldPos(cPesq)
	If nPosHead > 0
		cConteudo := aCols[Len(aCols),nPosHead]
	Elseif ! lRelac
		cConteudo := &(ReadVar())
	Endif

	If "FATOR"$ AllTrim(cPesq)
		cGrupo := SQ3->Q3_GRUPO
		If Empty(cGrupo)
			cGrupo := M->Q3_GRUPO
		EndIf
		cRet := TrmDesc(cAlias,cGrupo+cConteudo,"SQ1->Q1_DESCSUM")
	ElseIf "GRAU"$ AllTrim(cPesq)
		If ! lRelac
			nPosHead := GdFieldPos("Q4_FATOR")
			If nPosHead > 0
				cContFat := aCols[Len(aCols),nPosHead]
			Endif
		EndIf
		cGrupo := SQ3->Q3_GRUPO
		If Empty(cGrupo)
			cGrupo := M->Q3_GRUPO
		EndIf
		cRet := TrmDesc(cAlias,(cGrupo+If(lRelac,SQ4->Q4_FATOR,cContFat)+cConteudo),"SQ2->Q2_DESC")
	ElseIf "CURSO"$ AllTrim(cPesq)
		cRet := TrmDesc(cAlias,cConteudo,"RA1->RA1_DESC")
	EndIf

	If ! lRelac
		//--Igualar no Acols o Descricao
		nPos := GdFieldPos(cCpoRet)
		If nPos > 0
			aCols[Len(aCols),nPos] := cRet
			lRet := .T.
		EndIf
	Else
		lRet := cRet
	EndIf

	RestArea(aSaveArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tr020Copia³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox para fazer a copia dos fatores / Cursos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr020Copia(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Grupo    								  ³±±
±±³ 		 ³ ExpC2 = Codigo do Cargo  							      ³±±
±±³ 		 ³ ExpC3 = Codigo do Centro de Custos					      ³±±
±±³ 		 ³ ExpN4 = Numero da Opcao  							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA020												   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TR020Copia(cGrupo,cCargo,cCC,nOpcx)
	Local cDesc		:= ""
	Local cDescGrau	:= ""
	Local cDescFat	:= ""
	Local cDescGru	:= ""
	Local cDescCurso:= ""
	Local aArrayF4	:= {}
	Local cCadastro	:= ""
	Local nPosFator	:= 0
	Local nPosDesc	:= 0
	Local nPosGrau	:= 0
	Local nPosDGrau := 0
	Local nPosCurso	:= 0
	Local nOpca		:= 0
	Local oDlg, oQual
	Local cVar		:= ""
	Local cEscol	:= ""
	Local cEscolCC	:= ""
	Local lExiste	:= .F.
	Local lFlag		:= .F.
	Local nPos		:= 0
	Local ny		:= 0
	Local nx		:= 0
	Local aAuxCols 	:= Aclone(aCols)
	Local cCodCargo	:= ""
	Local cCodCC	:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para Dimensionar Tela		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aTreeCoords	:= {}
	Local aEnchCoords	:= {}
	Local aGetDCoords	:= {}

	If nOpcx == 5 .Or. nOpcx == 2 // Se Exclusao ou Visualizacao
		Return .T.
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	aAdvSize		:= MsAdvSize(,.T.,380)
	aInfoAdvSize	:= {aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5}
	If cEstou == "2"
		aAdd( aObjCoords , {000, 018, .T., .F.} )		//Cabecalho
	Endif
	aAdd( aObjCoords , {000, 000, .T., .T. , .T. } )	//Lisbox
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )


	If cEstou == "2"	//Fatores Avaliacao

		cCadastro	:= OemtoAnsi(STR0030)//"Fatores do Cargo"

		dbSelectArea("SQ3")
		dbSetOrder(2)
		If	dbSeek(xFilial("SQ3")+cGrupo)
			While !Eof() .And. xFilial("SQ3")+cGrupo ==;
								Q3_FILIAL+Q3_GRUPO

				If cCargo == SQ3->Q3_CARGO .And. cCC == SQ3->Q3_CC
					dbSkip()
					Loop
				EndIf

				cDesc		:= SQ3->Q3_DESCSUM
				cCodCargo	:= SQ3->Q3_CARGO
				cCodCC		:= SQ3->Q3_CC

				dbSelectArea("SQ4")
				dbSetOrder(2)
				If dbSeek(xFilial("SQ4")+SQ3->Q3_CARGO+SQ3->Q3_CC)
					While !Eof() .And. xFilial("SQ4")+SQ3->Q3_CARGO+SQ3->Q3_CC ==;
										Q4_FILIAL+Q4_CARGO+Q4_CC

						//Preenche descricao dos fatores e graduacao
						cDescFat	:= TrmDesc("SQ1",SQ3->Q3_GRUPO+SQ4->Q4_FATOR,"SQ1->Q1_DESCSUM")
						cDescGrau 	:= TrmDesc("SQ2",SQ3->Q3_GRUPO+SQ4->Q4_FATOR+SQ4->Q4_GRAU,"SQ2->Q2_DESC")

						AADD(aArrayF4,{cCodCargo,cDesc,cCodCC,SQ4->Q4_FATOR,cDescFat,SQ4->Q4_GRAU,cDescGrau,SQ3->Q3_CARGO,SQ3->Q3_CC})

						dbSkip()
					EndDo
				EndIf

				cDesc		:= Space(30)
				cCodCargo	:= Space(05)
				cCodCC		:= Space(09)

				dbSelectArea("SQ3")
				dbSetOrder(2)
				dbSkip()
			EndDo
		EndIf

		dbSelectArea("SQ3")
		dbSetOrder(1)

		cDescGru := TrmDesc("SQ0",cGrupo,"SQ0->Q0_DESCRIC")

		If Len(aArrayF4) == 0
			Help("",1,"A120NAOHA")						// Nao existe cargo para ser copiado.

			dbSelectArea("SQ3")
			dbSetOrder(1)
			dbGoTo(nRecSq3)
			Return .T.									// Verifique o Grupo do cargo pois deve pertence ao mesmo grupo.
		EndIf

		DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL //3,10 To 18,70 OF oMainWnd
			oGroup:= TGroup():New(aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4],'',oDlg,,,.T.)
			@ aObjSize[1,1]+5,aObjSize[1,2]+5 SAY OemtoAnsi(STR0023)+cGrupo+" - "+cDescGru COLOR CLR_BLUE	OF oDlg PIXEL//"Grupo:   "
			@ aObjSize[2,1],aObjSize[2,2] LISTBOX oQual VAR cVar FIELDS HEADER	OemToAnsi(STR0024),;		//"Cargo"
				OemToAnsi(STR0010),;	   			//"Descricao Cargo"
				OemToAnsi(STR0035),;	   			//"C.Custo"
				OemToAnsi(STR0025),;				//"Fator"
				OemToAnsi(STR0026),;				//"Descricao Fator"
				OemToAnsi(STR0027),;				//"Grau"
				OemToAnsi(STR0028) ;				//"Descricao Grau"
				SIZE aObjSize[2,3],aObjSize[2,4] ;
			ON DBLCLICK (nOpca := 1,oDlg:End()) OF oDlg PIXEL
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6],aArrayF4[oQual:nAT][7]}}
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpca := 1,cEscol := aArrayF4[oQual:nAt][1],cEscolCC := aArrayF4[oQual:nAt][3],oDlg:End())},{|| oDlg:End()}) CENTERED





		If nOpca == 1 			// Confirma
			nPosFator	:= GdFieldPos("Q4_FATOR")
			nPosDesc 	:= GdFieldPos("Q4_DESCFAT")
			nPosGrau	:= GdFieldPos("Q4_GRAU")
			nPosDGrau	:= GdFieldPos("Q4_DESCGRA")

			nPos :=0
			// Controle da 1a vez quando acols vazio
			If Empty(aAuxCols[1][nPosFator]) .And. Empty(aAuxCols[1][nPosGrau])
				For ny:=1 To Len(aArrayF4)
					If cEscol == aArrayF4[ny][1] .And. cEscolCC == aArrayF4[ny][3]
						If nPos != 0
							aAdd(aAuxCols, aClone(aAuxCols[Len(aAuxCols)]))
						EndIf
						nPos := IIf(nPos == 0, 1, Len(aAuxCols))
						IIf(nPosFator 	> 0, aAuxCols[nPos][nPosFator] := aArrayF4[ny][4],)
						IIf(nPosDesc 	> 0, aAuxCols[nPos][nPosDesc]  := aArrayF4[ny][5],)
						IIf(nPosGrau 	> 0, aAuxCols[nPos][nPosGrau]  := aArrayF4[ny][6],)
						IIf(nPosDGrau 	> 0, aAuxCols[nPos][nPosDGrau] := aArrayF4[ny][7],)
						aAuxCols[nPos][Len(aAuxCols[nPos])] := .F.
					EndIf
				Next ny
			Else
				For ny := 1 To Len(aArrayF4)
					If cEscol == aArrayF4[ny][1] .And. cEscolCC == aArrayF4[ny][3]
						lFlag := .F.					// Marcar para incluir um novo registro
						For nx := 1 To Len(aAuxCols)
							If aArrayF4[ny][4] == aAuxCols[nx][nPosFator] .And.;
								!aAuxCols[nx][Len(aAuxCols[nx])]
								If aArrayF4[ny][6] != aAuxCols[nx][nPosGrau]
									aAuxCols[nx][Len(aAuxCols[nx])] := .T.	// Marcar como deletado
									lExiste	:= .T.								// Flag da mensagem
								Else
									lFlag 	:= .T.
								EndIf
								Exit
							EndIf
						Next nx
						If !lFlag
							aAdd(aAuxCols, aClone(aAuxCols[Len(aAuxCols)]))
							nPos := Len(aAuxCols)
							IIf(nPosFator 	> 0, aAuxCols[nPos][nPosFator] := aArrayF4[ny][4],)
							IIf(nPosDesc 	> 0, aAuxCols[nPos][nPosDesc]  := aArrayF4[ny][5],)
							IIf(nPosGrau 	> 0, aAuxCols[nPos][nPosGrau]  := aArrayF4[ny][6],)
							IIf(nPosDGrau 	> 0, aAuxCols[nPos][nPosDGrau] := aArrayF4[ny][7],)
							aAuxCols[nPos][Len(aAuxCols[nPos])] := .F.
							lFlag:= .F.
						EndIf
					EndIf
				Next ny

				If lExiste
					Help(" ",1,"A120EXISTE")	// Existe fator do cargo igual ao cargo que esta sendo copiado.
				EndIf							// Verifique pois o fator foi marcado como deletado.
			EndIf

			n		:= Len(aAuxCols)
			aCols	:= aClone(aAuxCols)
			o2Get:ForceRefresh(.T.)
		EndIf


	ElseIf cEstou == "3"	//Cursos

		cCadastro	:= OemtoAnsi(STR0033)//"Cursos do Cargo"

		dbSelectArea("SQ3")
		dbSetOrder(2)
		If	dbSeek(xFilial("SQ3")+cGrupo)
			While !Eof() .And. xFilial("SQ3")+cGrupo ==;
								Q3_FILIAL+Q3_GRUPO

				If cCargo == SQ3->Q3_CARGO .And. cCC == SQ3->Q3_CC
					dbSkip()
					Loop
				EndIf

				cDesc		:= SQ3->Q3_DESCSUM
				cCodCargo	:= SQ3->Q3_CARGO
				cCodCC		:= SQ3->Q3_CC

				dbSelectArea("RA5")
				dbSetOrder(2)
				If dbSeek(xFilial("RA5")+SQ3->Q3_CARGO+SQ3->Q3_CC)
					While !Eof() .And. xFilial("RA5")+SQ3->Q3_CARGO+SQ3->Q3_CC ==;
										RA5_FILIAL+RA5_CARGO+RA5_CC

						//Preenche descricao dos fatores e graduacao
						cDescCurso	:= TrmDesc("RA1",RA5->RA5_CURSO,"RA1->RA1_DESC")

						AADD(aArrayF4,{cCodCargo,cDesc,cCodCC,RA5->RA5_CURSO,cDescCurso,SQ3->Q3_CARGO,SQ3->Q3_CC})

						cDesc		:= Space(30)
						cCodCargo	:= Space(05)
						cCodCC		:= Space(09)

						dbSkip()
					EndDo
				EndIf

				dbSelectArea("SQ3")
				dbSetOrder(2)
				dbSkip()
			EndDo
		EndIf

		dbSelectArea("SQ3")
		dbSetOrder(1)

		cDescGru := TrmDesc("SQ0",cGrupo,"SQ0->Q0_DESCRIC")

		If Len(aArrayF4) == 0
			Help("",1,"A120NAOHA")						// Nao existe cargo para ser copiado.

			dbSelectArea("SQ3")
			dbSetOrder(1)
			dbGoTo(nRecSq3)
			Return .T.									// Verifique o Grupo do cargo pois deve pertence ao mesmo grupo.
		EndIf


		DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],10 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//3,10 To 18,70 OF oMainWnd

			@ aObjSize[1,1],aObjSize[1,2] LISTBOX oQual VAR cVar FIELDS HEADER	OemToAnsi(STR0024),;	//"Cargo"
			OemToAnsi(STR0010),;	   			//"Descricao Cargo"
			OemToAnsi(STR0035),;	   			//"C.Custo"
			OemToAnsi(STR0036),;	   			//"Curso"
			OemToAnsi(STR0034) SIZE aObjSize[1,3],aObjSize[1,4];	//"Descricao Curso"
			ON DBLCLICK (nOpca := 1,oDlg:End()) of oDlg PIXEL
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5]}}
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpca := 1,cEscol := aArrayF4[oQual:nAt][6],cEscolCC := aArrayF4[oQual:nAt][7],oDlg:End())},{|| oDlg:End()}) CENTERED

		If nOpca == 1 			// Confirma
			nPosCurso	:= GdFieldPos("RA5_CURSO")
			nPosDesc 	:= GdFieldPos("RA5_DESCCU")

			nPos :=0
			// Controle da 1a vez quando acols vazio
			If Empty(aAuxCols[1][nPosCurso])
				For ny := 1 To Len(aArrayF4)
					If cEscol == aArrayF4[ny][6] .And. cEscolCC == aArrayF4[ny][7]
						If nPos != 0
							aAdd(aAuxCols, aClone(aAuxCols[Len(aAuxCols)]))
						EndIf
						nPos := IIf(nPos == 0, 1, Len(aAuxCols))
						IIf(nPosCurso 	> 0, aAuxCols[nPos][nPosCurso] := aArrayF4[ny][4],)
						IIf(nPosDesc 	> 0, aAuxCols[nPos][nPosDesc]  := aArrayF4[ny][5],)

						aAuxCols[nPos][Len(aAuxCols[nPos])] := .F.
					EndIf
				Next ny
			Else
				For ny := 1 To Len(aArrayF4)
					If cEscol == aArrayF4[ny][6] .And. cEscolCC == aArrayF4[ny][7]
						lFlag := .F.					// Marcar para incluir um novo registro
						For nx := 1 To Len(aAuxCols)
							If aArrayF4[ny][4] == aAuxCols[nx][nPosCurso] .And.;
								!aAuxCols[nx][Len(aAuxCols[nx])]
								lFlag 	:= .T.
								Exit
							EndIf
						Next nx
						If !lFlag
							Aadd(aAuxCols, aClone(aAuxCols[Len(aAuxCols)]))
							nPos := Len(aAuxCols)
							IIf(nPosCurso 	> 0, aAuxCols[nPos][nPosCurso] := aArrayF4[ny][4],)
							IIf(nPosDesc 	> 0, aAuxCols[nPos][nPosDesc]  := aArrayF4[ny][5],)

							aAuxCols[nPos][Len(aAuxCols[nPos])] := .F.
							lFlag:= .F.
						EndIf
					EndIf
				Next ny

				If lExiste
					Help(" ",1,"A120EXISTE")	// Existe fator do cargo igual ao cargo que esta sendo copiado.
				EndIf							// Verifique pois o fator foi marcado como deletado.
			EndIf

			n		:= Len(aAuxCols)
			aCols	:= aClone(aAuxCols)
			o2Get:ForceRefresh(.T.)
		EndIf

	EndIf
	If cEstou ="2" .OR. cEstou = "3"
		aLisPast[Val(cEstou)][2] := aCols
	Endif

	dbSelectArea("SQ3")
	dbSetOrder(1)
	dbGoTo(nRecSq3)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tr020Depto³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a unidade de trabalho do grupo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Tr020Depto                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr020Depto()
	Local aSaveArea	:= GetArea()
	Local lRet		:= .T.
	Local cDepto	:= M->Q3_DEPTO

	If Empty(cDepto)
		cDepto := &(ReadVar())
	EndIf

	If !Empty(cDepto)
		dbSelectArea("SQB")
		dbSetOrder(1)

		If !dbSeek(xFilial("SQB")+cDepto)
			Help("",1,"TRA020DEPT")	// Verifique o departamento, pois nao existe para este grupo
			lRet := .F.
		EndIf
	EndIf

	RestArea(aSaveArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tr020Grau ³ Autor ³ Mauro Sergio          ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe o grau para este grupo/fator             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr020Grau()
	Local aSaveArea	:= GetArea()
	Local cGrau 	:= M->Q4_GRAU
	Local nPosFator := GdFieldPos("Q4_FATOR")
	Local nPosPtos  := GdFieldPos("Q4_PONTOS")

	If Empty(cGrau)
		cGrau := &(ReadVar())
	EndIf

	dbSelectArea("SQ2")
	dbSetOrder(1)

	If !dbSeek(xFilial("SQ2")+M->Q3_GRUPO+aCols[n][nPosFator]+cGrau)
		Help("",1,"TRA020GRAU")		// Grau nao cadastrado para este Grupo/Fator
		RestArea(aSaveArea)
		Return .F.
	EndIf

	If nPosPtos > 0
		aCols[n][nPosPtos] := SQ2->Q2_PONTOSI
	EndIf

	RestArea(aSaveArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tr0020Zera ³ Autor ³ Cristina Ogura		³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Zera o acols												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA020		 ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr020Zera()
	Local nx	:= 0
	Local lRet	:= .T.

	For nx := 1 To Len(aHeader)-1
		If !Empty(aCols[1][nx])
			lRet := .F.
			Exit
		EndIf
	Next nx

	If lRet
		aCols := {}
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ Tr020Linha	³ Autor ³ Cristina Ogura	³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a primeira linha esta toda sem preencher		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias											  ³±±
±±³			 ³ ExpN1 : Registro											  ³±±
±±³			 ³ ExpN2 : Opcao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TRMA020		  ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr020Linha()
	Local lTree := .T.
	Local nx	:= 0

	For nx := 1 To Len(aHeader) - 3
		If !Empty(aCols[1][nx])
			lTree := .F.
			Exit
		EndIf
	Next nx
Return lTree


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fTr020Desc³ Autor ³ Mauro Sergio          ³ Data ³ 01.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trazer as Descricoes dos campos Virtuais e Inic.Padrao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ (cAlias,cCpoRet,cCodPesq,lRelac)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTr020Desc(cAlias,cCpoRet,cCodPesq,lRelac)
	Local aSaveArea := GetArea()
	Local cPesq 	:= ""
	Local nPosHead	:= 0
	Local nPos		:= 0
	Local cRet		:= ""
	Local lRet		:= .F.
	Local cContFat 	:= ""
	Local cGrupo	:= ""

	Private cConteudo := ""
	cPesq := If (lRelac,cCodPesq,ReadVar())

	nPosHead := GdFieldPos(cPesq)
	If nPosHead > 0
		cConteudo := aCols[Len(aCols),nPosHead]
	Elseif ! lRelac
		cConteudo := &(ReadVar())
	Endif

	If "FATOR"$ AllTrim(cPesq)
		cGrupo := M->Q3_GRUPO
		If Empty(cGrupo)
			cGrupo := SQ3->Q3_GRUPO
		EndIf
		cRet := TrmDesc(cAlias,cGrupo+cConteudo,"SQ1->Q1_DESCSUM")
	ElseIf "GRAU"$ AllTrim(cPesq)
		If ! lRelac
			nPosHead := GdFieldPos("Q4_FATOR")
			If nPosHead > 0
				cContFat := aCols[n,nPosHead]
			Endif
		EndIf
		cGrupo := M->Q3_GRUPO
		If Empty(cGrupo)
			cGrupo := SQ3->Q3_GRUPO
		EndIf
		cRet := TrmDesc(cAlias,(cGrupo+If(lRelac,SQ4->Q4_FATOR,cContFat)+cConteudo),"SQ2->Q2_DESC")
	ElseIf "CURSO"$ AllTrim(cPesq)
		cRet := TrmDesc(cAlias,cConteudo,"RA1->RA1_DESC")
	EndIf

	If ! lRelac
		//--Igualar no Acols o Descricao
		nPos := GdFieldPos(cCpoRet)
		If nPos > 0
			aCols[n,nPos] := cRet
			lRet := .T.
		EndIf
	Else
		lRet := cRet
	EndIf

	RestArea(aSaveArea)

	Return(lRet)

// Atualiza os pontos do cargo, apos ter digitado os pontos da graduacao
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tr020Pontos   ³ Autor ³ Cristina Ogura   ³ Data ³ 05/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os ptos do cargo apos ter digitado os ptos graduac³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr020Pontos                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr020Pontos(aAuxHeader,aAuxCols,nOpcx)
	Local nPosPontos	:= GdFieldPos("Q4_PONTOS", aAuxHeader)
	Local nTotPontos	:= 0
	Local nx    		:= 0

	// Exclusao e Visualizacao
	If 	nOpcx == 5 .Or. nOpcx == 2
		Return .T.
	EndIf

	For nx:= 1 To Len(aAuxCols)
		If !aAuxCols[nx][Len(aAuxCols[nx])]			//Verifico deletado
			nTotPontos += aAuxCols[nx][nPosPontos]
		EndIf
	Next nx


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso tenha pontos informado nos fatores, atualiza Pontos do Cargo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotPontos > 0
		M->Q3_PONTOSI := nTotPontos
	EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tr020VerF     ³ Autor ³ Cristina Ogura   ³ Data ³ 17/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem todos os fatores no SQV.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr020VerF                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr020VerF(lRet,cAuxFil,cAuxCargo,cAuxCC)
	Local aSaveArea	:= GetArea()
	Local aSQ4		:= {}

	cAuxFil:= xFilial("SQ4", cAuxFil)

	dbSelectArea("SQ4")
	dbSetOrder(2)
	If 	dbSeek(cAuxFil+cAuxCargo)
		ProcRegua(SQ4->(Reccount()))
		While !Eof() .And. SQ4->Q4_FILIAL+SQ4->Q4_CARGO+SQ4->Q4_CC == cAuxFil+cAuxCargo+cAuxCC
			IncProc()
			Aadd(aSQ4,{SQ4->Q4_FILIAL,SQ4->Q4_FATOR,SQ4->Q4_GRAU})
			dbSkip()
		EndDo
	EndIf

	If 	!FVerFatG(aSQ4)
		lRet := .F.
	EndIf

	RestArea(aSaveArea)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tr020CC       ³ Autor ³ Emerson Grassi   ³ Data ³ 25/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo Centro de Custos.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr020CC	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tr020CC()
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local nRecno	:= SQ3->( Recno() )

	If Type("lCopy") == "U"	// GPEA370
		lCopy := .F.
	EndIf
	If Type("lInclui") == "U"
		lInclui := .F.
	EndIf

	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3") + M->Q3_CARGO + M->Q3_CC) .And.;
		(( lInclui .Or. lCopy ) .Or. ( nRecno != SQ3->(Recno()) ))

		Help(,,STR0031,,OemToAnsi(STR0032),1,0)  //"Atencao"###"Esse Centro de Custo ja foi cadastrado para este cargo."
		lRet := .F.
	Else
		M->Q3_DESCCC := RhDescCC(M->Q3_CC)
	EndIf

	RestArea(aSaveArea)
Return lRet



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tr020Neces    ³ Autor ³ Emerson Grassi   ³ Data ³ 10/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe Necessidade Treinamento e Exclui.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tr020Neces                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr020Neces(nx)
	Local aSaveArea	:= GetArea()
	Local nPosCurso	:= GdFieldPos("RA5_CURSO")
	Local nI		:= 0
	Local lApaga	:= .T.
	Local cCurso	:= aCols[nx][nPosCurso]
	Local cCargo	:= ""

	// Variaveis IndRegua
	Local cArqRA3	:= ""
	Local cIndCond	:= ""
	Local cFor		:= ""
	Local nIndex	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se alem da linha deletada existe mesmo curso nao deletado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aCols)
		If aCols[nI][nPosCurso] == aCols[nx][nPosCurso] .And. !aCols[nI][Len(aCols[nI])]
			lApaga := .F.
		EndIf
	Next nI

	If lApaga
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IndRegua por Curso no RA3 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("RA3")
		dbSetOrder(1)

		dbGoTop()
		cIndCond	:= "RA3_CURSO+RA3_FILIAL"
		cFor		:= 'RA3_CURSO =="'+ cCurso +'"'

		cArqRA3  := CriaTrab(NIL,.F.)
		IndRegua("RA3",cArqRA3,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
		nIndex := RetIndex("RA3")

		#IFNDEF TOP
			dbSetIndex(cArqRA3+OrdBagExt())
		#ENDIF

		dbSetOrder(nIndex+1)
		dbSeek(cCurso)

		While !Eof()

			If RA3->RA3_RESERV == "S" .And. Empty(RA3->RA3_CALEND)

				dbSelectArea("SRA")
				dbSetOrder(1)
				If dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT)

				    cCargo := fGetCargo(SRA->RA_MAT)

					If cCargo1 == cCargo

						If Empty(cCC1) .Or. ( !Empty(cCC1) .And. cCC1 == SRA->RA_CC )

							dbSelectArea("RA3")
							RecLock("RA3",.F.)
								dbDelete()
							MsUnlock()
						EndIf
					EndIf
				EndIf
			EndIf

			dbSelectArea("RA3")
			dbSkip()
		EndDo

		dbSelectArea("RA3")
		Set Filter To
		RetIndex("RA3")
		dbSetOrder(1)
		FErase (cArqRA3+OrdBagExt())

	EndIf

	RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TRM020Copy³ Autor ³ Emerson Grassi Rocha ³ Data ³ 11/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia Cargo existente para novo Cargo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA020       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TRM020Copy(cAlias,nReg,nOpcx,aCpos)
	Trm020Rot(cAlias, nReg, nOpcx, aCpos)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TR020Gru  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 14/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo Q3_GRUPO (When)		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR020Gru()
Local lRet		:= .F.
Local cKeyDel	:= SQ3->Q3_CARGO
Local aAreas	:= {}
Local cAlias	:= "SQ3"
Local aRegist	:= {}

IF ( Type("nOpcx") == "U" )
	Private nOpcx := 0
Endif

//Controle de preenchimento do nOpcao para chamadas externas.
Iif( Type("nOpcao") == "U", nOpcao := nOpcx, nOpcao)

//-- Para manter o mesmo comportamento de versoes anteriores, o grupo somente pode ser modificado
//-- na inclusao ou na sua ausencia. Como na opcao Copia forcamos a variavel INCLUI foi
//-- necessario impedir o seu comportamento na escolha do Grupo (devido ao legado).
If ( Inclui .Or. Empty(SQ3->Q3_GRUPO) ) .AND. nOpcao <> 6
	lRet := .T.
Elseif !Empty(SQ3->Q3_GRUPO)
	aAdd( aAreas , Array( 03 ) )
	nAreas := Len( aAreas )
	aAreas[nAreas,01] := SQ4->( GetArea() )
	aAreas[nAreas,02] := {"Q4_FILIAL","Q4_CARGO"}
	aAreas[nAreas,03] := RetOrdem( "SQ4" , "Q4_FILIAL+Q4_CARGO" , .T. )

	aAdd( aAreas , Array( 03 ) )
	nAreas := Len( aAreas )
	aAreas[nAreas,01] := RBH->( GetArea() )
	aAreas[nAreas,02] := {"RBH_FILIAL","RBH_CARGO"}
	aAreas[nAreas,03] := RetOrdem( "RBH" , "RBH_FILIAL+RBH_GRUPO+RBH_CARGO" , .T. )
	lRet  := ChkDelRegs(	cAlias				,;	//Alias do Arquivo Principal
								SQ3->( Recno() ) 	,;	//Registro do Arquivo Principal
								nOpcao				,;	//Opcao para a AxDeleta
								xFilial( cAlias )		,;	//Filial do Arquivo principal para Delecao
								cKeyDel					,;	//Chave do Arquivo Principal para Delecao
								aAreas					,;	//Array contendo informacoes dos arquivos a serem pesquisados
								NIL						,;	//Mensagem para MsgYesNo
								NIL						,;	//Titulo do Log de Delecao
								NIL						,;	//Mensagem para o corpo do Log
								.F.				 		,;	//Se executa AxDeleta
								.F.						,;	//Se deve Mostrar o Log
								@aRegist				,;	//Array com o Log de Exclusao
								NIL				 		,;	//Array com o Titulo do Log
								NIL						,;	//Bloco para Posicionamento no Arquivo
								NIL						,;	//Bloco para a Condicao While
								NIL						,;	//Bloco para Skip/Loop no While
								.F.						,;	//Verifica os Relacionamentos no SX9
								NIL						,;	//Alias que nao deverao ser Verificados no SX9
								.F.				 	 	,;	//Se faz uma checagem soft
								.T.				 ;  //Se esta executando rotina automatica
							)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR020NewRbh³ Autor ³ Emerson Grassi Rocha ³ Data ³ 26/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche GetDados atraves de RBM / RBJ na 1a Vez.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR020NewRbh()
	Local cCodCom	:= ""
	Local nx		:= 0
	Local aLinCols 	:= aClone(aCols)	//Linha em branco do Acols
	Local aAuxCols	:= {}

	Local nPosComp	:= GdFieldPos("RBH_CODCOM")
	Local nPosDCdCom:= GdFieldPos("RBH_DCDCOM")
	Local nPosItem	:= GdFieldPos("RBH_ITECOM")
	Local nPosDItCom:= GdFieldPos("RBH_DITCOM")
	Local nPosHabil	:= GdFieldPos("RBH_HABIL")
	Local nPosDHabil:= GdFieldPos("RBH_DHABIL")
	Local nPosEsc	:= GdFieldPos("RBH_ESCALA")
	Local nPosDEsc	:= GdFieldPos("RBH_DESCAL")
	Local nPosImp	:= GdFieldPos("RBH_IMPORT")
	Local nPosDImp	:= GdFieldPos("RBH_DIMPOR")

	If Len(aCols) == 1 .And. Empty(aCols[1][nPosComp]) // Inclusao
		dbSelectArea("RBM")
		dbSetOrder(1)
		dbSeek(xFilial("RBM")+cGrupo)
		While !Eof() .And. cGrupo == RBM->RBM_GRUPO

			cCodCom := RBM->RBM_CODCOM
			aAuxCols:= Aclone(aCols)

			dbSelectArea("RBJ")
			dbSetOrder(1)
			dbSeek(xFilial("RBJ")+cCodCom)
			While !Eof() .And. cCodCom == RBJ->RBJ_CODCOM
				nx++
				aAuxCols := Aclone(aLinCols)

				If nx > 1
					Aadd(aCols, aAuxCols[1])
				EndIf

				aCols[nx][nPosComp]			:= RBJ->RBJ_CODCOM
				aCols[nx][nPosDCdCom]		:= FDesc("RDM",RBJ->RBJ_CODCOM,"RDM_DESC")
				aCols[nx][nPosItem]			:= RBJ->RBJ_ITECOM
				aCols[nx][nPosDItCom]		:= FDesc("RD2",RBJ->RBJ_CODCOM+RBJ->RBJ_ITECOM,"RD2_DESC")
				aCols[nx][nPosHabil]		:= RBJ->RBJ_HABIL
				aCols[nx][nPosDHabil]		:= FDesc("RBG",RBJ->RBJ_HABIL,"RBG_DESC")
				aCols[nx][nPosEsc]			:= RBJ->RBJ_ESCALA
				aCols[nx][nPosDEsc]			:= FDesc("RBK",RBJ->RBJ_ESCALA,"RBK_DESCRI")
				aCols[nx][nPosImp]			:= RBJ_IMPORT
				aCols[nx][nPosDImp]			:= FDesc("RBK",RBJ->RBJ_IMPORT,"RBK_DESCRI")

				dbSkip()
			EndDo

			dbSelectArea("RBM")
			dbSkip()
		EndDo

	EndIf

	If lTrm020Hab
		ExecBlock( "TRM020HAB", .F., .F. )
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TR020NewSq4  ³ Autor   ³ Allyson M     ³ Data ³ 28/10/14    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche GetDados atraves de SQ1 / SQ2 na 1a Vez.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR020NewSq4()
	Local cCodFat	:= ""
	Local nx		:= 0
	Local aLinCols 	:= aClone(aCols)	//Linha em branco do Acols
	Local aAuxCols	:= {}

	Local nPosFat	:= GdFieldPos("Q4_FATOR")
	Local nPosDFat:= GdFieldPos("Q4_DESCFAT")
	Local nPosGrau	:= GdFieldPos("Q4_GRAU")
	Local nPosDGrau:= GdFieldPos("Q4_DESCGRA")
	Local nPosPontos	:= GdFieldPos("Q4_PONTOS")
	Local lModCSA		:= (cModulo == "CSA" )

	If Len(aCols) == 1 .And. Empty(aCols[1][nPosFat]) // Inclusao
		dbSelectArea("SQ1")
		dbSetOrder(1)
		dbSeek(xFilial("SQ1") + cGrupo)
		While !Eof() .And. SQ1->Q1_GRUPO == cGrupo
			nx++
			cCodFat := SQ1->Q1_FATOR
			aAuxCols:= Aclone(aLinCols)

			dbSelectArea("SQ2")
			dbSetOrder(1)

			If dbSeek(xFilial("SQ2") + cGrupo + cCodFat)
				If nx > 1
					Aadd(aCols, aAuxCols[1])
				EndIf

				aCols[nx][nPosFat]		:= cCodFat
				aCols[nx][nPosDFat]		:= SQ1->Q1_DESCSUM
				aCols[nx][nPosGrau]		:= SQ2->Q2_GRAU
				aCols[nx][nPosDGrau]	:= SQ2->Q2_DESC
				If 	lModCSA
					aCols[nx][nPosPontos]	:= SQ2->Q2_PONTOSI
				EndIf
			EndIf

			dbSelectArea("SQ1")
			dbSkip()
		EndDo
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RbhItEscWhen³ Autor³ Emerson Grassi Rocha ³ Data ³ 26/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega variaveis de Memoria da Linha corrente do aCols.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN do campo RBH_ITESCA.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RbhItEscWhen()
	Local nx 		:= 0
	Local nUsaHab	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria as Variaveis de Memoria - Habilidades (RBH)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsaHab := Len(aHeader)
	For nX := 1 To nUsaHab
		&("M->"+aHeader[nx][2]) := aCols[n][nx]
	Next nX
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RbhItImpWhen³ Autor³ Emerson Grassi Rocha ³ Data ³ 26/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega variaveis de Memoria da Linha corrente do aCols.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³				                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ X3_WHEN do campo RBH_ITIMPO.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RbhItImpWhen()
	Local nx 		:= 0
	Local nUsaHab	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria as Variaveis de Memoria - Habilidades (RBH)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsaHab := Len(aHeader)
	For nX := 1 To nUsaHab
		&("M->"+aHeader[nx][2]) := aCols[n][nx]
	Next nX
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Sq3CcWhen  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When do campo Q3_CC.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Sq3CcWhen()				                     		   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                               	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN do Campo Q3_CC									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Sq3CcWhen()
	Local lRet		:= .F.
	Local cKeyDel	:= SQ3->Q3_CARGO+SQ3->Q3_CC
	Local aAreas	:= {}
	Local cAlias	:= "SQ3"
	Local aRegist	:= {}

	lCopy	:= If(Type("lCopy")=="L",lCopy,.F.)

	If Inclui .Or. lCopy
		lRet := .T.
	Else
		aAdd( aAreas , Array( 03 ) )
		nAreas := Len( aAreas )
		aAreas[nAreas,01] := SQ4->( GetArea() )
		aAreas[nAreas,02] := {"Q4_FILIAL","Q4_CARGO","Q4_CC"}
		aAreas[nAreas,03] := RetOrdem( "SQ4" , "Q4_FILIAL+Q4_CARGO+Q4_CC" , .T. )

		aAdd( aAreas , Array( 03 ) )
		nAreas := Len( aAreas )
		aAreas[nAreas,01] := RA5->( GetArea() )
		aAreas[nAreas,02] := {"RA5_FILIAL","RA5_CARGO","RA5_CC"}
		aAreas[nAreas,03] := RetOrdem( "RA5" , "RA5_FILIAL+RA5_CARGO+RA5_CC" , .T. )
		lRet  := ChkDelRegs(	cAlias				,;	//Alias do Arquivo Principal
									SQ3->( Recno() ) 	,;	//Registro do Arquivo Principal
									nOpcao				,;	//Opcao para a AxDeleta
									xFilial( cAlias )		,;	//Filial do Arquivo principal para Delecao
									cKeyDel					,;	//Chave do Arquivo Principal para Delecao
									aAreas					,;	//Array contendo informacoes dos arquivos a serem pesquisados
									NIL						,;	//Mensagem para MsgYesNo
									NIL						,;	//Titulo do Log de Delecao
									NIL						,;	//Mensagem para o corpo do Log
									.F.				 		,;	//Se executa AxDeleta
									.F.						,;	//Se deve Mostrar o Log
									@aRegist				,;	//Array com o Log de Exclusao
									NIL				 		,;	//Array com o Titulo do Log
									NIL						,;	//Bloco para Posicionamento no Arquivo
									NIL						,;	//Bloco para a Condicao While
									NIL						,;	//Bloco para Skip/Loop no While
									.F.						,;	//Verifica os Relacionamentos no SX9
									NIL						,;	//Alias que nao deverao ser Verificados no SX9
									.F.				 	 	,;	//Se faz uma checagem soft
									.T.				 ;  //Se esta executando rotina automatica
								)
		If lRet
			aAreas := {}
			cKeyDel := SQ3->Q3_CARGO+SQ3->Q3_GRUPO+SQ3->Q3_CC
			aAdd( aAreas , Array( 03 ) )
			nAreas := Len( aAreas )
			aAreas[nAreas,01] := RBH->( GetArea() )
			aAreas[nAreas,02] := {"RBH_FILIAL","RBH_GRUPO","RBH_CARGO","RBH_CC"}
			aAreas[nAreas,03] := RetOrdem( "RBH" , "RBH_FILIAL+RBH_GRUPO+RBH_CARGO+RBH_CC" , .T. )

			lRet  := ChkDelRegs(	cAlias				,;	//Alias do Arquivo Principal
										SQ3->( Recno() ) 	,;	//Registro do Arquivo Principal
										nOpcao				,;	//Opcao para a AxDeleta
										xFilial( cAlias )		,;	//Filial do Arquivo principal para Delecao
										cKeyDel					,;	//Chave do Arquivo Principal para Delecao
										aAreas					,;	//Array contendo informacoes dos arquivos a serem pesquisados
										NIL						,;	//Mensagem para MsgYesNo
										NIL						,;	//Titulo do Log de Delecao
										NIL						,;	//Mensagem para o corpo do Log
										.F.				 		,;	//Se executa AxDeleta
										.F.						,;	//Se deve Mostrar o Log
										@aRegist				,;	//Array com o Log de Exclusao
										NIL				 		,;	//Array com o Titulo do Log
										NIL						,;	//Bloco para Posicionamento no Arquivo
										NIL						,;	//Bloco para a Condicao While
										NIL						,;	//Bloco para Skip/Loop no While
										.F.						,;	//Verifica os Relacionamentos no SX9
										NIL						,;	//Alias que nao deverao ser Verificados no SX9
										.F.				 	 	,;	//Se faz uma checagem soft
										.T.				 ;  //Se esta executando rotina automatica
									)
		EndIf
	EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrmFatorF3 ³ Autor ³ Eduardo Ju           ³ Data ³ 09.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo XB_CONTEM no SXB **CSXBFATOR**           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSP*TRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmFatorF3()
	Local cRet

	IF (Type("CSXBFATOR") == "U") .AND. (FUNNAME() == "TRMA020")
		cRet:= SQ2->Q2_FATOR
	ElseIf FunName() == "RSPM002"
		cRet := SQV->QV_FATOR //Ira aparecer todos os graus cadastrados
	Else
		cRet:= CSXBFATOR
	EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RbhHabilVld³ Autor ³ Emerson Grassi Rocha ³ Data ³ 23/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aleracao do campo RBH_HABIL	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³X3_VALID do campo RBH_HABIL.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RbhHabilVld()
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local cCodCom 	:= GDFieldGet("RBH_CODCOM", n)
	Local cIteCom 	:= GDFieldGet("RBH_ITECOM", n)
	Local cHabil  	:= GetMemVar( "RBH_HABIL" )

	dbSelectArea("RBJ")
	dbSetOrder(1)
	If !( lRet := dbSeek(xFilial("RBJ")+cCodCom+cIteCom+cHabil) )
		Aviso(STR0031, STR0048, {"Ok"})	//"Atencao"###"Informe uma Habilidade valida para este Item de Competencia."
	EndIf

	RestArea(aSaveArea)
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³22/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA020                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//³    6 - Alteracao sem inclusao de registro                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 Local aRotina := { 	{ STR0002	,"PesqBrw"		, 0 , 1,,.F.},;	//"Pesquisar"
							{ STR0003	,"TRM020Rot"	, 0 , 2},;			//"Visualizar"
							{ STR0004	,"TRM020Rot"	, 0 , 3},;			//"Incluir"
							{ STR0005	,"TRM020Rot"	, 0 , 4},;			//"Alterar"
							{ STR0006	,"TRM020Rot"	, 0 , 5},;			//"Excluir"
							{ STR0015	,"TRM020Copy"	, 0 , 4} }			//"Copiar"

Return aRotina



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr020obter³ Autor ³ Joeudo Santana	    ³ Data ³ 05.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que localiza e retorna o aCols e a Header	da pasta  ³±±
±±³			 ³indicada pelo parametro nPasta. Caso o aCols nao tenha sido ³±±
±±³			 ³carregado, e feita a chamada para a funcao Tr020Fill.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr020obter(nPasta, aHeadAux, aColAux,nOpcx)
	If (aLisPast[nPasta] == Nil)
	   	aLisPast[nPasta]:= TR020FillG(nPasta, nOpcx)
	EndIf

	aHeadAux:= aClone(aLisPast[nPasta][1])
	aColAux:= aClone(aLisPast[nPasta][2])
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³TR020FillG³ Autor ³ Joeudo Santana	    ³ Data ³ 03/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem das Getdados aHeader,aCols com adequaçã à		  ³±±
±±³		     ³ funcionalidade do Walk Trhu                     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx,cAlias, nOrder, cSeekKey, bSeekWhile, aNoFields      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TrmA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR020FillG(nPasta,nOpcx)
 	Do Case
		Case nPasta = 2
			cAlias		:="SQ4"						 						//2-cAlias - area a ser utilizada;
			nOrder		:=2													//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
   			cSeekKey	:=cChave											//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:={|| SQ4->Q4_FILIAL + SQ4->Q4_CARGO+ SQ4->Q4_CC}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"Q4_FILIAL","Q4_CARGO","Q4_DESCCAR"}			//7-aNoFields - array contendo os campos que não estarão no aHeader;
	    Case  nPasta = 3
	      	cAlias		:="RA5"						 							//2-cAlias - area a ser utilizada;
			nOrder		:=2														//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
   			cSeekKey	:=cChave												//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:={|| RA5->RA5_FILIAL + RA5->RA5_CARGO+ RA5->RA5_CC}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RA5_FILIAL","RA5_CARGO"}							//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
        Case  nPasta = 4
         	cAlias		:= "RBH"						 				 							//2-cAlias - area a ser utilizada;
			nOrder		:= 2  																		//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			cSeekKey	:= cChavRBH													 				//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:= {|| RBH->RBH_FILIAL + RBH->RBH_GRUPO + RBH->RBH_CARGO + RBH->RBH_CC}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RBH_FILIAL","RBH_GRUPO","RBH_CARGO"}									//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
    EndCase


	FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAlias					,; //2-cAlias - area a ser utilizada;
				 nOrder					,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 	 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					)  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}


	// Posiciona no final do arquivo para que o Inicialiazador padrao apresente os campos em branco
	dbSelectArea(cAlias)
	dbGoBottom()
	dbSkip()
Return  {aHeader, aCols}



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RbhCamposVld ³ Autor ³ Joeudo Santana	      ³ Data ³05/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos campos RBH_ITECOM, RBH_ITESCA e RBH_ITIMPO     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³X3_VALID dos campos RBH_ITECOM, RBH_ITESCA e RBH_ITIMPO      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RbhCamposVld(cAlias, cPrincCampo, cRelacCampo)
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local cCampoPrinc
	Local cCampoRelac

	If IsInGetDados( { cPrincCampo } )
		cCampoRelac 	:= GDFieldGet(cRelacCampo, n)
		cCampoPrinc 	:= &("M->" + cPrincCampo)
	Else
		cCampoRelac 	:= &("M->" + cRelacCampo)
		cCampoPrinc 	:= &("M->" + cPrincCampo)
	EndIf

	If !(NaoVazio().and.ExistCpo(cAlias,cCampoRelac+cCampoPrinc))
		lRet := .F.
	EndIf

	RestArea(aSaveArea)
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RbhCodCom	   ³ Autor ³ Joeudo Santana	      ³ Data ³05/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posiciona no Registro que esta sendo manipulado na GetDados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consulta Padrao: RD2001		                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RbhCodCom()
	Local aSaveArea := GetArea()

	If IsInGetDados( { "RBH_CODCOM" } )
		cCodCom	:= GDFieldGet("RBH_CODCOM", n)
	Else
		cCodCom := M->RBH_CODCOM
	EndIf

	RestArea(aSaveArea)
Return cCodCom

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAtiv()
Função que efetua a verificação se há funcionários ativos vinculados ao cargo
@author  Allyson Luiz Mesashi
@since   28/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAtiv( cCodCargo )

Local cAliasQRY	:= "QRYSRA"
Local cQuery	:= ""
Local cTabSRA	:= RetSqlName("SRA")
Local cTabSQ3	:= RetSqlName("SQ3")
Local lTemAtiv	:= .F.

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSQ3 + " SQ3 "
cQuery 	+= "INNER JOIN " + cTabSRA + " SRA "
cQuery 	+= "ON " + FWJoinFilial( "SQ3", "SRA" ) + " AND SRA.RA_CARGO = SQ3.Q3_CARGO AND SRA.RA_SITFOLH != 'D' AND SRA.D_E_L_E_T_ = ' ' " 
cQuery 	+= "WHERE SQ3.Q3_FILIAL = '" + xFilial("SQ3") + "' "
cQuery 	+= "AND SQ3.Q3_CARGO = '" + cCodCargo + "' "
cQuery 	+= "AND SQ3.D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

lTemAtiv := (cAliasQRY)->CONT > 0

(cAliasQRY)->( dbCloseArea() )

Return lTemAtiv
