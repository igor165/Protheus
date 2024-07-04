#INCLUDE "CTBA250.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTBA250   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 30.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Cadastro de Amarracao Contabil               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba250()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA250()
 
local lRet := .F.
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006)  // "Cadastro Amarracao"
PRIVATE lCtbUseAmar := CtbUseAmar() $ '2#3'	
PRIVATE cTamanho 	:= StrZero(1,TamSx3("CTA_ITREGR")[1])

Private aIndexFil	:= {}
Private aIndexes

Private bFiltraBrw
Private cBrwFiltro	:= "" 


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf
SetKey(VK_F12,{|a,b|Pergunte("CTB250",.T.)})
Pergunte("CTB250",.F.)

lRet := CTB250SX1()

If lCtbUseAmar
	If lRet .And. mv_par02 == 2	//Exibe todas as linhas de amarracoes na amarracao, apos alteracoes pelo changeset -> 641330.
		cBrwFiltro := ' (CTA_ITREGR >= "'+cTamanho+'" .OR. Empty(CTA_ITREGR))' //retornado condicao empty(CTA_ITREGR) por conta do help -> Deseja efetuar a amarracao dos itens? = Nao
	Else	//Exibe somente a linha geral da amarracao, como fazia antes no changeset 337349.
		cBrwFiltro := ' (CTA_ITREGR == "'+cTamanho+'" .OR. Empty(CTA_ITREGR))'
	Endif

	bFiltraBrw := { || FilBrowse("CTA",@aIndexFil,@cBrwFiltro) }
	DbSelectArea("CTA")
	Eval(bFiltraBrw)
Endif
	
mBrowse( 6, 1,22,75,"CTA" )  

If lCtbUseAmar
	EndFilBrw("CTA",aIndexFil)
Endif

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA250DLG Autor ³TOTVS               º Data ³  03/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA250DLG(cAlias,nReg,nOpc)
Local aAreaAtu	:= GetArea()
Local aCampos	:= {}	
Local nQtdeEnt	:= CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
Local cCampos	:= ""
Local nX		:= 0  
Local cRegra 
Local nMov	:= MV_PAR01 

If nQtdeEnt > 4     
	cCampos := "*"
	For nX:=5 To nQtdeEnt
		cCampos += "CTA_ENTI" + StrZero(nX,2) + Iif(nX<nQtdeEnt,"*","")	
	Next nX
EndIf

DbSelectArea('SX3')
DbSetOrder(1)
If DbSeek( 'CTA' )        
	While SX3->(!Eof()) .And. X3_ARQUIVO == 'CTA'
		If	x3uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		    If !(Alltrim(SX3->X3_CAMPO) $ "CTA_ITREGR*CTA_CONTA*CTA_CUSTO*CTA_ITEM*CTA_CLVL"+cCampos)
				AADD( aCampos,SX3->X3_CAMPO )	    
	    	EndIf
	    EndIf
		SX3->(DbSkip())	     	
    EndDo
EndIf 

If nOpc == 2 .Or. nOpc == 4
	If !lCtbUseAmar
		If nOpc == 2
			AxVisual(cAlias,nReg,nOpc,aCampos)
		Else
			AxAltera(cAlias,nReg,nOpc,aCampos)		
		Endif
	Else
	    If nMov==1 .AND.nopc==4
			
			CTBA811ROT(cAlias,nReg,nOpc)
		Else	
			CTBA810( cAlias,nReg,nOpc )
			
		Endif	
	EndIf
ElseIf nOpc == 3
	nOpcA := AxInclui(cAlias,nReg,nOpc,aCampos)

	If lCtbUseAmar .And. nOpcA == 1 .And. MsgYesNo( STR0009 )  //"Deseja efetuar a amarracao dos itens?"
	    If nMov==1 .AND. FindFunction("CTBA811")
			CTBA811ROT(cAlias,CTA->(Recno()),nOpc)
		Else	
			CTBA810( cAlias,CTA->(Recno()),nOpc )
		Endif						
	Endif

ElseIf nOpc == 5
	dbSelectArea('CTA')
	dbSetOrder(1)
	cRegra := CTA->CTA_REGRA
	CTA->( dbSeek(xFilial()+cRegra) )
	If	Aviso(STR0007, STR0008+cRegra+"-"+Alltrim(CTA->CTA_DESC)+STR0010, {STR0011,STR0012})==1  //" Tem Certeza ? "##"Sim"##"Não"
		While CTA->( !Eof() .And. CTA_FILIAL+CTA_REGRA == xFilial()+cRegra)
			RecLock("CTA",.F.,.T.)
			dbDelete()
			MsUnlOCK()
			CTA->( DbSkip() )
		EndDo
	EndIf
EndIf

MV_PAR01:=nMov
RestArea(aAreaAtu)
Return()
                    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
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
Static Function MenuDef()
Local aRotina := { 	{ OemToAnsi(STR0001),"AxPesqui", 0 , 1,,.F.},;  //"Pesquisar"
						{ OemToAnsi(STR0002),"CTBA250DLG", 0 , 2},;  // "Visualizar"
						{ OemToAnsi(STR0003),"CTBA250DLG", 0 , 3},;  // "Incluir"
						{ OemToAnsi(STR0004),"CTBA250DLG", 0 , 4},;  // "Alterar"
						{ OemToAnsi(STR0005),"CTBA250DLG", 0 , 5} }  // "Excluir"
Return(aRotina)

function CTB250SX1()

Local oObjPerg
Local aPergunte
Local lRet := .F.
Local cPerg := 'CTB250'

oObjPerg := FWSX1Util():New()
oObjPerg:AddGroup(cPerg)


oObjPerg:SearchGroup()
aPergunte := oObjPerg:GetGroup(cPerg)

If Len(aPergunte[2]) > 1 //Verifica se o MV_PAR02 esta criado
	lRet := .T.
EndIf

Return lRet
