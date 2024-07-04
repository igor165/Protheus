#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA011.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFA011  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao do cadastro de rateios de despesas  ³±±
±±³			 ³ do bem													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ATFA011()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATF - Localizacao Argentina/Brasil                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ATFA011()

Local aCores		:= {	{ ' NV_MSBLQL == "1" .AND. NV_STATUS $ "1|2|3|4|5" ','BR_PRETO'	 	},;//Rateio Bloqueado
{ ' NV_STATUS == "1" ','ENABLE'    		},;	//Rateio Disponível
{ ' NV_STATUS == "2" ','BR_AMARELO'   	},;	//Pendente de classificação
{ ' NV_STATUS == "3" ','BR_AZUL'		},;	//Rateio vinculado a Bem (Ativo)
{ ' NV_STATUS == "4" ','BR_LARANJA'		},;	//Ativo Baixado
{ ' NV_STATUS == "5" ','DISABLE'	 	}}	//Rateio Finalizado

Local cFilQry		:= ""

Private cCadastro 	:= STR0001	//"Rateio de despesas de depreciacao do imobilizado"
Private aRotina   	:= MenuDef()

dbSelectArea("SNV")
dbSetOrder(1)

If SuperGetMv("MV_ATFRFIL",,.F.)
	
	cFilQry := "	R_E_C_N_O_ IN ( "
	cFilQry += "				SELECT MAX(R_E_C_N_O_)  "
	cFilQry += "				FROM  "
	cFilQry += "					" + RetSqlName("SNV") "
	cFilQry += "				WHERE D_E_L_E_T_ = ' '"
	cFilQry += "				GROUP BY  "
	cFilQry += "					NV_FILIAL,  "
	cFilQry += "					NV_CODRAT,  "
	cFilQry += "					NV_REVISAO)	 "
	
Endif

mBrowse(006,001,022,075,"SNV",,,,,,aCores,,,,,,,,cFilQry)

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³    6 - Bloqueia ou desbloqueia um cadastro de rateio       ³±±
±±³          ³    7 - Gera uma nova revisao para o registro de rateio, 	  ³±±
±±³          ³utilizado quando um registro nao pode ser alterado.		  ³±±
±±³          ³    8 - Amarra um registro de rateio com algum item da ficha³±±
±±³          ³de ativo.													  ³±±
±±³          ³    9 - Legenda das cores							          ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Menudef()

Local aRotina	:= {}

aAdd(aRotina,{STR0004		,"AxPesqui",0,1})	//"Pesquisar"
aAdd(aRotina,{STR0005		,"Af011Man",0,2})	//"Visualizar"
aAdd(aRotina,{STR0006		,"Af011Man",0,3})	//"Incluir"
aAdd(aRotina,{STR0007		,"Af011Man",0,4})	//"Alterar"
aAdd(aRotina,{STR0008		,"Af011Man",0,5})	//"Excluir"
aAdd(aRotina,{STR0009		,"Af011Blq",0,4})	//"Bloq/Desbloq"
aAdd(aRotina,{STR0010		,"Af011Rev",0,4})	//"Gerar Rev."
aAdd(aRotina,{STR0011		,"Af011Vin",0,4})	//"Vincular"
aAdd(aRotina,{STR0012		,"Af011Len",0,4})	//"Legenda"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011MAN  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada pelo aRotina, opcoes Visualizar, Incluir,  ³±±
±±³			 ³Alterar e Excluir.  										  ³±±
±±³			 ³Responsavel pela manutencao de cadastro, atraves da montagem³±±
±±³			 ³da tela, das chamadas as funcoes de validacoes dos dados    ³±±
±±³			 ³e da chamada da funcao que grava, altera e exclui registros ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011MAN(cAlias,nReg,nOpc)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- String: Alias da Tabela corrente ("FRP")		  ³±±
±±³			 ³nReg		- Numeric: Nro do registro posicionado.			  ³±±
±±³			 ³nOpc		- Numeric: Opcao de manipulacao de dados 		  ³±±
±±³			 ³			2 - Visualizar 		  							  ³±±
±±³			 ³			3 - Incluir 		  							  ³±±
±±³			 ³			4 - Alterar 		  							  ³±±
±±³			 ³			5 - Excluir 		  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011MAN(cAlias,nReg,nOpc)

Local cRevAtu	:= ""

Local aRateio	:= {}

Local lMan		:= .f.
Local lValid	:= .t.

Local nOpcA		:= 0

//Executa as Validacoes das opcoes do Menu aRotina
lValid := AF011VALID(nOpc)

If lValid
	If nOpc <> 3
		//Carrega o array aRateio com os dados do rateio
		AF011CRateio(aRateio)
	Endif
	
	nOpcA := AF011FRAT(aRateio,1,nOpc)
	
	If nOpcA == 1 //Clicado no Botao Ok
		If len(aRateio) > 0
			If len(aRateio[1,5]) > 0
				Begin Transaction
				If nOpc <> 5
					lMan := AF011Grv(nOpc,aRateio)
				Else
					lMan := AF011DEL(aRateio)
					If lMan
						cRevAtu := AF011GETREV(aRateio[1,1])
						If !empty(cRevAtu)
							Af011AtuStatus(aRateio[1,1],cRevAtu,aRateio[1,3])
						Endif
					Endif
				Endif
				End Transaction
			Endif
		Endif
	Endif
Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011Valid	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que executa as validacoes para as opcoes de aRotina	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011Valid(nOpc)											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc	- Numeric: Nro da opcao de manipulacao do rateio          ³±±
±±³			 ³	1 : Pesquisa	      										  ³±±
±±³			 ³	2 : Visualizacao        		      						  ³±±
±±³			 ³	3 : Inclusao         			              				  ³±±
±±³          ³	4 : Alteracao 		    			              			  ³±±
±±³          ³	5 : Exclusao				              					  ³±±
±±³          ³	6 : Bloqueio/Desbloqueio	 		   				          ³±±
±±³          ³	7 : Gera nova revisao do rateio 		    			      ³±±
±±³			 ³	8 : Amarra um rateio com um SN3       			      		  ³±±
±±³			 ³	9 : Legenda	  		   	  									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: .T. -> Validado, .F. -> Nao Validado 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Programa ATFA011, Localizacao Argentina				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF011Valid(nOpc)

Local cRevAtu	:= ""

Local lRet		:= .t.

cRevAtu := AF011GETREV(SNV->NV_CODRAT)

If nOpc == 4 .or. nOpc == 5
	
	lRet := Af011ExMov(SNV->NV_CODRAT)
	
	If lRet

		If 	SNV->NV_MSBLQL == "1"
			lRet := .f.
			Help(" ",1,"Af011RtBloq",,STR0037,1,0) //"Rateio Bloqueado"
		Endif
		If Alltrim(SNV->NV_REVISAO) <> Alltrim(cRevAtu)
			lRet := .f.
			Help(" ",1,"AF011ValidREV",,STR0013,1,0) //"A revisao deste cadastro de Rateio que deseja-se alterar ou excluir não é a mais atual."
		Endif
		
	Endif
ElseIf  nOpc == 6
	
	If SNV->NV_STATUS <> "5"
		If SNV->NV_MSBLQL == "1"
			
			If Alltrim(SNV->NV_REVISAO) <> Alltrim(cRevAtu)
				lRet := .f.
				Help(" ",1,"AF011Desbloqueio",,STR0014,1,0) //"Este cadastro de Rateio não pode ser desbloqueado, porque ele já possui uma revisão mais atual."
			Endif
		Endif
	Else
		lRet := .f.
		Help(" ",1,"AF011Finalizado",,STR0015,1,0)	 //"Este Rateio não pode ser bloqueado, pois está finalizado."
	Endif
ElseIf nOpc == 7
	If !(SNV->NV_STATUS $ "1|3")
		lRet := .f.
		Help(" ",1,"AF011VLdNEWREV",,STR0016,1,0)  //"Gerar revisão somente para os rateios que estejam disponíveis, vinculados a bens ou bloqueados."
	Endif
ElseIf nOpc == 8
	If SNV->NV_MSBLQL == "1" .Or. SNV->NV_STATUS != '1' 
		lRet := .F.
		Help(" ",1,"AF011ValidVINC",,STR0017,1,0)  //"Somente rateios disponíveis poderão ser vinculados com algum Bem (Ativo)."
	Endif
EndIf


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011BLQ		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloqueia e desbloqueia um rateio.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011BLQ(cAlias,nReg,nOpc)								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc	- Numeric: Nro da opcao de manipulacao do rateio          ³±±
±±³          ³	6 : Bloqueio/Desbloqueio	 		   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil													 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011BLQ(cAlias,nReg,nOpc)

Local lValid	:= .T.

DbSelectArea("SNV")

aAreaSNV := SNV->(GetArea())

If AF011VALID(nOpc)
	//Valida as entidades contábeis do rateio
	If SNV->NV_MSBLQL == "1"
		If !AF011ExisEnt(Nil,SNV->NV_CODRAT,SNV->NV_REVISAO)
			lValid := .F.
		EndIf
	EndIf
	
	If lValid
		Af011AtuStatus(SNV->NV_CODRAT,SNV->NV_REVISAO,SNV->NV_STATUS,.T.)
	EndIf
Endif

RestArea(aAreaSNV)


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011REV		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera uma nova revisao para um rateio.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011REV(cAlias,nReg,nOpc)								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc	- Numeric: Nro da opcao de manipulacao do rateio          ³±±
±±³          ³	7 : Nova Revisao			 		   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil													 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina/Brasil						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011REV(cAlias,nReg,nOpc)

Local aRateio	:= {}
Local lValid 	:= .f.//AF011VALID(nOpc)
Local cRevAnt	:= ""

lValid 	:= AF011VALID(nOpc)

If lValid
	
	AF011CRateio(aRateio)
	cRevAnt			:= aRateio[1,2]
	aRateio[1,2] 	:= AF011GETREV(aRateio[1,1],.t.)
	
	nOpcA := AF011FRAT(aRateio,1,nOpc)
	
	If nOpcA == 1 //Clicado no Botao Ok
		If len(aRateio) > 0
			If len(aRateio[1,5]) > 0
				Begin Transaction
				lMan := AF011NewRev(aRateio[1,1],cRevAnt,aRateio[1,5],aRateio[1,3])
				End Transaction
			Endif
		Endif
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011VIN		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Amarra um rateio com um item da ficha de ativo.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011VIN(cAlias,nReg,nOpc)								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc	- Numeric: Nro da opcao de manipulacao do rateio          ³±±
±±³          ³	7 : Vincular				 		   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil													 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina/Brasil						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011VIN(cAlias,nReg,nOpc)

Local oPanel1
Local oPanel2
Local oBrowN3
Local oDlg
Local oSayBem
Local oGetBem
Local oSayItB
Local oGetItB
Local oBtnFil
Local oBtnOk
Local oBtnCan
Local oArial14

Local cGetBem		:= space(TamSX3("N3_CBASE")[1])
Local cGetItB		:= space(TamSX3("N3_ITEM")[1])

Local nWidth 		:= 0
Local nHeight		:= 0
Local nCoordX		:= 0
Local nCoordY		:= 0
Local nCtrlX		:= 0
Local nCtrlY		:= 0
Local nOpcA			:= 0

Local aSizeAut		:= FWGetDialogSize(oMainWnd)
Local aFields		:= {"N3_CBASE","N3_ITEM","N3_SEQ","N3_TIPO","N3_HISTOR","N3_TPSALDO"}
Local aFieldName	:= AF11RetName(aFields)
Local aFieldSize	:= AF11RetTam(aFields,aFieldName)
Local aFieldData	:= AF11RetData(aFields)

Local aButtons		:= {}
Local aUsButtons	:= {}

Local lValid 		:= AF011VALID(nOpc)

Local bExecute		:= {|| AF11VINCSN3(oBrowN3),oDlg:End()}
Local bExecFil		:= {||	aFieldData := {},;
aFieldData := AF11RetData(aFields,cGetBem,cGetItB),;
oBrowN3:SetArray(aFieldData),;
oBrowN3:bLine := bLine,;
oBrowN3:Refresh()}

Local bCancel		:= {|| oDlg:End()}

Local bLine			:= {|| {	aFieldData[oBrowN3:nAt,01],;
aFieldData[oBrowN3:nAt,02],;
aFieldData[oBrowN3:nAt,03],;
aFieldData[oBrowN3:nAt,04],;
aFieldData[oBrowN3:nAt,05],;
aFieldData[oBrowN3:nAt,06]}}

If !lValid
	Return()
Endif

nCoordY	:= aSizeAut[1]
nCoordX	:= aSizeAut[2]
nWidth 	:= aSizeAut[4]/1.75
nHeight := aSizeAut[3]/1.75

DEFINE MSDIALOG oDlg TITLE STR0018 FROM nCoordX,nCoordY TO nCoordX+nHeight,nCoordY+nWidth PIXEL OF oMainWnd  //"Vincular Rateio com Bem"

oArial14		:= tFont():New("Arial",,-14,,.t.)
oPanel1			:= tPanel():New(0,0,,oDlg)
oPanel1:Align 	:= CONTROL_ALIGN_TOP
oPanel1:nLeft	:= 0
oPanel1:nHeight := nHeight/4

nCtrlY	:= 15

oSayBem			:= tSay():New(nCtrlY,003,{|| Af11FldName("N3_CBASE") },oPanel1,,oArial14,,,,.T.)
oGetBem			:= tGet():New(nCtrlY+10,003,{|u| Iif( PCount() > 0, cGetBem := u, cGetBem)},oPanel1,60,,"@!",,,,,,,.T.,,,,,,,,,"SN1","cGetBem")
oSayItB			:= tSay():New(nCtrlY,095,{|| Af11FldName("N3_ITEM") },oPanel1,,oArial14,,,,.T.)
oGetItB			:= tGet():New(nCtrlY+10,095,{|u| Iif( PCount() > 0, cGetItB := u, cGetItB)},oPanel1,50,,"@!",,,,,,,.T.,,,,,,,,,,"cGetItB")

oBtnFil			:= tButton():New(nCtrlY+10,160,STR0019,oPanel1,bExecFil,35,12,,,,.T.)	//"&Filtro"
oBtnOk			:= tButton():New(nCtrlY+10,250,STR0020,oPanel1,bExecute,35,12,,,,.T.)//"&Ok"
oBtnCan			:= tButton():New(nCtrlY+10,300,STR0021,oPanel1,bCancel,35,12,,,,.T.)	//"&Cancelar"

oPanel2			:= tPanel():New(nCoordY+oPanel1:nHeight,nCoordX,,oDlg)
oPanel2:Align	:= CONTROL_ALIGN_ALLCLIENT

oBrowN3			:= TWBrowse():New( nCoordY,nCoordX,nWidth,nHeight,,aFieldName,aFieldSize,oPanel2,,,,,bExecute,,,,,,,.F.,,.T.,,.F.)
oBrown3:Align	:= CONTROL_ALIGN_ALLCLIENT
oBrowN3:SetArray(aFieldData)
oBrowN3:bLine 	:= bLine

ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF11VINCSN3	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera as tabelas SN3, com o codigo do rateio e SNV, com status ³±±
±±³          ³igual a "3" (Ativo)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF11VINCSN3(oBrowseN3)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oBrowseN3	- Object: Objeto da Classe TWBrowse com os itens da   ³±±
±±³          ³ficha de ativo (SN3)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil													 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina/Brasil				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF11VINCSN3(oBrowseN3)

Local aAreaSN3	:= SN3->(GetArea())
Local aAreaSNV	:= SNV->(GetArea())

Local nAt		:= oBrowseN3:nAt

Local cBusca	:= ""

cBusca := 	xFilial("SN3") +;
PadR(oBrowseN3:aArray[nAt,1],TamSx3("N3_CBASE")[1])+;
PadR(oBrowseN3:aArray[nAt,2],TamSx3("N3_ITEM")[1])+;
PadR(oBrowseN3:aArray[nAt,4],TamSx3("N3_TIPO")[1])+;
PadR("0",TamSx3("N3_BAIXA")[1])+;
PadR(oBrowseN3:aArray[nAt,3],TamSx3("N3_SEQ")[1])

SN3->(DbSetOrder(1))
SNV->(DbSetOrder(1))

If SN3->(DbSeek(cBusca))
	Begin Transaction
	RecLock("SN3",.F.)
	SN3->N3_RATEIO := "1"
	SN3->N3_CODRAT := SNV->NV_CODRAT
	SN3->(MSUnlock())
	
	Af011AtuStatus(SNV->NV_CODRAT,SNV->NV_REVISAO,"3")
	
	End Transaction
Endif

RestArea(aAreaSN3)
RestArea(aAreaSNV)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011FRAT		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria a Janela MsDialog para o usuario efetuar a distribuicao do ³±±
±±³          ³rateio.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011FRAT(aRateio,nLin,nOpc,bFunc)						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRateio	- Array: dados do rateio. 							  ³±±
±±³          ³	aRateio[i,1] - Char: Codigo do Rateio						  ³±±
±±³          ³	aRateio[i,2] - Char: Revisao do Rateio						  ³±±
±±³          ³	aRateio[i,3] - Char: Status do Rateio						  ³±±
±±³          ³		"1"	- Disponivel										  ³±±
±±³          ³		"2"	- Pendente de classificacao							  ³±±
±±³          ³		"3"	- Ativo												  ³±±
±±³          ³		"4"	- Ativo Baixado										  ³±±
±±³          ³		"5"	- Finalizado										  ³±±
±±³          ³	aRateio[i,4] - Numeric: Nro da Linha do Grid do Item da		  ³±±
±±³          ³	do Ativo (nAt da GetDados do SN3)							  ³±±
±±³          ³	aRateio[i,5] - Array: Similar ao aCols, com o Rateio		  ³±±
±±³          ³		aRateio[i,5,j] - Array: Linhas do aCols	  				  ³±±
±±³          ³			aRateio[i,5,j,k] - Any: Colunas do aCols			  ³±±
±±³          ³	aRateio[i,6] - Boolean: Demonstra se o item da ficha do Ativo ³±±
±±³          ³foi apagado na GetDados do SN3. Se .T. - item apagado 		  ³±±
±±³          ³nLin		- Numeric: Linha (nAt) da GetDados do SN3	 		  ³±±
±±³          ³nOpc		- Numeric: Nro da opcao de manipulacao do rateio      ³±±
±±³			 ³		2 : Visualizacao        		      					  ³±±
±±³			 ³		3 : Inclusao         			              			  ³±±
±±³          ³		4 : Alteracao 		    			              		  ³±±
±±³          ³		5 : Exclusao				              				  ³±±
±±³          ³		7 : Gera nova revisao do rateio 		    			  ³±±
±±³          ³bFunc		- Code Block: Funcao que retorna um objeto da classe  ³±±
±±³          ³tPanel que sera apresentado no topo da janela.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nOpcA	- Numeric: Retorna se foi dado OK na tela ou nao 	      ³±±
±±³          ³	0: Tela Cancelada									 	      ³±±
±±³          ³	1: Tela Confirmada									 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina/Brasil						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF011FRAT(aRateio,nLin,nOpc,bFunc,oDlg,lGetGD)

Local oPanelAll
Local oSize
Local oPanelCab
Local oPanelGrid
Local oPanelRdp
Local oSayRateio
Local oSayRatear
Local oEnch
Local oMsNewGD
Local oSayPercRt
Local oSayPercAR
Local oArial14		:= tFont():New("Arial",,-14,,.t.)
Local oArial14It	:= tFont():New("Arial",,-14,,.f.,,,,.t.)

Local nWidth 	:= 0
Local nHeight	:= 0
Local nCoordX	:= 0
Local nCoordY	:= 0
Local nPercRat	:= 0
Local nPercARat	:= 0
Local nX 		:= 0
Local nOpcA		:= 0
Local nPosnAt	:= 0
Local nOpcAnt	:= nOpc

Local aDados		:= aClone(aRateio)
Local aFldEnch		:= {}//{"NV_CODRAT","NV_REVISAO","NV_STATUS"}
Local aPosEnch		:= {}
Local aObjects		:= {}
Local aPosObj		:= {}
Local aInfo			:= {}
Local aSizeAut		:= MsAdvSize()
Local aHeader		:= {}
Local aCols			:= {}
Local aAlter		:= {}
Local aButtons		:= {}
Local aUsButtons	:= {}
Local aCodeRateio	:= {}

Local lInsert			:= (nOpc == 3 .or. nOpc == 4 .or. nOpc == 7)
Local lUpdate			:= lInsert
Local lDelete			:= lInsert
Local lMsDialogObject	:= .f.
Local lATFA011			:= IsInCallStack("ATFA011")
Local lDif				:= .f.

Local cStatus	:= ""

Local bAtuPerc	:= {|x,z|	z := AF011AtuPercs(oMsNewGD,x),;
nPercRat 	:= z[1],;
nPercARat	:= z[2],;
oSayPercRt:Refresh(),;
oSayPercAR:Refresh() }

Local bLinhaOk	:= {|| FA011LinOk(oMsNewGD)}

Local bTudoOk	:= {|lRet|	lRet := Iif(oEnch <> Nil,Obrigatorio(oEnch:aGets,oEnch:aTela),.t.) ,;
Iif(lRet,lRet := AF011AllOk(oMsNewGD,nOpc),lRet),;
Iif(lRet,lRet := AF011VPerc(nPercRat,nPercARat),lRet),;
Iif(lRet,lRet := AF011FullPerc(nPercRat,nPercARat),lRet) }

Local bDelOk	:= {||	Eval(bAtuPerc,.t.),;
AF011VPerc(nPercRat,nPercARat)}

Local bCancel	:= {||	ROLLBACKSX8(),;
oDlg:End()}

Local bUpdate	:= {||	Iif( Eval(bTudoOk),nOpcA := 1, nOpcA := 0 ),;
Iif( nOpcA == 1, oDlg:End(), nil) }

Local bLoadSNV	:= {|x,y,z,w| AF011LoadSNV(x,y,@z,w)}

Local bBtnAct1	:= {|| AdmRatExt(oMsNewGD:aHeader,oMsNewGD:aCols,bLoadSNV), Eval(bAtuPerc) }

Local bFieldOK	:= {||	Eval(bAtuPerc),;
Iif(Alltrim(ReadVar()) $ "M->NV_PERCEN",AF011VPerc(nPercRat,nPercARat),.T.) } 
Local cRotina := ""
Local nLinIni := 0
Local nColIni := 0

Default nLin	:= 0
Default bFunc	:= ""
Default	oDlg	:= nil
Default lGetGD	:= .f.


If nLin == 0
	Return()
Endif

RegToMemory("SNV",(nOpc == 3),.T.,.T.)

AAdd( aObjects, { 000, 025, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo  		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj		:= MsObjSize( aInfo, aObjects )


If nOpc <> 2 .and. nOpc <> 5
	aadd(aButtons,{ 'AUTOM',;
	bBtnAct1,;
	STR0022,;
	STR0022} ) //'Escolha de Rateio Pre-Configurado'
Endif

Do 	Case
  	Case nOpc = 2 
   		cRotina:= STR0005  //'Visualizar'
   	Case nOpc = 3
		cRotina:= STR0006  //'Incluir'
	Case nOpc = 4 
		cRotina:= STR0007  //'Alterar'
	Case nOpc = 5 
		cRotina:= STR0008  //'Excluir'
	Case nOpc = 7 
		cRotina:= STR0010  //'Gerar rev'
EndCase

If oDlg == nil
	lMsDialogObject := .t.
	DEFINE MSDIALOG oDlg TITLE STR0023+"-"+cRotina FROM aSizeAut[7],0 TO 400,800 PIXEL OF oMainWnd //"Rateio de Despesas de Depreciacao"
Endif

oPanelAll 			:= tPanel():New(0,0 ,,oDlg,,,,,,400,800)
oPanelAll:Align 	:=  CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New(.T.,,,oPanelAll)
oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 60, .T., .T. ) // Totalmente dimensionavel 
oSize:AddObject( "RODAPE"   ,  100, 20, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() 	   // Dispara os calculos   

nLinIni:= oSize:GetDimension("CABECALHO","LININI")
nColIni:= oSize:GetDimension("CABECALHO","COLINI")

nWidth 	:= aPosObj[2,4]		//0
nHeight	:= aPosObj[2,3]/4	//+25
nCoordX	:= nLinIni
nCoordY	:= 0


If !lGetGD
	
	If ValType(bFunc) == "C"
		oPanelCab 			:= tPanel():New(nLinIni,nColIni,,oPanelAll,,,,,,030,030)
		oPanelCab:Align 	:= CONTROL_ALIGN_TOP
		oPanelCab:nHeight 	:= nHeight
		oPanelCab:nWidth	:= nWidth
		
		aFldEnch := {"NV_CODRAT","NV_REVISAO","NV_STATUS"}
		
		If nOpc == 7
			nOpc := 3
		Endif
		
		oEnch 				:= MsMGet():New("SNV",SNV->(RECNO()),nOpc,,,STR0023+"-"+cRotina,aFldEnch,/*aPosEnch*/{0,0,0,0},{},,,,,oPanelCab,,,.F.) //"Rateio de Despesas de Depreciacao"
		oEnch:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT
	Else
		//bFunc	:= {|x| MountPanel(x)}
		oPanelCab 	:= Eval(bFunc,oPanelAll)//,nCoordX,nCoordY,nWidth,nHeight)
	Endif
	
	If oPanelCab:Align <> CONTROL_ALIGN_TOP
		oPanelCab:Align := CONTROL_ALIGN_TOP
		oPanelCab:nHeight := nHeight
	Endif
Endif

nLinIni:= oSize:GetDimension("GETDADOS","LININI")
nColIni:= oSize:GetDimension("GETDADOS","COLINI")

oPanelGrid			:= tPanel():New(nLinIni,nColIni,,oPanelAll,,,,,,nWidth,nHeight*3)
oPanelGrid:Align	:= CONTROL_ALIGN_ALLCLIENT

aHeader := AF011HeadSNV()

nPosnAt := aScan(aDados,{|x| x[4] == nLin })

//Se aDados foi passado vazio, entao, sera preenchido com a revisao
If Empty(aDados) .OR. nPosnAt == 0
	If !lAtfA011
		aAdd(aDados,{"","","3",nLin,{},.F.})
	Else
		aCodeRateio := AF011COD(M->NV_CODRAT,nOpcAnt == 7)
		M->NV_CODRAT 	:= aCodeRateio[1]
		M->NV_REVISAO	:= aCodeRateio[2]
		
		If nOpcAnt == 7
			M->NV_STATUS := "1"
		Endif
		
		aAdd(aDados,{M->NV_CODRAT,M->NV_REVISAO,M->NV_STATUS,nLin,{},.F.})
	Endif
Else
	//Acrescentado por Fernando Radu Muscalu em 29/10/11
	//Verificar se houve alteracao no rateio, efetivamente.
	
	If nPosnAt > 0
		M->NV_CODRAT 	:= aDados[nPosnAt,1]
		M->NV_REVISAO 	:= aDados[nPosnAt,2]
		M->NV_STATUS	:= aDados[nPosnAt,3]
	Endif
Endif

aCols	:= AF011CargaGD(aHeader,nOpc,aDados,nLin)

If lInsert .or. lUpdate
	aEval( aHeader, {|x| Iif(ALLTRIM(x[2]) <> "NV_SEQUEN",aAdd(aAlter,x[2]),nil) } )
Endif

oMsNewGD 	:= MsNewGetDados():New(0,0,0,0,GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","+NV_SEQUEN",aAlter,,999,/*fieldok*/,/*superdel*/,/*delok*/,oPanelGrid,aHeader,aCols)
oMsNewGD:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT

oMsNewGD:bFieldOk	:= bFieldOK
oMsNewGD:bChange	:= bFieldOK
oMsNewGD:bLinhaOk	:= bLinhaOk
oMsNewGD:bDelOk		:= bDelOk

oMsNewGD:lInsert 	:= lInsert
oMsNewGD:lUpdate 	:= lUpdate
oMsNewGD:lDelete 	:= lDelete

oPanelRdp			:= tPanel():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI"),,oPanelAll,,,,,,030,030)
oPanelRdp:Align		:= CONTROL_ALIGN_BOTTOM

oSayRateio			:= tSay():New(01,01,{|| STR0024 },oPanelRdp,,oArial14)//,,,,,,,30,10)	//"% Rateado:"
oSayRatear			:= tSay():New(01,25,{|| STR0025 },oPanelRdp,,oArial14)//,,,,,,,30,10)	//"% A ratear:"
oSayPercRt			:= tSay():New(01,08,{|| nPercRat },oPanelRdp,PesqPict("SNV","NV_PERCEN"),oArial14It)//,,,,,,,,,30,10)
oSayPercAR			:= tSay():New(01,32,{|| nPercARat},oPanelRdp,PesqPict("SNV","NV_PERCEN"),oArial14It)//,,,,,,,,,30,10)

Eval(bAtuPerc)

If lMsDialogObject
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,aButtons) CENTERED
Else
	nOpcA := 1
Endif

If nOpcA == 1
	If ( nPosnAt := Iif(!Empty(aDados),aScan(aDados,{|x| x[4] == nLin}),0) ) > 0
		
		//Acrescentado por Fernando Radu Muscalu em 29/10/11
		//Verificar se houve alteracao no rateio, efetivamente para nao gerar nenhuma revisao.
		lDif := AdmDiffArray(aDados[nPosnAt,5],oMSNewGD:aCols)
		
		If lDif
			
			If !lATFA011 .and. nOpc == 4
				//Alterado por Fernando Radu Muscalu em 02/11/10
				//Se o codigo de rateio esta em branco, significa que e um novo rateio,
				//mesmo sendo uma alteracao na ficha de ativo. Provavelmente foi inserifo um novo item
				If Empty(aDados[nPosnAt,1])
					aDados[nPosnAt,3] 	:= "3"
				Else
					aDados[nPosnAt,3] 	:= "5"
				Endif
			Endif
			
			aDados[nPosnAt,5]	:= {}
			aDados[nPosnAt,5]	:= aClone(oMSNewGD:aCols)
			
			aRateio 			:= aClone(aDados)
		Endif
	Endif
Endif

Return(nOpcA)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011HeadSNV	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem do cabecalho da Getdados do arquivo SNV 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011HeadSNV()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRetHead	- Array: Retorna array aHeader da MsNewGetdados com os³±±
±±³          ³campos da tabela SNV, somente os usados e que nao estejam na    ³±±
±±³          ³enchoice da tela 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina						  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011HeadSNV()

Local aRetHead	:= {}
Local aAreaSX3	:= SX3->(GetArea())

Local cNoFields	:= "NV_FILIAL|NV_CODRAT|NV_REVISAO|NV_STATUS|NV_MSBLQL"

SX3->(dbSetOrder(1))

SX3->(DBSeek("SNV"))

While SX3->(!EOF()) .And. (SX3->X3_ARQUIVO == "SNV")
	
	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !(alltrim(SX3->X3_CAMPO) $ cNoFields)
		AADD(aRetHead,{ TRIM(x3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_F3,;
		SX3->X3_CONTEXT } )
	EndIf
	
	SX3->(dbSkip())
EndDo

RestArea(aAreaSX3)

Return(aRetHead)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011CargaGD	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria a Janela MsDialog para o usuario efetuar a distribuicao do ³±±
±±³          ³rateio.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011CargaGD(aHeadGD,nOpc,aDados,nP)						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aHeadGD	- Array: aHeader do objeto MSNewGetDados. 			  ³±±
±±³          ³nOpc		- Numeric: Nro da opcao de manipulacao do rateio      ³±±
±±³			 ³		2 : Visualizacao        		      					  ³±±
±±³			 ³		3 : Inclusao         			              			  ³±±
±±³          ³		4 : Alteracao 		    			              		  ³±±
±±³          ³		5 : Exclusao				              				  ³±±
±±³          ³		7 : Gera nova revisao do rateio 		    			  ³±±
±±³          ³aDados	- Array: dados do rateio. 							  ³±±
±±³          ³	aDados[i,1] - Char: Codigo do Rateio						  ³±±
±±³          ³	aDados[i,2] - Char: Revisao do Rateio						  ³±±
±±³          ³	aDados[i,3] - Char: Status do Rateio						  ³±±
±±³          ³		"1"	- Disponivel										  ³±±
±±³          ³		"2"	- Pendente de classificacao							  ³±±
±±³          ³		"3"	- Ativo												  ³±±
±±³          ³		"4"	- Ativo Baixado										  ³±±
±±³          ³		"5"	- Finalizado										  ³±±
±±³          ³	aDados[i,4] - Numeric: Nro da Linha do Grid do Item da		  ³±±
±±³          ³	do Ativo (nAt da GetDados do SN3)							  ³±±
±±³          ³	aDados[i,5] - Array: Similar ao aCols, com o Rateio		      ³±±
±±³          ³		aDados[i,5,j] - Array: Linhas do aCols	  				  ³±±
±±³          ³			aDados[i,5,j,k] - Any: Colunas do aCols			  	  ³±±
±±³          ³	aDados[i,6] - Boolean: Demonstra se o item da ficha do Ativo  ³±±
±±³          ³foi apagado na GetDados do SN3. Se .T. - item apagado 		  ³±±
±±³          ³nP		- Numeric:  Linha (nAt) da GetDados do SN3	 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRetCols	- Array: Retorna o aCols do objeto MSNewGetDados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011CargaGD(aHeadGD,nOpc,aDados,nP)

Local nI		:= 0
Local nX		:= 0
Local nPosnAt 	:= Iif(!Empty(aDados),aScan(aDados,{|x| x[4] == nP}),0)
Local aRetCols	:= {}
Local aAux		:= {}

If len(aDados[nPosnAt,5]) == 0
	aAdd( aRetCols, array( len(aHeadGD) + 1 ) )
	
	For nI  := 1 to len(aHeadGD)
		If Alltrim(aHeadGD[nI,2]) == "NV_SEQUEN"
			aRetCols[len(aRetCols),nI] := strzero(1,TAMSX3("NV_SEQUEN")[1])
		Else
			aRetCols[len(aRetCols),nI] := CriaVar(aHeadGD[nI,2])
		Endif
	Next nI
	
	aRetCols[len(aRetCols),len(aHeadGD) + 1] := .f.
Else
	For nX := 1 to len(aDados[nPosnAt,5])
		
		For nI := 1 to len(aDados[nPosnAt,5,nX])
			aAdd(aAux,aDados[nPosnAt,5,nX,nI])
		Next nI
		
		aAdd(aRetCols,aAux)
		
		aAux := {}
	Next nX
Endif

Return(aRetCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011GETREV	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de captacao de Revisao do Rateio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011GETREV(cCodRat,lNew)			 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodRat	- Char: codigo do rateio.				 			  ³±±
±±³          ³lNew		- Boolean: Para definir que Revisao sera retornada	  ³±±
±±³          ³			.T. - A proxima revisao livre						  ³±±
±±³          ³			.F. - A ultima revisao      						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRev	- Char: Revisao referente ao codigo parametrizado	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011GETREV(cCodRat,lNew)

Local cRev		:= ""
Local cQry		:= ""

Local aAreaSNV  := {}

Default lNew	:= .f.

aAreaSNV  := SNV->(GetArea())
SNV->(dbSetOrder(1))

If SNV->(DbSeek(xFilial("SNV") + padr(cCodRat,TamSX3("NV_CODRAT")[1])))
	
	#IFNDEF TOP
		While SNV->(!Eof()) .AND. Alltrim(cCodRat) == Alltrim(SNV->NV_CODRAT)
			cRev := SNV->NV_REVISAO
			SNV->(dbSkip())
		EndDo
	#ELSE
		
		cQry := "SELECT " + chr(13) + chr(10)
		cQry += "	MAX(NV_REVISAO) MAX_REV " + chr(13) + chr(10)
		cQry += "FROM " + chr(13) + chr(10)
		cQry += "	"+ RetSQlName("SNV") + " SNV " + chr(13) + chr(10)
		cQry += "WHERE " + chr(13) + chr(10)
		cQry += "	NV_FILIAL = '" + XFILIAL("SNV") + "' " + chr(13) + chr(10)
		cQry += "	AND " + chr(13) + chr(10)
		cQry += "	NV_CODRAT = '" + cCodRat + "' " + chr(13) + chr(10)
		cQry += "	AND " + chr(13) + chr(10)
		cQry += "	SNV.D_E_L_E_T_ = ' ' "
		
		cQry := ChangeQuery(cQry)
		
		If select("MAXREV") > 0
			MAXREV->(DbCloseArea())
		Endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "MAXREV", .T., .F.)
		
		MAXREV->(dbGotop())
		
		If !MAXREV->(Eof())
			cRev := MAXREV->MAX_REV
		Endif
		
		MAXREV->(DbCloseArea())
	#ENDIF
	
Endif

RestArea(aAreaSNV)

If lNew
	cRev := Strzero(Val(cRev)+1,TamSx3("NV_REVISAO")[1])
Endif

Return(cRev)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011LoadSNV	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de captacao dos dados de rateio externo (tabela CTJ)	  ³±±
±±³          ³responsavel por alimentar o aCols do objeto MSNewGetdados da	  ³±±
±±³          ³tela rateio que atualizara o arquivo de SNV (rateio de despesas ³±±
±±³          ³da ficha de ativo. 											  ³±±
±±³          ³Sobre a particularidade desta funcao, leia o item USO, abaixo.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011LoadSNV(aCols, aHeader, cItem, lPrimeiro)			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCols		- Array: aCols da Getdados de rateio da ficha (SNV).  ³±±
±±³          ³aHeader	- Array: aHeader da Getdados com os campos de SNV	  ³±±
±±³          ³cItem		- Char: Item ou sequencia do rateio da ficha		  ³±±
±±³          ³lPrimeiro - Boolean: Para controle interno da Funcao chamadora. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especial da Funcao AdmRatExt(...) que monta a tela de rateio	  ³±±
±±³          ³externo (CTJ) do modulo de Contabilidade Gerencial. Atraves de  ³±±
±±³          ³uma iteracao do arquivo CTJ, a funcao	AF011LoadSNV(...) passada ³±±
±±³          ³dentro de um Bloco de Codigo ( {||} ) e executada a cada volta  ³±±
±±³          ³do laco desta iteracao. Desta forma e possivel alimentar o aCols³±±
±±³          ³que o bloco recebe com os dados de CTJ.						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF011LoadSNV(aCols, aHeader, cItem, lPrimeiro)

Local nPosPerc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_PERCEN" } )
Local nPosSeq		:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_SEQUEN" } )
Local nPosCC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_CC"} )
Local nPosConta		:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_CONTA"} )
Local nPosItemCta	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_ITEMCTA"} )
Local nPosCLVL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "NV_CLVL"} )

Local aEntidades	:= {}
Local nEnt			:= 0
Local nDeb			:= 0

Local nHeader		:= 0

If lPrimeiro
	//-- Se ja foi informado algum rateio, limpar o aCols
	If aCols[Len(aCols)][nPosPerc] <> 0
		
		aCols := {}
		Aadd(aCols, Array(Len(aHeader) + 1))
		
		For nHeader := 1 To Len(aHeader)
			aCols[Len(aCols)][nHeader] := CriaVar(aHeader[nHeader][2])
		Next nHeader
		
	EndIf
	
	cItem := Strzero(Val(cItem)+1,TamSx3("NV_SEQUEN")[1])
	
	aCols[Len(aCols)][nPosSeq]  		:= cItem
	aCols[Len(aCols)][Len(aHeader)+1] 	:= .F.
Else
	
	If aCols[Len(aCols)][nPosPerc] = 0
		cItem := aCols[Len(aCols)][nPosSeq]
	Else
		If Len(aCols) > 0
			cItem := aCols[Len(aCols)][nPosSeq]
		Endif
		
		Aadd(aCols, Array(Len(aHeader) + 1))
		cItem := Strzero(Val(cItem)+1,TamSx3("NV_SEQUEN")[1])
	EndIf
	
	For nHeader := 1 To Len(aHeader)
		aCols[Len(aCols)][nHeader] := CriaVar(aHeader[nHeader][2])
	Next nHeader
	
	aCols[Len(aCols)][nPosSeq] := cItem
	
	// Interpreto os campos incluida possibilidade de variaveis de memoria
	If !Empty(CTJ->CTJ_DEBITO)
		aCols[Len(aCols)][nPosConta]	:= CTJ->CTJ_DEBITO
	Else
		aCols[Len(aCols)][nPosConta]	:= CTJ->CTJ_CREDIT
	Endif
	
	If ! Empty(CTJ->CTJ_CCD)
		aCols[Len(aCols)][nPosCc]	:= CTJ->CTJ_CCD
	Else
		aCols[Len(aCols)][nPosCc]	:= CTJ->CTJ_CCC
	Endif
	
	If ! Empty(CTJ->CTJ_ITEMD)
		aCols[Len(aCols)][nPosItemCta]	:= CTJ->CTJ_ITEMD
	Else
		aCols[Len(aCols)][nPosItemCta]	:= CTJ->CTJ_ITEMC
	Endif
	
	If ! Empty(CTJ->CTJ_CLVLDB)
		aCols[Len(aCols)][nPosClVl]	:= CTJ->CTJ_CLVLDB
	Else
		aCols[Len(aCols)][nPosClVl]	:= CTJ->CTJ_CLVLCR
	Endif
	
	aCols[Len(aCols)][nPosPerc]	:= CTJ->CTJ_PERCEN
	
	aCols[Len(aCols)][Len(aHeader) + 1] := .F.

	aEntidades := CtbEntArr()
	For nEnt := 1 to Len(aEntidades)
		For nDeb := 1 to 2
			cCpo := "NV_EC"+aEntidades[nEnt]
			cCTJ := "CTJ_EC"+aEntidades[nEnt]
			
			If nDeb == 1
				cCpo += "DB"
				cCTJ += "DB"
			Else
				cCpo += "CR"
				cCTJ += "CR"
			EndIf
			
			nPosHead := aScan(aHeader,{|x| AllTrim(x[2]) == Alltrim(cCpo) } )
			
			If nPosHead > 0 .And. CTJ->(FieldPos(cCTJ)) > 0
				aCols[Len(aCols)][nPosHead] := CTJ->(&(cCTJ))
			EndIf
			
		Next nDeb
	Next nEnt

	
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af011AtuPercs	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualizacao dos valores dos percentuais do rodape da tela de	  ³±±
±±³          ³rateio das despesas da ficha de ativo.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Af011AtuPercs(oGetDados,lDelAction) 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetDados	- object: Instancia da classe MSNewGetDados.		  ³±±
±±³          ³lDelAction- Boolean: chamada pelo bloco de acao de Exclusao da  ³±±
±±³          ³linha da GetDados?											  ³±±
±±³          ³			.T. - Sim 											  ³±±
±±³          ³			.F. - Nao      						  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aPercs	- Array: Percentuais do Rodape da tela de rateio      ³±±
±±³          ³	aPercs[1]- Numeric: Valor rateado						      ³±±
±±³          ³	aPercs[2]- Numeric: Valor a ratear						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af011AtuPercs(oGetDados,lDelAction)

Local nPosPerc	:= aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == "NV_PERCEN"})
Local nI		:= 0
Local nAt		:= oGetDados:nAT

Local aPercs	:= array(2)

Default lDelAction 	:= .f.


If Alltrim(Readvar()) == "M->NV_PERCEN"
	If M->NV_PERCEN > 100
		M->NV_PERCEN := 100
	ElseIf 	M->NV_PERCEN < 0
		M->NV_PERCEN := 0
	Endif
Endif

aPercs[1] := 0

For nI := 1 to len(oGetDados:aCols)
	If !oGetDados:aCols[nI,len(oGetDados:aHeader)+1]
		If lDelAction .and. nI == nAt
			aPercs[1] += 0
		Else
			If Alltrim(Readvar()) <> "M->NV_PERCEN" .or. nI <> nAt
				aPercs[1] += oGetDados:aCols[nI,nPosPerc]
			Else
				aPercs[1] += M->NV_PERCEN
			Endif
		Endif
	Else
		If lDelAction .and. nI == nAt
			If Alltrim(Readvar()) <> "M->NV_PERCEN" .or. nI <> nAt
				aPercs[1] += oGetDados:aCols[nI,nPosPerc]
			Else
				aPercs[1] += M->NV_PERCEN
			Endif
		Endif
	Endif
Next nI

aPercs[2] := 100 - aPercs[1]

Return(aPercs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011VPerc	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do percentual rateado								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011VPerc(nPercRat,nPercARat)	 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPercRat	- Numeric: Valor rateado		  					  ³±±
±±³          ³nPercARat	- Numeric: Valor a ratear							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se o percentual e valido ou nao.	      ³±±
±±³			 ³					.t. - percentual valido					      ³±±
±±³			 ³					.f. - percentual nao valida				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF011VPerc(nPercRat,nPercARat)

Local lRet	:= .t.

If nPercRat > 100
	lRet := .f.
	Help(" ",1,"AF011VPerc",,STR0026,1,0) //"Percentual Rateado não pode assumir valor acima de 100."
Endif

If lRet
	If nPercARat < 0
		lRet := .f.
		Help(" ",1,"AF011VPerc",,STR0027,1,0)	//"Percentual A Ratear não pode assumir valor Abaixo de 0."
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA011LinOk  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da linha do objeto MsNewGetDados.				   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA011LinOk(oGetRateio,nLin)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetRateio	- objeto: instancia de MsNewGetDados            ³±±
±±³          ³nLin			- Numeric: Nro da Linha do array aCols do objeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³lRet	- Boolean: Se a linha foi validada			         	³±±
±±³       	 ³		.t. - linha validada									³±±
±±³       	 ³		.f. - linha invalidada									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA011LinOk(oGetRateio,nLin)

Local lEnt05		:= SNV->(ColumnPos("NV_EC05DB")) > 0
Local lEnt06		:= SNV->(ColumnPos("NV_EC06DB")) > 0
Local lEnt07		:= SNV->(ColumnPos("NV_EC07DB")) > 0
Local lEnt08		:= SNV->(ColumnPos("NV_EC08DB")) > 0
Local lEnt09		:= SNV->(ColumnPos("NV_EC09DB")) > 0

Local lRet			:= .t.
Local lRetEntP		:= .t.
Local lRetEntA		:= .F.

Local aEmptys		:= {}
 
Local nI			:= 0

Local nPSeq			:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_SEQUEN"})
Local nPPer			:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_PERCEN"})
Local nPCC			:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CC"})
Local nPConta   	:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CONTA"})
Local nPItCon   	:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_ITEMCTA"})
Local nPClvl   		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CLVL"})
Local nEntD05 		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC05DB"})
Local nEntC05		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC05CR"})
Local nEntD06 		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC06DB"})
Local nEntC06		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC06CR"})
Local nEntD07 		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC07DB"})
Local nEntC07		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC07CR"})
Local nEntD08 		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC08DB"})
Local nEntC08		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC08CR"})
Local nEntD09 		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC09DB"})
Local nEntC09		:= aScan(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_EC09CR"})


Default nLin 		:= oGetRateio:nAt

If !oGetRateio:aCols[nLin,len(oGetRateio:aHeader)+1]
	If oGetRateio:aCols[nLin,nPPer] == 0
		lRet := .f.
		Help(" ",1,"FA011LinOkA",, STR0028 + Alltrim(oGetRateio:aCols[nLin,nPSeq]),1,0) //"Percentual Zerado. Defina um valor maior que zero. Erro ocorrido na Sequencia "
	EndIf
Endif

If Empty(oGetRateio:aCols[nLin,nPCC])
	aAdd(aEmptys,"CC")
Endif

If Empty(oGetRateio:aCols[nLin,nPConta])
	aAdd(aEmptys,"CONTA")
Endif

If Empty(oGetRateio:aCols[nLin,nPItCon])
	aAdd(aEmptys,"ITCONTA")
Endif

If Empty(oGetRateio:aCols[nLin,nPClvl])
	aAdd(aEmptys,"CLVL")
Endif

If len(aEmptys) >= 4
	lRet := .f.
	Help(" ",1,"Sem Entidade Contábil",, STR0029 + Alltrim(oGetRateio:aCols[nLin,nPSeq]),1,0)	//"Nenhuma das entidades contábeis foram preenchidas. Preencha ao menos uma delas. [Centro de Custo, Conta Contábil, Item da conta ou classe de valor]. Erro na sequência "
Endif

If lRet
	For nI := 1 to len(oGetRateio:aCols)
		
		If lRet
			
			If nI <> nLin .and. !oGetRateio:aCols[nI,len(oGetRateio:aHeader)+1]
				If	( Alltrim(oGetRateio:aCols[nI,nPCC]) == Alltrim(oGetRateio:aCols[nLin,nPCC]) );
					.and.;
					( Alltrim(oGetRateio:aCols[nI,nPConta]) == Alltrim(oGetRateio:aCols[nLin,nPConta]) );
					.and.;
					( Alltrim(oGetRateio:aCols[nI,nPItCon]) == Alltrim(oGetRateio:aCols[nLin,nPItCon]) );
					.and.;
					( Alltrim(oGetRateio:aCols[nI,nPClvl]) == Alltrim(oGetRateio:aCols[nLin,nPClvl]) )
						lRetEntP := .F.
						If lEnt05
							If (lEnt05 .and. ( Alltrim(oGetRateio:aCols[nI,nEntD05]) == Alltrim(oGetRateio:aCols[nLin,nEntD05]) );
							.and.;
							( Alltrim(oGetRateio:aCols[nI,nEntC05]) == Alltrim(oGetRateio:aCols[nLin,nEntC05]) ) )
								lRetEntA := .F.

								If (lEnt06 .and. ( Alltrim(oGetRateio:aCols[nI,nEntD06]) == Alltrim(oGetRateio:aCols[nLin,nEntD06]) );
								.and.;
								( Alltrim(oGetRateio:aCols[nI,nEntC06]) == Alltrim(oGetRateio:aCols[nLin,nEntC06]) ) )
									lRetEntA := .F.

									If (lEnt07 .and. ( Alltrim(oGetRateio:aCols[nI,nEntD07]) == Alltrim(oGetRateio:aCols[nLin,nEntD07]) );
									.and.;
									( Alltrim(oGetRateio:aCols[nI,nEntC07]) == Alltrim(oGetRateio:aCols[nLin,nEntC07]) ) )
										lRetEntA := .F.

										If ( lEnt08 .and. ( Alltrim(oGetRateio:aCols[nI,nEntD08]) == Alltrim(oGetRateio:aCols[nLin,nEntD08]) );
										.and.;
										( Alltrim(oGetRateio:aCols[nI,nEntC08]) == Alltrim(oGetRateio:aCols[nLin,nEntC08]) ) )
											lRetEntA := .F.

												If ( lEnt09 .and. ( Alltrim(oGetRateio:aCols[nI,nEntD09]) == Alltrim(oGetRateio:aCols[nLin,nEntD09]) );
												.and.;
												( Alltrim(oGetRateio:aCols[nI,nEntC09]) == Alltrim(oGetRateio:aCols[nLin,nEntC09]) ))
													lRetEntA := .F.
												Else
													lRetEntA := .T.
												Endif
										Else
											lRetEntA := .T.
										EndIf
									Else
										lRetEntA := .T.
									Endif
								Else 
									lRetEntA := .T.
								EndIf
							Else
									lRetEntA := .T.
							Endif
						EndIf
				EndIf
			Endif	
			If !lRetEntP .and. !lRetEntA
				lRet := .f.
				Help(" ",1,"FA011LinOkB",, STR0030 + Alltrim(oGetRateio:aCols[nI,nPSeq]) + ".",1,0) //"Não é permitido repetir as mesmas entidades contábeis em linhas diferentes do rateio. Ao menos uma delas deve estar diferente."
			
			Endif
		Endif
			
		
		If !lRet
			Exit
		Endif
	Next nI
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011AllOk  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do formulario de cadastro de rateio.			   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011AllOk(oGetRateio,nOpc)	                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetRateio- objeto: instancia de MsNewGetDados            	³±±
±±³			 ³nOpc		- Numeric: Opcao de manipulacao de dados 		    ³±±
±±³			 ³				2 - Visualizar 		  							³±±
±±³			 ³				3 - Incluir 		  							³±±
±±³			 ³				4 - Alterar 		  							³±±
±±³			 ³				5 - Excluir 		  							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³lRet	- Boolean: Se o formulario foi validado			        ³±±
±±³       	 ³		.t. - formulario validado								³±±
±±³       	 ³		.f. - formulario invalidado								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF011AllOk(oGetRateio,nOpc)

Local lRet	:= .t.
Local nI	:= 0

If (nOpc == 3) .Or. (nOpc == 4)		//Inclusão ou alteração
	For nI := 1 to len(oGetRateio:aCols)
		If oGetRateio:ChkObrigat(nI)
			If !oGetRateio:aCols[nI,len(oGetRateio:aHeader)+1]
				lRet := FA011LinOk(oGetRateio,nI)
				If !lRet
					Exit
				EndIf
			Endif
		Endif
	Next nI
	
	If lRet
		lRet := AF011ExisEnt(oGetRateio)
	EndIf
EndIf


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011FullPerc	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se houve o 100% da distribuicao do rateio			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011FullPerc(nPercRat,nPercARat)	 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPercRat	- Numeric: Valor rateado		  					  ³±±
±±³          ³nPercARat	- Numeric: Valor a ratear							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna se o percentual alcancou 100%.	      ³±±
±±³			 ³					.t. - percentual alcancado				      ³±±
±±³			 ³					.f. - percentual nao alcancado			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF011FullPerc(nPercRat,nPercARat)

Local lRet	:= .t.

If nPercRat < 100 .and. nPercARat > 0
	lRet := .f.
	Help(" ",1,"AF011FullPerc",,STR0031,1,0)	//"O percentual distribuído não alcançou 100%."
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011Grv		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao dos arquivos SNV e SN3.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011Grv(nOpc,aDados)									      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc	- Numeric: Opcao de manipulacao de dados de aRotina   	  ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±³          ³aDados	- Array: dados do rateio. 							  ³±±
±±³          ³	aDados[i,1] - Char: Codigo do Rateio						  ³±±
±±³          ³	aDados[i,2] - Char: Revisao do Rateio						  ³±±
±±³          ³	aDados[i,3] - Char: Status do Rateio						  ³±±
±±³          ³		"1"	- Disponivel										  ³±±
±±³          ³		"2"	- Pendente de classificacao							  ³±±
±±³          ³		"3"	- Ativo												  ³±±
±±³          ³		"4"	- Ativo Baixado										  ³±±
±±³          ³		"5"	- Finalizado										  ³±±
±±³          ³	aDados[i,4] - Numeric: Nro da Linha do Grid do Item da		  ³±±
±±³          ³	do Ativo (nAt da GetDados do SN3)							  ³±±
±±³          ³	aDados[i,5] - Array: Similar ao aCols, com o Rateio		      ³±±
±±³          ³		aDados[i,5,j] - Array: Linhas do aCols	  				  ³±±
±±³          ³			aDados[i,5,j,k] - Any: Colunas do aCols			  	  ³±±
±±³          ³	aDados[i,6] - Boolean: Demonstra se o item da ficha do Ativo  ³±±
±±³          ³foi apagado na GetDados do SN3. Se .T. - item apagado 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lManipulou	- Boolean: Retorna se houve hesito na manipulacao ³±±
±±³          ³dos registros.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF011Grv(nOpc,aDados)

Local aHeader		:= {}//AF011HeadSNV()
Local aCodeRateio	:= {}
Local aAreaSN3 		:= SN3->(GetArea())

Local nI			:= 0
Local nX			:= 0
Local nZ			:= 0
Local nPSeq			:= 0//aScan(aHeader,{|x| alltrim(x[2]) == "NV_SEQUEN"})

Local lInsert 		:= (nOpc == 3)
Local lUpdate 		:= (nOpc == 4)
Local lDelete 		:= .f.
Local lAtfA011		:= IsInCallStack("ATFA011")
Local lLock			:= .f.
Local lGetSxE		:= .f.
Local lManipulou	:= .f.
Local cSeq			:= ""

Local cBusca		:= ""

cSeq			:= STRZERO(0,TamSx3("NV_SEQUEN")[1])

aHeader	:= AF011HeadSNV()
nPSeq	:= aScan(aHeader,{|x| alltrim(x[2]) == "NV_SEQUEN"})

If lInsert .or. lUpdate //.or. lDelete
	
	For nI := 1 to len(aDados)
		
		If Empty(aDados[nI,1])
			
			aCodeRateio		:= AF011COD()
			aDados[nI,1] 	:= aCodeRateio[1]
			
			If Empty(aDados[nI,2])
				aDados[nI,2] := aCodeRateio[2]
			Endif
			
			lGetSxE			:= aCodeRateio[3]
			
		Endif
		
		
		//se o item da ficha de ativo foi deletado,
		//e for uma alteracao de cadastro, entao devera assumir como delecao ao inves de alteracao
		If aDados[nI,6] .and. lUpdate
			lDelete := .t.
			lUpdate := .f.
			//Se o item da ficha de ativo foi deletado e for uma inclusao, entao ignora-se esta inclusao
		ElseIf aDados[nI,6] .and. lInsert
			Loop
		Endif
		
		If !lATFA011 .and. (lUpdate .or. lInsert) .and. aDados[nI,3] == "5"
			
			AF011NewRev(aDados[nI,1],aDados[nI,2],aDados[nI,5],"3")
			
		ElseIf !lAtfa011 .and. lDelete
			lManipulou := AF011DEL(aDados,.T.,nI)
		Else
			For nX := 1 to len(aDados[nI,5])
				If !lInsert
					SNV->(DbSetOrder(1)) //NV_FILIAL+NV_CODRAT+NV_REVISAO+NV_SEQUEN
					cBusca := xFilial("SNV") +;
					PadR(aDados[nI,1],TamSx3("NV_CODRAT")[1])+;
					PadR(aDados[nI,2],TamSx3("NV_REVISAO")[1])+;
					PadR(aDados[nI,5,nX,nPSeq],TamSx3("NV_SEQUEN")[1])
					
					lLock := !SNV->(dbSeek(cBusca))
					
					If !lDelete
						lDelete := aDados[nI,5,nX,len(aHeader)+1]
					Endif
				Else
					lLock 	:= .t.
					lDelete := aDados[nI,5,nX,len(aDados[nI,5,nX])]
				Endif
				
				If !lDelete
					cSeq := Soma1(cSeq)
					RecLock("SNV",lLock)
					
					SNV->NV_FILIAL 	:= xFilial("SNV")
					SNV->NV_CODRAT 	:= aDados[nI,1]
					SNV->NV_REVISAO	:= aDados[nI,2]
					SNV->NV_STATUS	:= aDados[nI,3]
					
					For nZ := 1 to len(aHeader)	// = aDados[nI,5,nX] (-) campo de delecao
						SNV->&(aHeader[nZ,2]) := aDados[nI,5,nX,nZ]
					Next nZ
					
					SNV->NV_SEQUEN	:= cSeq
					
					SNV->(MsUnlock())
				Else
					
					If !lLock
						//AF011DEL(aDados,.f.,nI)
						RecLock("SNV",.F.)
						SNV->(DbDelete())
						SNV->(MsUnlock())
					Endif
					
					If lUpdate .or. lInsert
						lDelete := .f.
					Endif
				Endif
				
				If !lManipulou
					lManipulou := .t.
				Endif
				
			Next nX
			
		Endif
		
		If lManipulou .and. lDelete
			
			AF011DVinc(aDados[nI,1])
			
		Endif
		
		If !lAtfA011 .and. lUpdate .and. lGetSxE //lAtfA010 .and. nOpc == 4 .and. lGetSxE
			SNV->(ConfirmSX8())
		Endif
		
	Next nI
Endif

Return(lManipulou)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011CRateio	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega aDados com aCols do rateio, encontrado em SNV.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011CRateio(aDados)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aDados	- Array: dados do rateio. 							  ³±±
±±³          ³	aDados[i,1] - Char: Codigo do Rateio						  ³±±
±±³          ³	aDados[i,2] - Char: Revisao do Rateio						  ³±±
±±³          ³	aDados[i,3] - Char: Status do Rateio						  ³±±
±±³          ³		"1"	- Disponivel										  ³±±
±±³          ³		"2"	- Pendente de classificacao							  ³±±
±±³          ³		"3"	- Ativo												  ³±±
±±³          ³		"4"	- Ativo Baixado										  ³±±
±±³          ³		"5"	- Finalizado										  ³±±
±±³          ³	aDados[i,4] - Numeric: Nro da Linha do Grid do Item da		  ³±±
±±³          ³	do Ativo (nAt da GetDados do SN3)							  ³±±
±±³          ³	aDados[i,5] - Array: Similar ao aCols, com o Rateio		      ³±±
±±³          ³		aDados[i,5,j] - Array: Linhas do aCols	  				  ³±±
±±³          ³			aDados[i,5,j,k] - Any: Colunas do aCols			  	  ³±±
±±³          ³	aDados[i,6] - Boolean: Demonstra se o item da ficha do Ativo  ³±±
±±³          ³foi apagado na GetDados do SN3. Se .T. - item apagado 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nil															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF011CRateio(aDados)

Local aHeader	:= AF011HeadSNV()
Local aCols		:= {}
Local aAreaSNV	:= SNV->(GetArea())
Local nI		:= 0

Local cBusca	:= ""

SNV->(DbSetOrder(1))
cBusca := 	PadR(xFilial("SNV"),TamSx3("NV_FILIAL")[1]) +;
PadR(SNV->NV_CODRAT,TamSx3("NV_CODRAT")[1]) +;
PadR(SNV->NV_REVISAO,TamSx3("NV_REVISAO")[1])

If SNV->(DbSeek(cBusca))
	While SNV->(!Eof()) .and. cBusca == Padr(SNV->NV_FILIAL,TamSX3("NV_FILIAL")[1]) +;
		PadR(SNV->NV_CODRAT,TamSx3("NV_CODRAT")[1])+;
		PadR(SNV->NV_REVISAO,TamSx3("NV_REVISAO")[1])
		aAdd(aCols,Array(Len(aHeader)+1))
		
		For nI := 1 to len(aHeader)
			aCols[len(aCols),nI] := CriaVar(aHeader[nI,2])
			aCols[len(aCols),nI] := SNV->&(aHeader[nI,2])
		Next nI
		
		aCols[len(aCols),len(aHeader)+1] := .F.
		
		SNV->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSNV)

aAdd(aDados, {SNV->NV_CODRAT,SNV->NV_REVISAO,SNV->NV_STATUS,1,aCols,.F.})

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF11RetName	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Descricao dos campos de aFields que deverao compor a TwBrowse.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF11RetName(aFields)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFields	- Array: Campos de SN3. 							  ³±±
±±³          ³	aFields[1] - Char: Codigo do Bem (N3_CBASE)					  ³±±
±±³          ³	aFields[2] - Char: Item do Bem (N3_ITEM)					  ³±±
±±³          ³	aFields[3] - Char: Sequencia (N3_SEQ)						  ³±±
±±³          ³	aFields[4] - Char: Tipo (N3_TIPO)							  ³±±
±±³          ³	aFields[5] - Char: Descricao (N3_HISTOR)					  ³±±
±±³          ³	aFields[6] - Char: Tipo de saldo (N3_TPSALDO)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aFieldName	- Array: Nome dos Campos na mesma sequencia dos   ³±±
±±³          ³itens de aFields.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF11RetName(aFields)

Local aFieldName	:=  {}

Local nI			:= 0

For nI := 1 to len(aFields)
	aAdd(aFieldName,Af11FldName(aFields[nI]))
Next nI

Return(aFieldName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF11RetTam	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tamanho das colunas da TwBrowse.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF11RetTam(aFields,aFieldName)							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFields		- Array: Campos de SN3. 						  ³±±
±±³          ³		aFields[1] - Char: Codigo do Bem (N3_CBASE)				  ³±±
±±³          ³		aFields[2] - Char: Item do Bem (N3_ITEM)				  ³±±
±±³          ³		aFields[3] - Char: Sequencia (N3_SEQ)					  ³±±
±±³          ³		aFields[4] - Char: Tipo (N3_TIPO)						  ³±±
±±³          ³		aFields[5] - Char: Descricao (N3_HISTOR)				  ³±±
±±³          ³		aFields[6] - Char: Tipo de saldo (N3_TPSALDO)			  ³±±
±±³          ³aFieldName	- Array: Nome dos Campos na mesma sequencia dos   ³±±
±±³          ³itens de aFields.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aFieldSize	- Array: Tamanho dos Campos na mesma sequencia dos³±±
±±³          ³itens de aFields. Caso a descricao do campo seja maior que o    ³±±
±±³          ³tamanho do dado suportado no campo em caracteres, assume-se o   ³±±
±±³          ³tamanho da descricao do campo.   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF11RetTam(aFields,aFieldName)

Local aFieldSize	:= {}

Local nI			:= 0
Local nTam			:= 0

For nI := 1 to len(aFields)
	
	If Len(Alltrim(aFieldName[nI])) > TamSx3(Alltrim(aFields[nI]))[1]
		nTam := Len(aFieldName[nI])
	Else
		nTam := TamSx3(Alltrim(aFields[nI]))[1]
	Endif
	
	aAdd(aFieldSize,nTam)
Next nI

Return(aFieldSize)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF11RetTam	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Dados da SN3.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF11RetData(aFields,cBem,cItBem)							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFields		- Array: Campos de SN3. 						  ³±±
±±³          ³		aFields[1] - Char: Codigo do Bem (N3_CBASE)				  ³±±
±±³          ³		aFields[2] - Char: Item do Bem (N3_ITEM)				  ³±±
±±³          ³		aFields[3] - Char: Sequencia (N3_SEQ)					  ³±±
±±³          ³		aFields[4] - Char: Tipo (N3_TIPO)						  ³±±
±±³          ³		aFields[5] - Char: Descricao (N3_HISTOR)				  ³±±
±±³          ³		aFields[6] - Char: Tipo de saldo (N3_TPSALDO)			  ³±±
±±³          ³cBem			- Char: Codigo Base do Bem						  ³±±
±±³          ³cItBem		- Char: Item do Bem								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aFieldData	- Array: Dados de registros do arquivo SN3, 	  ³±±
±±³          ³que podem estar filtrados ou nao. Os dados acompanham as colunas³±±
±±³          ³definidas por aFields e em mesma ordem						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - ATFA011 - Localizacao Argentina					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF11RetData(aFields,cBem,cItBem)

Local aFieldData	:= {}
Local cQry			:= ""
Local cCampos		:= ""

Local nI			:= 0

Default cBem		:= ""
Default cItBem		:= ""

aEval(aFields,{|x| cCampos += x + ","})

cCampos := Substr(cCampos,1,Rat(",",cCampos)-1)

cQry := "SELECT " +  chr(13) + chr(10)
cQry +=	cCampos +  chr(13) + chr(10)
cQry += " FROM " +  chr(13) + chr(10)
cQry += "	" + RetSqlName("SN3") + " SN3 " +  chr(13) + chr(10)
cQry += "WHERE " +  chr(13) + chr(10)
cQry += "	N3_FILIAL = '" +xFilial("SN3")+ "' " +  chr(13) + chr(10)
cQry += "	AND " +  chr(13) + chr(10)

If !Empty(cBem)
	cQry += "	N3_CBASE = '" + cBem + "' " +  chr(13) + chr(10)
	cQry += "	AND " +  chr(13) + chr(10)
Endif

If !Empty(cItBem)
	cQry += "	N3_ITEM = '" + cItBem + "' " +  chr(13) + chr(10)
	cQry += "	AND " +  chr(13) + chr(10)
Endif

cQry += "	N3_BAIXA <> '1' " +  chr(13) + chr(10)
cQry += "	AND " +  chr(13) + chr(10)
cQry += "	N3_RATEIO <> '1' " +  chr(13) + chr(10)
cQry += "	AND " +  chr(13) + chr(10)
cQry += "	SN3.D_E_L_E_T_ = ' ' " +  chr(13) + chr(10)
cQry += "ORDER BY " +  chr(13) + chr(10)
cQry += "	N3_CBASE, " +  chr(13) + chr(10)
cQry += "	N3_ITEM, " +  chr(13) + chr(10)
cQry += "	N3_SEQ, " +  chr(13) + chr(10)
cQry += "	N3_TIPO, " +  chr(13) + chr(10)
cQry += "	N3_TPSALDO "

If Select("TRBSN3") > 0
	TRBSN3->(DbClosearea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBSN3", .T., .F.)

If TRBSN3->(!Eof())
	
	While TRBSN3->(!Eof())
		aAdd(aFieldData,array(Len(aFields)))
		For nI := 1 to len(aFields)
			aFieldData[len(aFieldData),nI] := TRBSN3->&(aFields[nI])
		Next nI
		TRBSN3->(dbSkip())
	EndDo
	
Else
	aAdd(aFieldData,array(Len(aFields)))
	For nI := 1 to len(aFields)
		aFieldData[len(aFieldData),nI] := CriaVar(aFields[nI])
	Next nI
Endif

TRBSN3->(DbClosearea())
Return(aFieldData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af11FldName	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Titulo do campo.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Af11FldName(cCampo)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo - Char: alias do campo no dic. SX3.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cTitulo- Char: Titulo do campo cadastrado no dicionario de dados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina					      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af11FldName(cCampo)

Local cTitulo	:= ""

Local aAreaSx3	:= SX3->(GetArea())

SX3->(DbSetOrder(2))

If SX3->(DbSeek(Alltrim(cCampo)))
	cTitulo := Alltrim(X3Titulo())
Else
	cTitulo := Alltrim(cCampo)
Endif

RestArea(aAreaSX3)
Return(cTitulo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011COD		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Capta o codigo do rateio e revisao.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011COD(cCodRat,lNewRev)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodRat - Char: Codigo do rateio.								  ³±±
±±³          ³lNewRev - Boolean: Retorna uma nova revisao?					  ³±±
±±³          ³	.T. -> Sim													  ³±±
±±³          ³	.F. -> Nao													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Array: Dados do Codigo de rateio						  ³±±
±±³          ³	aRet[1]	- Char: Codigo de rateio							  ³±±
±±³          ³	aRet[2]	- Char: Revisao de rateio							  ³±±
±±³          ³	aRet[3]	- Boolean: Se foi gerado um novo nro de codigo 		  ³±±
±±³          ³		.T. -> Sim										 		  ³±±
±±³          ³		.F. -> Nao										 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina					      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011COD(cCodRat,lNewRev)

Local aAreaSNV 	:= {}
Local aRet		:= Array(3)

Default cCodRat := ""
Default lNewRev	:= .f.

aAreaSNV := SNV->(GetArea())

If Type("FN9_FILDES") <> "U" .And. FunName() = "ATFA060"
	cFilAnt	:=   M->FN9_FILDES
ENDIF

If Empty(cCodRat)
	
	aRet[1] := GetSXeNum("SNV","NV_CODRAT")
	
	While SNV->(DbSeek(xFilial("SNV") + aRet[1]))
		aRet[1] := GetSXeNum("SNV","NV_CODRAT")
	EndDo
	
	aRet[2] := Strzero(1,TamSx3("NV_REVISAO")[1])
	aRet[3] := .T.
Else
	aRet[1] := cCodRat
	aRet[2] := AF011GETREV(cCodRat,lNewRev)
	aRet[3] := .F.
Endif

RestArea(aAreaSNV)
Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF011NewRev	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Finaliza revisao corrente e gera uma nova.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF011NewRev(cCodRat,cRevAtu,aCols,cStatus)				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodRat	- Char: Codigo do rateio.							  ³±±
±±³          ³cRevAtu	- Char: Revisao atual do rateio						  ³±±
±±³          ³aCols 	- Array: aCols da GetDados com dados da SNV			  ³±±
±±³          ³cStatus 	- Char: Status do Rateio							  ³±±
±±³          ³		"1"	- Disponivel										  ³±±
±±³          ³		"2"	- Pendente de classificacao							  ³±±
±±³          ³		"3"	- Ativo												  ³±±
±±³          ³		"4"	- Ativo Baixado										  ³±±
±±³          ³		"5"	- Finalizado										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: se efetuou a geracao da revisao				  ³±±
±±³          ³		.T. -> Revisao Gerada									  ³±±
±±³          ³		.F. -> Revisao Nao Gerada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina					      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF011NewRev(cCodRat,cRevAtu,aCols,cStatus)

Local aHeader	:= {}//AF011HeadSNV()
Local aAreaSnv	:= {}//SNV->(GetArea())

Local cNewRev	:= {}//AF011GETREV(cCodRat,.t.)
Local cBusca	:= ""

Local nI		:= 0
Local nX		:= 0
Local lRet		:= .f.

Default cStatus	:= "1"

aHeader		:= AF011HeadSNV()
aAreaSnv	:= SNV->(GetArea())
cNewRev		:= AF011GETREV(cCodRat,.t.)

cBusca := xfilial("SNV") + Padr(cCodrat,TamSx3("NV_CODRAT")[1]) + PadR(cRevAtu,TamSx3("NV_REVISAO")[1])
SNV->(DbSetOrder(1))

If SNV->(DbSeek(cBusca))
	
	Af011AtuStatus(SNV->NV_CODRAT,SNV->NV_REVISAO,"5",SNV->NV_MSBLQL == "1")
	
	For nI := 1 to len(aCols)
		
		If !aCols[nI,len(aCols[nI])]
			
			RecLock("SNV",.T.)
			
			SNV->NV_FILIAL := xFilial("SNV")
			SNV->NV_CODRAT := cCodRat
			SNV->NV_REVISAO:= cNewRev
			SNV->NV_STATUS := cStatus
			
			For nX := 1 to len(aHeader)
				SNV->&(aHeader[nX,2]) := aCols[nI,nX]
			Next nX
			
			SNV->(MsUnlock())
			
		Endif
		
		If !lRet
			lRet := .t.
		Endif
		
	Next nI
Endif

RestArea(aAreaSNV)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af011Len		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dialog da Legenda.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Af011Len()												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina					      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af011Len()

Local aCores := {	{"ENABLE"		,OemToAnsi(STR0032)},;	//"Rateio Disponível"
{"BR_AZUL"		,OemToAnsi(STR0033)},;	//"Rateio vinculado a Bem (Ativo)"
{"BR_AMARELO"	,OemToAnsi(STR0034)},;	//"Pendente de classificação"
{"BR_LARANJA"	,OemToAnsi(STR0035)},;	//"Ativo Baixado"
{"DISABLE"		,OemToAnsi(STR0036)},;	//"Rateio Finalizado"
{"BR_PRETO"		,OemToAnsi(STR0037)}}	//"Rateio Bloqueado"


BrwLegenda("Legenda",STR0038,aCores) //"Classificação dos Rateios"

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Af011AtuStatus³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o status ou bloqueia/desbloqueia um registro de rateio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Af011AtuStatus(cCodRat,cRevAtu,cNewStatus,lBloq)			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodRat		- Char: Codigo do rateio.						  ³±±
±±³          ³cRevAtu		- Char: Revisao atual do rateio					  ³±±
±±³          ³cNewStatus	- Char: Novo status do Rateio 					  ³±±
±±³          ³lBloq			- Boolean: Se e proveniente de bloqueio de 		  ³±±
±±³          ³registro.	.T. -> Sim, .F. -> Nao						 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina					      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Af011AtuStatus(cCodRat,cRevAtu,cNewStatus,lBloq)

Local aAreaSnv	:= {}//SNV->(GetArea())

Default lBloq	:= .f.

aAreaSnv := SNV->(GetArea())

SNV->(DbSetOrder(1))

SNV->(DbSeek(xFilial("SNV") + PadR(cCodRat,TamSx3("NV_CODRAT")[1]) + PadR(cRevAtu,TamSx3("NV_REVISAO")[1])))

While !SNV->(Eof())	.and. Alltrim(xFilial("SNV")) == Alltrim(SNV->NV_FILIAL);
	.and. Alltrim(cCodRat) == Alltrim(SNV->NV_CODRAT);
	.and. Alltrim(cRevAtu) == Alltrim(SNV->NV_REVISAO)
	
	RecLock("SNV",.F.)
	If !lBloq
		SNV->NV_STATUS := cNewStatus
	Else
		If SNV->NV_MSBLQL == "2" .or. Empty(SNV->NV_MSBLQL)
			cBloq := "1"
		Else
			cBloq := "2"
		Endif
		
		SNV->NV_MSBLQL := cBloq
		SNV->NV_STATUS := cNewStatus
	Endif
	SNV->(MsUnlock())
	
	SNV->(DbSkip())
EndDo


RestArea(aAreaSnv)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA011   ºAutor  ³Microsiga           º Data ³  03/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011DEL(aRateio,lExcAll,nPos)
Local lRet			:= .F.
Local cSeek			:= ""
Local nI			:= 0
Local nInicio		:= 1
Local nFim			:= Len(aRateio)
Local aAreaSN3		:= SN3->(GetArea())
Local lAchou		:= .F.

Default lExcAll		:= .F.
Default nPos		:= 0

If nPos > 0
	nInicio	:= nPos
	nFim	:= nPos
Endif

For nI := nInicio to nFim
	SNV->(DbSetOrder(1))
	
	If !lExcAll
		
		cSeek := xfilial('SNV') +;
		PadR(aRateio[nI,1],TamSx3('NV_CODRAT')[1]) +;
		PadR(aRateio[nI,2],TamSx3('NV_REVISAO')[1])
		
		If SNV->(dbSeek(cSeek))
			lAchou := .T.
			lRet := .T.
			While !SNV->(Eof()) .and. Alltrim(xFilial('SNV')) == Alltrim(SNV->NV_FILIAL) .and. Alltrim(aRateio[nI,1]+aRateio[nI,2]) == Alltrim(SNV->(NV_CODRAT+NV_REVISAO))
				RecLock("SNV",.F.)
				SNV->(DbDelete())
				SNV->(MsUnlock())
				SNV->(DbSkip())
			EndDo
		Else
			lAchou := .F.
		Endif
	Else
		
		cSeek := xfilial('SNV') + PadR(aRateio[nI,1],TamSx3('NV_CODRAT')[1])
		
		If SNV->(dbSeek(cSeek))
			lAchou := .T.
			lRet := .T.
			While !SNV->(Eof()) .and. xFilial('SNV') == SNV->NV_FILIAL .and. Alltrim(aRateio[nI,1]) == Alltrim(SNV->NV_CODRAT)
				RecLock("SNV",.F.)
				SNV->(DbDelete())
				SNV->(MsUnlock())
				SNV->(DbSkip())
			EndDo
		Else
			lAchou := .F.
		Endif
	Endif
	
	If lRet .And. lAchou
		AF011DVinc(aRateio[nI,1])
	Endif
Next nI

RestArea(aAreaSN3)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA011   ºAutor  ³Microsiga           º Data ³  03/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF011DVinc(cCodRat)

Local aAreas	:= {}//{ SN3->(GetArea()), SNV->(GetArea())}

Local nI		:= 0

aAreas	:= { SN3->(GetArea()), SNV->(GetArea())}

SNV->(DbSetOrder(1))

If !SNV->(DbSeek(xFilial("SNV") + Alltrim(cCodRat)))
	
	SN3->(DbOrderNickName("RATEIO")) //Filial + Codigo do Rateio
	
	If SN3->(DbSeek(XFilial("SN3") + Alltrim(cCodRat) ))
		RecLock("SN3",.F.)
		SN3->N3_CODRAT := ""
		SN3->N3_RATEIO := "2"
		SN3->(MsUnlock())
	Endif
Endif

For nI := 1 to len(aAreas)
	RestArea(aAreas[nI])
Next nI

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA011   ºAutor  ³Microsiga           º Data ³  03/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Af011ExMov(cCodRat)

Local aAreas	:= { SN3->(GetArea()) , SN4->(GetArea()) , SNX->(GetArea()) }

Local nI		:= 0

Local cKeySN4	:= ""
Local cKeySNX	:= ""

Local lRet		:= .t.

SN3->(DbOrderNickName("RATEIO")) //Filial + Codigo do Rateio

If SN3->(dbSeek(xfilial("SN3") + SNV->NV_CODRAT))
	
	cKeySN4 := xFilial("SN4") +;
	PadR(SN3->N3_CBASE,TamSx3("N4_CBASE")[1])+;
	PadR(SN3->N3_ITEM,TamSX3("N4_ITEM")[1])+;
	PadR(SN3->N3_TIPO,TamSX3("N4_TIPO")[1])
	
	SN4->(DbSetOrder(1))	//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_DATA+N4_OCORR+N4_SEQ
	If SN4->(DbSeek(cKeySN4))
		While !SN4->(Eof())	 .and. cKeySN4 == SN4->N4_FILIAL +;
			Padr(SN4->N4_CBASE,TamSx3("N4_CBASE")[1])+;
			PadR(SN4->N4_ITEM,TamSX3("N4_ITEM")[1])+;
			PadR(SN4->N4_TIPO,TamSX3("N4_TIPO")[1])
			
			cKeySNX := PadR(SN4->N4_FILIAL,TamSx3("NX_FILIAL")[1])+;
			dTos(SN4->N4_DATA)+;
			PadR(SN4->N4_IDMOV,TamSx3("NX_IDMOV")[1])+;
			PadR(SN4->N4_TPSALDO,TamSx3("NX_TPSALDO")[1])
			
			SNX->(DbSetOrder(1))//NX_FILIAL	+NX_DTMOV+NX_IDMOV+NX_TPSALDO+NX_MOEDA
			If SNX->(DbSeek(cKeySNX))
				lRet := .f.
				Help(" ",1,"Af011ExMov",,STR0039,1,0) //"Existe alguma movimentação ocorrida para este rateio."
				Exit
			Endif
			SN4->(Dbskip())
		EndDo
	Endif
Endif

For nI := 1 to len(aAreas)
	RestArea(aAreas[nI])
Next nI

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF011ExisEnt   ºAutor  ³Renan Guedes   º Data ³  08/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as entidades contábeis do rateio na inclusão/		  º±±
±±º          ³modificação e no desbloqueio.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF011ExisEnt(oGetRateio,cCodRat,cRevisao)

Local nX	   		:= 1
Local aAreaSNV		:= {}
Local aAreaCTH		:= {}
Local aAreaCTD		:= {}
Local aAreaCTT		:= {}
Local aAreaCT1		:= {}
Local nPosCC   		:= 0
Local nPosCta  		:= 0
Local nPosItem 		:= 0
Local nPosClas 		:= 0
Local lExisEnt		:= .T.

Default oGetRateio	:= Nil
Default cCodRat		:= ""
Default cRevisao	:= ""

If !Empty(cCodRat) .And. !Empty(cRevisao)
	dbSelectArea("SNV")
	aAreaSNV := SNV->(GetArea())
	dbSetOrder(1)		//NV_FILIAL+NV_CODRAT+NV_REVISAO+NV_SEQUEN
EndIf

//Salva as áreas das tabelas que serão posicionadas
dbSelectArea("CT1")		//Conta contábil
aAreaCT1 := CT1->(GetArea())
dbSetOrder(1)			//CT1_FILIAL+CT1_CONTA

dbSelectArea("CTT")		//Centro de custo
aAreaCTT := CTT->(GetArea())
dbSetOrder(1)			//CTT_FILIAL+CTT_CUSTO

dbSelectArea("CTD")		//Item contábil
aAreaCTD := CTD->(GetArea())
dbSetOrder(1)			//CTD_FILIAL+CTD_ITEM

dbSelectArea("CTH")		//Classe de valor
aAreaCTH := CTH->(GetArea())
dbSetOrder(1)			//CTH_FILIAL+CTH_CLVL

If !Empty(cCodRat) .And. !Empty(cRevisao)
	If SNV->(MsSeek(xFilial("SNV")+cCodRat+cRevisao))
		While SNV->(!EoF()) .And. (SNV->(NV_FILIAL+NV_CODRAT+NV_REVISAO) == xFilial("SNV")+cCodRat+cRevisao)
			If !Empty(SNV->NV_CONTA)
				If !CT1->(MsSeek(xFilial("CT1")+SNV->NV_CONTA))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(SNV->NV_CC)
				If !CTT->(MsSeek(xFilial("CTT")+SNV->NV_CC))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(SNV->NV_ITEMCTA)
				If !CTD->(MsSeek(xFilial("CTD")+SNV->NV_ITEMCTA))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(SNV->NV_CLVL)
				If !CTH->(MsSeek(xFilial("CTH")+SNV->NV_CLVL))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			SNV->(dbSkip())
		EndDo
	EndIf
ElseIf oGetRateio != Nil
	
	nPosCC   		:= ASCAN(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CC"})
	nPosCta  		:= ASCAN(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CONTA"})
	nPosItem 		:= ASCAN(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_ITEMCTA"})
	nPosClas 		:= ASCAN(oGetRateio:aHeader,{|x| alltrim(x[2]) == "NV_CLVL"})
	
	For nX := 1 To Len(oGetRateio:aCols)
		If !oGetRateio:aCols[nX,Len(oGetRateio:aHeader)+1]
			If !Empty(oGetRateio:aCols[nX,nPosCta])
				If !CT1->(MsSeek(xFilial("CT1")+oGetRateio:aCols[nX,nPosCta]))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(oGetRateio:aCols[nX,nPosCC])
				If !CTT->(MsSeek(xFilial("CTT")+oGetRateio:aCols[nX,nPosCC]))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(oGetRateio:aCols[nX,nPosItem])
				If !CTD->(MsSeek(xFilial("CTD")+oGetRateio:aCols[nX,nPosItem]))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
			If !Empty(oGetRateio:aCols[nX,nPosClas])
				If !CTH->(MsSeek(xFilial("CTH")+oGetRateio:aCols[nX,nPosClas]))
					lExisEnt := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

If !lExisEnt
	Help("",1,"AFA011RATI")		//"Entidades contábeis inconsistentes."##"Informe entidades contábeis existentes."
EndIf

RestArea(aAreaCTH)
RestArea(aAreaCTD)
RestArea(aAreaCTT)
RestArea(aAreaCT1)

If !Empty(cCodRat) .And. !Empty(cRevisao)
	RestArea(aAreaSNV)
EndIf

Return(lExisEnt)
