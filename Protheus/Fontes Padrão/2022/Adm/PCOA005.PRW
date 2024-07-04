#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA005.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA005	³ Autor ³ Luiz Enrique	     	  ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Acoes. - Planejamento Orcamentario.					 ³±±
±±³			 ³ AS OPCOES DE INCLUSAO E ALTERACAO, FORAM RETIRADAS POR    	 ³±±
±±³			 ³ DEFINICAO DE REGRA DE NEGOCIO. POREM AS FUNCOES DE VALIDACOES³±±
±±³			 ³ FORAM MANTIDAS PARA USO FUTURO: VldExcAca() e VldAltAca()  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOA005 ()

Private aRotina 	:= {} 
Private cCadastro	:= STR0001 //"Ações do Planejamento Orçamentário"  

dbSelectArea("AMI")
dbSetOrder(1)
dbGoTop()

aAdd( aRotina ,{"Pesquisar" 	,"AxPesqui",0,1})
aAdd( aRotina ,{"Visualizar"	,"AxVisual",0,2})

mBrowse(,,,,"AMI")

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldExcAca ³ Autor ³ Luiz Enrique	     	  ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Exclusao no Cadastro de Acoes.							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldExcAca()

Local lret := .T.

Local aRet:=FunRetPadr (Nil,AMI->AMI_CODEVT)	//Verifica se Acao e Padrao	

If aRet[2]  
	MsgBox(STR0002) //"A Ação em questão é padrão e não pode ser Excluida."
	Return .f.
Endif

AMH->(DbGoTop())
While AMH->(!Eof())
	If AMI->AMI_CODEVT == AMH->AMH_CODEVT
		lRet := .f.
		Exit
	EndIf
	AMH->(DbSkip())
EndDo

If !lret
	Aviso(STR0003,STR0004,{STR0005},2,STR0006)  // "Atenção" //"Impossível Excluir. Existem Fases associadas a esta Ação." // "Voltar" // "Exclusão de Ação"
EndIf

Return lRet   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldAltAca ³ Autor ³ Luiz Enrique	     	  ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Inclusao e ALteracao no Cadastro de Acoes.			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VldAltAca()

Local lret := .T.
Local nRecAtu:= AMI->(Recno())

Local aRet:=FunRetPadr (Nil,AMI->AMI_CODEVT)	//Verifica se Acao e Padrao	

If aRet[2]  
	MsgBox(STR0007) //"A Ação em questão é padrão e não pode ser Alterada."
	Return .f.
Endif 

AMI->(DbGoTop())

While AMI->(!Eof()) 
	If AMI->AMI_CODEVT == M->AMI_CODEVT .And. nRecAtu <> AMI->(Recno())
		lRet:=.f.
		Exit
	Endif
	AMI->(Dbskip())
Enddo

If !lret
	Aviso(STR0003,STR0008,{STR0005},2,STR0009) //"Atenção" //"Operação Inválida. Código da Ação já existente." //"Voltar" //"Manutenção da Ação"
EndIf

AMI->(DbGoto(nRecAtu))

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FunRetPadr³ Autor ³ Luiz Enrique	     	  ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um Array contendo: 											 ³±±
±±³			 ³ 1- Valor logico da existencia da Fase Padrao - Defaut = .F.	 ³±±
±±³			 ³ 2- Valor logico da existencia da Acao Padrao - Defaut = .F.	 ³±±
±±³			 ³ 3- Array com os codigos Padrao das Fases.							 ³±±
±±³			 ³ 4- Array com os codigos Padrao das Acoes.					   	 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cFase: Opcional, Informa codigo da Fase a ser pesquisada ou  ³±±
±±³   		 ³ cAcao: Opcional, Informa codigo da Acao a ser pesquisada.	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ aRetPadrao: {lExiteFase,lExistAcao,aFases,aAcoes}            ³±±
±±³   		 ³ lExiteFase 	=	{T ou F na existencia da Fase recebida}		 ³±±
±±³   		 ³ lExistAcao	=	{T ou F na existencia da acao recebida}		 ³±±
±±³   		 ³ aFases  		=	{codigos das Fases Padrao}							 ³±±
±±³   		 ³ aAcoes  		=	{codigos das Acoes Padrao}							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FunRetPadr (cFase,cAcao)

Local nLp
Local aAcoes	:= {}
Local aFases	:= {}
Local aF			:= {}
Local aA			:= {} 

Local aAreaAMI	:= GetArea("AMI")
Local aAreaAMG	:= GetArea("AMG")
Local aAreaAMH	:= GetArea("AMH")

Local lretF		:=.f.
Local lretA		:=.f.

PCO5ARRPAD (@aFases,@aAcoes)
     
AMI->(dbSetOrder(2)) //ACOES:			Filial + Descricao
AMG->(dbSetOrder(2)) //FASES:			Filial + Descricao
AMH->(dbSetOrder(1)) //AMARRACAO:	Filial + Codigos da Fase + Codigo da Acao 

//Monta Array com os codigos das FASES Padrao
aF:= {} 
For nLp:= 1 To Len(aFases)  
	AMG->(DbSeek(xFilial()+Upper(aFases[nLp,1])))	
	aAdd(aF,{AMG->AMG_COD})	
Next

//Monta Array com os codigos das ACOES Padrao
aA:= {} 
For nLp:= 1 To Len(aAcoes)
	AMI->(DbSeek(xFilial()+Upper(aAcoes[nLp,1])))
	aAdd(aA,{AMI->AMI_CODEVT})	
Next

If!Empty(cFase)
	lretF := Ascan(aF,{|x| x[01] == cFase}) > 0
Endif

If!Empty(cAcao)
	lretA := Ascan(aA,{|x| x[01] == cAcao}) > 0
Endif

aRetPadrao:={lretF,lretA,aF,aA}

RestArea(aAreaAMI)
RestArea(aAreaAMG)
RestArea(aAreaAMH)

Return aRetPadrao  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOEdiAcao³ Autor ³ Luiz Enrique	        ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Alteracao do campo e permitida considerando os ³±±
±±³			 ³ codigos padroes das ACOES.						 						 ³±±
±±³			 ³ Utilizado no X3_WHEN dos campos AMI_CODEVT e AMI_DESCRI.		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOEdiAcao()

Local aRet
Local lRet:= .F.  

aRet:=FunRetPadr (Nil,M->AMI_CODEVT)	//Verifica se Fase Padrao
lRet:=aRet[2] 

Return lRet

