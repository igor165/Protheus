#INCLUDE "TMKC010C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DbTREE.CH"
#INCLUDE "TMKDEF.CH"

#DEFINE cPerg "TMKC10"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn35  ºAutor  ³Vendas Clientes	   º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Titulos Protestados        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn35(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local aCoord    := {}													// Array com as coordenadas da tela	
Local oLB01Pn37															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := SE1->(RecNo())										// Registro do SE1 associado a consulta.
Local oEnchoice															// Enchoice com os campos do SE1
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSE1Exc	:= (X2ModAcess("SE1") == "E")							// Indica se o SE1 esta como exclusivo

aCabeca := TKCListBox("SE1", aEmpCont, nPanel,,P_ANF_PROTESTADO)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
									"",;
									STR0096; //"	01} SE1 - Títulos do contas a receber"
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft ListBox oLB01Pn37 Fields;
				Header	STR0246,; // 01 - Filial
						STR0097,; // 02 - Prefixo 
						STR0098,; // 03 - Titulo 
						STR0099,; // 04 - Parcela 
						STR0100,; // 05 - Tipo 
					 	STR0101,; // 06 - Natureza 
						STR0077,; // 07 - Descricao 
						STR0102,; // 08 - Portador 
						STR0008,; // 09 - Nome 
						STR0103,; // 10 - Emissao 
						STR0104,; // 11 - Vencimento 
						STR0105,; // 12 - Venc. Real 
						STR0106,; // 13 - Venc. Original 
						STR0078,; // 14 - Valor 
						STR0034,; // 15 - Saldo 
						STR0107,; // 16 - IRRF  
						STR0108,; // 17 - ISS 
						STR0109,; // 18 - Bordero 
						STR0110;  // 19 - Data Bord. 
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn37:SetArray(aCabeca)
oLB01Pn37:bLine:={||{	aCabeca[oLB01Pn37:nAt,19],;
						aCabeca[oLB01Pn37:nAt,1],;
						aCabeca[oLB01Pn37:nAt,2],;
						aCabeca[oLB01Pn37:nAt,3],;
						aCabeca[oLB01Pn37:nAt,4],;
						aCabeca[oLB01Pn37:nAt,5],;
						aCabeca[oLB01Pn37:nAt,6],;
						aCabeca[oLB01Pn37:nAt,7],;
						aCabeca[oLB01Pn37:nAt,8],;
						aCabeca[oLB01Pn37:nAt,9],;
						aCabeca[oLB01Pn37:nAt,10],;
						aCabeca[oLB01Pn37:nAt,11],;
						aCabeca[oLB01Pn37:nAt,12],;
						aCabeca[oLB01Pn37:nAt,13],;
						aCabeca[oLB01Pn37:nAt,14],;
						aCabeca[oLB01Pn37:nAt,15],;
						aCabeca[oLB01Pn37:nAt,16],;
						aCabeca[oLB01Pn37:nAt,17],;
						aCabeca[oLB01Pn37:nAt,18]}}
oLB01Pn37:nAt := 1
oLB01Pn37:Default()
oLB01Pn37:bChange := {||   If((lSE1Exc .AND. cFilAnt <> Eval(oLB01Pn37:bLine)[1]),(cFilAnt := Eval(oLB01Pn37:bLine)[1]),.T.),;
							nRec := TKC010Brow( "SE1", "E", Eval(oLB01Pn37:bLine)[2] + Eval(oLB01Pn37:bLine)[3] + Eval(oLB01Pn37:bLine)[4] ),;
							oEnchoice:Refresh(),;
							cFilAnt := cFilAtu	}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um Enchoice tipo MsMGet Read Only do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )
oEnchoice := MsMGet():New("SE1",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn37:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn36  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Posicao Financeira         º±±
±±º          ³A montagem deste panel e realizada pelo mesmo codigo utiliza- º±±
±±º          ³do pela rotina do financeiro, de onde foi extraido.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn36(oExplorer, nPanel, aEmpCont)

Local aArea     := GetArea()				// Salva a area atual
Local aParam    := {}						// Parametro da funcao Fc010Brow
Local aAlias	:= {}						// Alias utilizado na consulta
Local cCgc		:= RetTitle("A1_CGC")		// Titulo do CGC/CNPJ
Local cMoeda    := ""						// Descricao da Moeda 
Local nMcusto   := 0						// Custo
Local aCols     :={}						// Conteudo da Getdados
Local aHeader   :={}						// Cabecalho da Getdados
Local cSalFin	:= STR0075					// "Saldo Sec."
Local cLcFin	:= STR0076					// "Lim.Cred.Sec."
Local aGet      := {"","","",""}			// Parametro da funcao Fc010Brow
Local lFc010Con								// Flag
Local oLbx									// Listbox
Local oGetNome		:= Nil
Local oGetCGC		:= Nil 
Local oGetTel		:= Nil  
Local oGetChqDev	:= Nil
Local oGetTitP		:= Nil

Private nCasas := SuperGetMV("MV_CENT")			//Conteudo do paramentro
Private Inclui := .F.						//Se inclui registro
Private Altera := .F.						//Se altera registro

If SA1->A1_MOEDALC > 0
	nMcusto  :=  SA1->A1_MOEDALC
Else
	nMcusto  :=  Val(SuperGetMV("MV_MCUSTO"))         
Endif	

DbSelectarea("SX3")
DbSetOrder(2)
If DbSeek("A1_LCFIN")
	cLcFin := X3Titulo()
Endif
	
If DbSeek("A1_SALFIN")
	cSalFin   := X3Titulo()
Endif

cMoeda := " "+Pad(SuperGetMV("MV_SIMB"+ALLTRIM(STR(nMCusto))),4)

If lFc010Con == NIL
	lFc010Con := ExistBlock("FC010CON")
Endif

Pergunte("FIC010",.F.)
If Mv_Par01 == NIL .OR. Empty(Mv_Par01)
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0112,; //"	01} SX1 - Não existem perguntas no arquivo SX1 para o grupo de consulta do financeiro"
									STR0113,; //"	02} SX1 - As respostas do arquivo SX1 podem estar vazias"
									"",;
									STR0114,; //"Solução"
									"",;
									STR0115,; //"	01.01} Realiza a consulta de posição de clientes primeiro pelo módulo de financeiro."
									STR0116,; //"	01.02} Após sua realização, o grupo de perguntas do módulo financeiro será criado."
									STR0117,; //"	01.03} Utilize normalmente a consulta pelo call center."
									STR0118; //"	02.01} Responda as perguntas no SX1 clicando no botão de parametros do financeiro na tela inicial."
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³[01] Data de Emissao Inicial                       ³
//³[02] Data de Emissao Final                         ³
//³[03] Vencimento Inicial                            ³
//³[04] Vencimento Final                              ³
//³[05] Considera Provisorios (1) Sim (2) Nao         ³
//³[06] Prefixo Inicial                               ³
//³[07] Prefixo Final                                 ³
//³[08] Considera Faturados 	 					  ³
//³[09] Considera Liquidados                          ³
//³[10] Pedidos c/Itens Bloqueados                    ³
//³[11] Tit. Ger. pela Liquidatpo                     ³
//³[12] Considera Saldo                               ³
//³[13] Considera Lojas                               ³
//³[14] TEF Gera Duplicata                            ³
//|[15] Se considera RA								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AAdd(aParam,MV_PAR01)
AAdd(aParam,MV_PAR02)
AAdd(aParam,MV_PAR03)
AAdd(aParam,MV_PAR04)
AAdd(aParam,MV_PAR05)
AAdd(aParam,MV_PAR06)
AAdd(aParam,MV_PAR07)
AAdd(aParam,MV_PAR08)
AAdd(aParam,MV_PAR09)
AAdd(aParam,MV_PAR10)
AAdd(aParam,MV_PAR11)
AAdd(aParam,MV_PAR12)
AAdd(aParam,MV_PAR13)
AAdd(aParam,MV_PAR14)
AAdd(aParam,MV_PAR15)

If !VerSenha(104) //Permite consulta a Posicao de Cliente
	TKC010SD(oExplorer, nPanel, {	STR0119,; //"Para que as informações deste folder sejam mostradas, são necessárias as permissões abaixo:"
									"",;
									STR0120; //"	01} Usuário não tem acesso para utilizar esta consulta."
									})
	Return(Nil)
Endif

If aEmpCont[9][3] <> "SA1"
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0121,; //"	01} SA1, Cadastro de clientes, portanto é impossível realizar esta consulta com outro tipo de empresa."
									STR0122; //"	01} SA1, Na escolha das empresas dos contatos selecione um cliente."
									})

	Return(Nil)
Endif

aHeader	:= {STR0077,STR0078,STR0069+ALLTRIM(cMoeda)," ",STR0077,STR0005}  

AAdd(aCols,{STR0014,;												//LIMITE DE CREDITO
			Transform(xMoeda(SA1->A1_LC, nMcusto, 1,dDataBase),;
			PesqPict("SA1","A1_LC",14,1)),;
			Transform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,nMCusto)),;
            " ",;
            STR0015,;
            SPACE(07)+DtoC(SA1->A1_PRICOM)})						//PRIMEIRA COMPRA
            
AAdd(aCols,{STR0010,;												//SALDO
			Transform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1) ),;
            Transform(SA1->A1_SALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto)),;
			" ",;
			STR0016,;												//ULTIMA COMPRA
			SPACE(07)+DtoC(SA1->A1_ULTCOM)})

AAdd(aCols,{cLcFin,;
			Transform(xMoeda(SA1->A1_LCFIN,nMcusto,1,dDatabase,MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),;     
            Transform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto)),;
            " ",;	
            STR0017,;												// Limite de credito secundario 
            Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14))}) 	// Maior Atraso    


AAdd(aCols,{cSalFin,;
			Transform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1)),;
           	Transform(SA1->A1_SALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto)),;
           	" ",;
           	STR0018,;                                               // Saldo em Cheque
           	Transform(SA1->A1_METR,PesqPict("SA1","A1_METR",14))}) 	// Media de Atraso


AAdd(aCols,{STR0011,;
			Transform(xMoeda(SA1->A1_MCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1) ),PesqPict("SA1","A1_MCOMPRA",14,1) ) ,;
			Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto)),;
            " ",;
            STR0019,;												// Maior Compra
            SPACE(25)+SA1->A1_RISCO}) 								// Grau de Risco
            
//MAior Saldo
AAdd(aCols,{STR0012,;												// Maior saldo
			Transform(xMoeda(SA1->A1_MSALDO, nMcusto ,1, dDataBase,MsDecimais(1) ),PesqPict("SA1","A1_MSALDO",14,1)),;
            Transform(SA1->A1_MSALDO,PesqPict("SA1","A1_MSALDO",14,nMcusto)),;
            " ",;
            " ",;
            ""}) 
 

@ 001,002 TO 043, 295 OF oExplorer:GetPanel(nPanel)	PIXEL

@ 004,005 SAY STR0006 SIZE 025,07          OF oExplorer:GetPanel(nPanel) PIXEL //"Codigo"
@ 012,004 MSGET SA1->A1_COD      SIZE 070,09 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL

@ 004,077 SAY STR0007 SIZE 020,07          OF oExplorer:GetPanel(nPanel) PIXEL //"Loja"
@ 012,077 MSGET SA1->A1_LOJA     SIZE 021,09 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL

@ 004,100 SAY STR0008 SIZE 025,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Nome"
@ 012,100 MSGET oGetNome VAR SA1->A1_NOME     SIZE 170,09 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL
If FATPDActive() .And. FTPDUse(.T.)
	oGetNome:lObfuscate := FATPDIsObfuscate("A1_NOME")
Endif

@ 023,005 SAY cCGC    SIZE 025,07 OF oExplorer:GetPanel(nPanel) PIXEL
@ 030,004 MSGET oGetCGC VAR SA1->A1_CGC SIZE 070,09 PICTURE PesqPict("SA1","A1_CGC") WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL
If FATPDActive() .And. FTPDUse(.T.)
	oGetCGC:lObfuscate := FATPDIsObfuscate("A1_CGC")
Endif

@ 023,077 SAY STR0009 SIZE 025,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Telefone"
@ 030,077 MSGET oGetTel VAR SA1->A1_TEL      SIZE 060,09 PICTURE PesqPict("SA1","A1_TEL") WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL
If FATPDActive() .And. FTPDUse(.T.)
	oGetTel:lObfuscate := FATPDIsObfuscate("A1_TEL")
Endif

@ 023,141 SAY RetTitle("A1_VENCLC")  SIZE 035,07 OF oExplorer:GetPanel(nPanel) PIXEL
@ 030,141 MSGET SA1->A1_VENCLC       SIZE 060,09 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL

@ 023,206 SAY STR0057 SIZE 035,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Vendedor"
@ 030,206 MSGET SA1->A1_VEND  	 SIZE 085,09 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL

oLbx := TWBrowse():New( 3.5, .42, 292, 70,,aHeader,{38,51,51,11,50,63},oExplorer:GetPanel(nPanel),,,,,,,,,,,, .F.,, .F.,, .F.,,, )
oLbx:SetArray(aCols)
oLbx:bLine:={ || RDbLine(oLbx,aCols,aHeader) }

@ 124,002 SAY STR0020 SIZE 061,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Cheques Devolvidos"
@ 124,121 SAY STR0021 SIZE 061,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Titulos Protestados"

@ 130,002 TO 154, 114 OF oExplorer:GetPanel(nPanel)	PIXEL

@ 133,005 SAY STR0022 SIZE 034,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Quantidade"
@ 133,045 SAY STR0023 SIZE 066,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Ultimo Devolvido"

@ 130,121 TO 154, 295 OF oExplorer:GetPanel(nPanel)	PIXEL

@ 133,126 SAY STR0022 SIZE 034,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Quantidade"
@ 133,163 SAY STR0024 SIZE 076,07 OF oExplorer:GetPanel(nPanel) PIXEL //"Ultimo Protesto"

@ 141,006 MSGET oGetChqDev VAR SA1->A1_CHQDEVO  SIZE 024,08 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL
If FATPDActive() .And. FTPDUse(.T.)
	oGetChqDev:lObfuscate := FATPDIsObfuscate("A1_CHQDEVO")
Endif

@ 141,045 MSGET SA1->A1_DTULCHQ  SIZE 050,08 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL

@ 141,126 MSGET oGetTitP VAR SA1->A1_TITPROT  SIZE 024,08 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL
If FATPDActive() .And. FTPDUse(.T.)
	oGetTitP:lObfuscate := FATPDIsObfuscate("A1_TITPROT") 
Endif

@ 141,163 MSGET SA1->A1_DTULTIT  SIZE 050,08 WHEN .F. OF oExplorer:GetPanel(nPanel) PIXEL  

// Titulos em aberto
@ 155,002	BUTTON STR0025 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
			ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
						Inclui := .F.,;
						Altera := .F.,;
						SA1->( DbSelectArea("SA1") ),;
						SA1->( DbSetOrder(1) ),;
						SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
						Fc010Brow(1,@aAlias,aParam,.T.,aGet) )

// Titulos Recebidos
@ 155,039	BUTTON STR0026 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL ;
			ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
						Inclui := .F.,;
						Altera := .F.,;
						SA1->( DbSelectArea("SA1") ),;
						SA1->( DbSetOrder(1) ),;
						SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
						FC010Brow(2,@aAlias,aParam,.T.,aGet) )

// Pedidos de venda
@ 155,076	BUTTON STR0027 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
			ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
						Inclui := .F.,;
						Altera := .F.,;
						SA1->( DbSelectArea("SA1") ),;
						SA1->( DbSetOrder(1) ),;
						SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
						Fc010Brow(3,@aAlias,aParam,.T.,aGet) )

// Faturamento, Notas fiscais emitidas
@ 155,113	BUTTON STR0028 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
			ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
						Inclui := .F.,;
						Altera := .F.,;
						SA1->( DbSelectArea("SA1") ),;
						SA1->( DbSetOrder(1) ),;
						SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
						Fc010Brow(4,@aAlias,aParam,.T.,aGet) )

If ( cPaisLoc<>"BRA" )
	//"Cheques/Trans"
	@ 155,150	BUTTON STR0029 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
				ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
							Inclui := .F.,;
							Altera := .F.,;
							SA1->( DbSelectArea("SA1") ),;
							SA1->( DbSetOrder(1) ),;
							SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
							Fc010Brow(5,@aAlias,aParam,.T.,aGet);
							)
Endif

If ( lFC010Con )
	//"Cons.Especif."
	@ 155,187	BUTTON STR0030 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
				ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
							Inclui := .F.,;
							Altera := .F.,;
							SA1->( DbSelectArea("SA1") ),;
							SA1->( DbSetOrder(1) ),;
							SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
							ExecBlock("FC010CON",.F.,.F.) )
Endif

If Trim(SuperGetMV("MV_VEICULO")) == "S"
	//"OSs Abertas"
	@ 155,224	BUTTON STR0123 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL; //"OSs Abertas"
				ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
							Inclui := .F.,;
							Altera := .F.,;
							SA1->( DbSelectArea("SA1") ),;
							SA1->( DbSetOrder(1) ),;
							SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
							FG_SALOSV(SA1->A1_COD,SA1->A1_LOJA,," ","T") )
Endif   

If Select("SAO") # 0
	//"Referencias"
	@ 155,261	BUTTON STR0059 SIZE 35,12 OF oExplorer:GetPanel(nPanel) PIXEL;
				ACTION	(	nCasas := SuperGetMV("MV_CENT"),;
							Inclui := .F.,;
							Altera := .F.,;
							SA1->( DbSelectArea("SA1") ),;
							SA1->( DbSetOrder(1) ),;
							SA1->( DbSeek(xFilial("SA1") + aEmpCont[10][3])),;
							Mata030Ref("SA1",SA1->(Recno()),2) 	)
Endif

aEval(aAlias,{|x| (x[1])->(DbCloseArea()),Ferase(x[2]+GetDbExtension()),Ferase(x[2]+OrDbagExt())})
DbSelectArea("SA1")
RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn37  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Marketing                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn37(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()                                        // Salva a area atual
Local nTop      := 5												// Coordenadas da tela
Local nLeft     := 5
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .92) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oGraphic                                                      // Grafico                       	
Local nSerie        												// Series dos graficos
Local aSerie    := {}												// Array com as series
Local nI		:= 0 												// Contador auxiliar
Local nLenAux	:= 0												// Contador auxiliar para o FOR

Pergunte(cPerg,.F.)	// Posiciona nas perguntas

If Empty(Mv_Par07)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0124,; //"Falta definir o parametro para o tipo de gráfico deste painel de informacoes."
									STR0125,; //"Os Tipos de Gráficos disponiveis sao:"
									STR0126,; //"	01) GRP_LINE		Codigo GRF01"
									STR0127,; //"	02) GRP_AREA		Codigo GRF02"
									STR0128,; //"	03) GRP_POINT		Codigo GRF03"
									STR0129,; //"	04) GRP_BAR			Codigo GRF04"
									STR0135,; //"	10) GRP_PIE			Codigo GRF10"
									})
	Return(Nil)
Endif

nSerie := Val( Mv_Par07)

AAdd(aSerie, {nSerie, 0, STR0141, 65280		} )		// CLR_HGREEN 	//"Listas"
AAdd(aSerie, {nSerie, 0, STR0142, 16711680	} )		// CLR_HBLUE 	//"Voz"
AAdd(aSerie, {nSerie, 0, STR0143, 16711935	} )		// CLR_HMAGENTA //"Fax"
AAdd(aSerie, {nSerie, 0, STR0144, 12632256	} )		// CLR_HGRAY 	//"Cross"
AAdd(aSerie, {nSerie, 0, STR0145, 65535		} )		// CLR_YELLOW 	//"Mala"
AAdd(aSerie, {nSerie, 0, STR0146, 255		} )		// CLR_HRED 	//"Pendencia"
AAdd(aSerie, {nSerie, 0, STR0147, 16777215	} )		// CLR_WHITE 	//"Web Site"

aSerie := TKC010VP39(aSerie, aEmpCont)		// Busca os valores para as series do grafico

TkC010Grap(@oGraphic,nLeft,nTop,nRight,nBottom,oExplorer:GetPanel(nPanel),aSerie,CONTROL_ALIGN_BOTTOM)

RestArea(aArea)

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn38  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Contato                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn38(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()                                                // Salva a area atual
Local nTop      := 05														// Coordenadas da tela SUPERIOR
Local nLeft     := 05														// Coordenadas da tela ESQUERDA
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)		// Coordenadas da tela ABAIXO
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)			// Coordenadas da tela DIREITA	
Local oLB01Pn40																// Listbox da Lista de Contatos - SU4
Local aCabeca   := {}														// Array com os registros do SU4 - Cabecalho da lista de contatos
Local oGetDados																// Getdados dos itens da Lista - SU6
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSU4Exc	:= (X2ModAcess("SU4") == "E")							// Indica se o SUD esta como exclusivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o aHeader e o aCols para garantir a integridade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}    
aCols 	:= {}

aCabeca := TKCListBox("SU4", aEmpCont, nPanel)
If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0148,; //"	01} SU4 - Cabeçalho da lista de contatos"
									STR0149,; //"	02) SU6 - Itens da lista de contatos"
									STR0167;  //"	03) SU8 - Resultado da lista de contatos"
									})
	Return(Nil)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³o array aALLHEADER contem os header acumulados se a tabela desejada estiver contida o aHeader e atualizado por copia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSU4Exc .AND. cFilAnt <> aCabeca[1][18]
		cFilAnt := aCabeca[1][18]
	EndIf

	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SU6"})
	If nPosHeader > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimenta o aHeader com a tabela SU6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "SU6", aCabeca[1][1], "" )		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "SU6", aCabeca[1][1], "" )
		AAdd(aAllHeader, {"SU6", aHeader})
	Endif
	
	cFilAnt := cFilAtu
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft 	ListBox oLB01Pn40 Fields;
				Header	STR0246,; // 01 -  Filial
						STR0150,; // 02 -  Lista 
						STR0077,; // 03 -  Descricao 
						STR0151,; // 04 -  Data 
						STR0152,; // 05 -  Tp.Lista 
						STR0153,; // 06 -  Tp.Contato 
						STR0154,; // 07 -  Operador 
						STR0008,; // 08 -  Nome 
						STR0155,; // 09 -  Configuracao 
						STR0009,; // 10 -  Telefone 
						STR0156,; // 11 -  Endereco 
						STR0157,; // 12 -  Arq. Mala Direta 
						STR0158,; // 13 -  Etiqueta 
						STR0159,; // 14 -  Arq. Etiqueta 
						STR0160,; // 15 -  Campanha 
						STR0161,; // 16 -  Script 
						STR0162,; // 17 -  Evento 
						STR0163;  // 18 -  Assunto 
				Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn40:Cargo := "MARKETING"
oLB01Pn40:SetArray(aCabeca)
oLB01Pn40:bLine:={||{	aCabeca[oLB01Pn40:nAt,18],;
						aCabeca[oLB01Pn40:nAt,1],;
						aCabeca[oLB01Pn40:nAt,2],;
						aCabeca[oLB01Pn40:nAt,3],;
						aCabeca[oLB01Pn40:nAt,4],;
						aCabeca[oLB01Pn40:nAt,5],;
						aCabeca[oLB01Pn40:nAt,6],;
						aCabeca[oLB01Pn40:nAt,7],;
						aCabeca[oLB01Pn40:nAt,8],;
						aCabeca[oLB01Pn40:nAt,9],;
 						aCabeca[oLB01Pn40:nAt,10],;
 						aCabeca[oLB01Pn40:nAt,11],;
 						aCabeca[oLB01Pn40:nAt,12],;
 						aCabeca[oLB01Pn40:nAt,13],;
 						aCabeca[oLB01Pn40:nAt,14],;
 						aCabeca[oLB01Pn40:nAt,15],;
 						aCabeca[oLB01Pn40:nAt,16],;
 						aCabeca[oLB01Pn40:nAt,17]	} }
oLB01Pn40:nAt := 1
oLB01Pn40:Default()
oLB01Pn40:bChange := {||If((lSU4Exc .AND. cFilAnt <> Eval(oLB01Pn40:bLine)[1]),(cFilAnt := Eval(oLB01Pn40:bLine)[1]),.T.),;
						TkMontaItens( "SU6", Eval(oLB01Pn40:bLine)[2], "" ),;
						oGetDados:oBrowse:Refresh(),;
						cFilAnt := cFilAtu }

If Type("aDados") == "A"						
	aDados[6] := aCabeca
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n := 1 // Garante posicionamento na primeira linha
oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn40:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn39  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Lista de contato           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn39(oExplorer, nPanel, aEmpCont)

Local aArea     := GetArea()											// Salva a area atual
Local nTop      := 5													// Coordenadas de tela - TOPO
Local nLeft     := 5											 		// Coordenadas de tela - ESQUERDO	
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)    // Coordenadas de tela - ABAIXO
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98)  / 2)	// Coordenadas de tela - DIREITO
Local oFolder															// Folder de divisao das enchoices				
Local oLB01Pn41															// Listbox do Cabecalho da Lista de Contato - SU4
Local aCabeca   := {}													// Array com os registros do SU4
Local oGetDados															// GetDados com os itens da Lista de Contato - SU6
Local nRecSUO   := 0													// Posicao do registro da campanha associada ao SU4
Local oSUOEnch															// Enchoice da Campanha
Local aSUOCoord := {}													// Coordenadas da enchoice da Campanha
Local nRecACD   := 0													// Posicao do registro do evento associada ao SU4
Local oACDEnch															// Enchoice do Evento
Local aACDCoord := {}													// Coordenadas da enchoice do Evento
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSU4Exc	:= (X2ModAcess("SU4") == "E")							// Indica se o SUD esta como exclusivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o aHeader e o aCols para garantir a integridade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}    
aCols 	:= {}

aCabeca := TKCListBox("SU4", aEmpCont, nPanel)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0148,; //"	01} SU4 - Cabeçalho da lista de contatos"
									STR0149,; //"	02) SU6 - Itens da lista de contatos"
									STR0164,; //"	03) SUO - Cadastro de campanhas"
									STR0165; //"	04) ACD - Cadastro de eventos"
									})
	Return(Nil)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³o array aALLHEADER contem os header acumulados se a tabela desejada estiver contida o aHeader e atualizado por copia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSU4Exc .AND. cFilAnt <> aCabeca[1][18]
		cFilAnt := aCabeca[1][18]
	EndIf

	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SU6"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "SU6", aCabeca[1][1], "" )		
	Else            
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "SU6", aCabeca[1][1], "" )
		AAdd(aAllHeader, {"SU6", aHeader})
	Endif                                                                       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no registro da respectiva campanha (SUO) associada a Lista (SU4)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecSUO := TKC010Brow( "SUO", "E", aCabeca[1][1] )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no registro do respectiva evento (ACD) associado a Lista (SU4)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecACD := TKC010Brow( "ACD", "E", aCabeca[1][1] )

	cFilAnt := cFilAtu

Endif

//"Lista","Campanha e Evento"
oFolder := TFolder():New(nTop-5,nLeft-5,{STR0150,STR0166},{},oExplorer:GetPanel(nPanel),,,,.T.,.F.,nRight,nBottom) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft	ListBox oLB01Pn41 Fields;
				Header	STR0246,; // 01 - Filial
						STR0150,; // 02 - Lista 
						STR0077,; // 03 - Descricao 
						STR0151,; // 04 - Data 
						STR0152,; // 05 - Tp Lista 
						STR0153,; // 06 - Tp Contato 
						STR0154,; // 07 - Operador 
						STR0008,; // 08 - Nome 
						STR0155,; // 09 - Configuracao 
						STR0009,; // 10 - Telefone 
						STR0156,; // 11 - Endereco 
						STR0157,; // 12 - Arq. Mala Direta 
						STR0158,; // 13 - Etiqueta 
						STR0159,; // 14 - Arq. Etiqueta 
						STR0160,; // 15 - Campanha 
						STR0161,; // 16 - Script 
						STR0162,; // 17 - Evento 
						STR0163;  // 18 - Assunto 
				Size nRight-15,(nBottom*.47) NoScroll Of oFolder:aDialogs[1] Pixel

oLB01Pn41:SetArray(aCabeca)
oLB01Pn41:bLine:={||{	aCabeca[oLB01Pn41:nAt,18],;
						aCabeca[oLB01Pn41:nAt,1],;
						aCabeca[oLB01Pn41:nAt,2],;
						aCabeca[oLB01Pn41:nAt,3],;
						aCabeca[oLB01Pn41:nAt,4],;
						aCabeca[oLB01Pn41:nAt,5],;
						aCabeca[oLB01Pn41:nAt,6],;
						aCabeca[oLB01Pn41:nAt,7],;
						aCabeca[oLB01Pn41:nAt,8],;
						aCabeca[oLB01Pn41:nAt,9],;
 						aCabeca[oLB01Pn41:nAt,10],;
 						aCabeca[oLB01Pn41:nAt,11],;
 						aCabeca[oLB01Pn41:nAt,12],;
 						aCabeca[oLB01Pn41:nAt,13],;
 						aCabeca[oLB01Pn41:nAt,14],;
 						aCabeca[oLB01Pn41:nAt,15],;
 						aCabeca[oLB01Pn41:nAt,16],;
 						aCabeca[oLB01Pn41:nAt,17];
 						}}
oLB01Pn41:nAt := 1
oLB01Pn41:Default()
// Mudou a posicao do SU4 no Listbox apresenta os respectivos itens na Getdados do SU6
oLB01Pn41:bChange := {||	If((lSU4Exc .AND. cFilAnt <> Eval(oLB01Pn41:bLine)[1]),(cFilAnt := Eval(oLB01Pn41:bLine)[1]),.T.),;
							TkMontaItens( "SU6", Eval(oLB01Pn41:bLine)[2], "" ),;
							oGetDados:oBrowse:Refresh(),;
							nRecSUO := TKC010Brow( "SUO", "E", Eval(oLB01Pn41:bLine)[15] ),;
							oSUOEnch:Refresh(),;
							nRecACD := TKC010Brow( "ACD", "E", Eval(oLB01Pn41:bLine)[17] ),;
							oACDEnch:Refresh(),;
							cFilAnt := cFilAtu 	}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom*.5),nLeft,(nBottom*.93),nRight-10,2,"","","",.T.,,,.F.,,,,,,oFolder:aDialogs[1])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um Enchoice tipo MsMGet Read Only do cabecalho - Campanha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aSUOCoord, { nTop, nLeft, nBottom*.47, nRight-5 } )
oSUOEnch := MsMGet():New("SUO",nRecSUO,2,,,,,aSUOCoord[1],,3,,,,oFolder:aDialogs[2],,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um Enchoice tipo MsMGet Read Only do cabecalho - Eventos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aACDCoord, { nBottom*.5, nLeft, nBottom*.93, nRight-5 } )
oACDEnch := MsMGet():New("ACD",nRecACD,2,,,,,aACDCoord[1],,3,,,,oFolder:aDialogs[2],,,,,,.T.)

Eval(oLB01Pn41:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn40  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Resultado                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn40(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()											// Salva a area atual
Local nTop		:= 05													// Coordenadas da tela
Local nLeft		:= 05           										// Coordenada inicial ESQUERDA
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Coordenada inicial ABAIXO	
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98)  / 2)	// Coordenada inicial DIREITA
Local oLB01Pn42															// Listbox do Cabecalho da Lista de Contato - SU4
Local aCabeca	:= {}													// Array com os registros do SU4
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSU4Exc	:= (X2ModAcess("SU4") == "E")							// Indica se o SUD esta como exclusivo

Local oLB02Pn42															// Listbox dos itens da Lista de Contato- SU6
Local aItens    := {}													// Array com os registros do SU6

Local oLB03Pn42															// Listbox dos itens de Historico da lista de contatos - SU8
Local aItensSU8	:= {}													// Array com os registros do SU8

Local aHeadNew	:= {}													// aHead auxiliar
Local aColsNew	:= {}													// aCols auxilar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o aHeader e o aCols para garantir a integridade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader	:= {}
aCols		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os registros da Lista de Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabeca := TKCListBox("SU4", aEmpCont, nPanel,,P_CONT_RESULTADO)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0148,; //"	01} SU4 - Cabeçalho da lista de contatos"
									STR0149,; //"	02) SU6 - Itens da lista de contatos"
									STR0167}) //"	03) SU8 - Resultado da lista de contatos"
	Return(Nil)
Else
	If lSU4Exc .AND. cFilAnt <> aCabeca[1][18]
		cFilAnt := aCabeca[1][18]
	EndIf   
	
	aItens := TKCListBox("SU6", aEmpCont, nPanel, aCabeca[1][1],P_CONT_RESULTADO) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³o array aALLHEADER contem os header acumulados se a tabela desejada estiver contida o aHeader e atualizado por copia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SU8"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "SU8", aCabeca[1][1], "" )		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "SU8", aCabeca[1][1], "" )		
		AAdd(aAllHeader, {"SU8", aHeader})
		aHeadNew := aClone(aHeader)
	Endif

	aColsNew := aClone(aCols)
	
	cFilAnt := cFilAtu	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho - Lista de Contatos - SU4 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft ListBox oLB01Pn42 Fields;
				Header	STR0246,; // 01 - Filial
						STR0150,; // 02 - Lista 
						STR0077,; // 03 - Descricao 
						STR0151,; // 04 - Data 
						STR0152,; // 05 - Tp Lista 
						STR0153,; // 06 - Tp Contato 
						STR0154,; // 07 - Operador 
						STR0008,; // 08 - Nome 
						STR0155,; // 09 - Configuracao 
						STR0009,; // 10 - Telefone 
						STR0156,; // 11 - Endereco 
						STR0157,; // 12 - Arq. Mala Direta 
						STR0158,; // 13 - Etiqueta 
						STR0159,; // 14 - Arq. Etiqueta 
						STR0160,; // 15 - Campanha 
						STR0161,; // 16 - Script 
						STR0162,; // 17 - Evento 
						STR0163;  // 18 - Assunto 
				Size nRight,(nBottom*.3) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
oLB01Pn42:SetArray(aCabeca)
oLB01Pn42:bLine:={||{	aCabeca[oLB01Pn42:nAt,18],; // 01
						aCabeca[oLB01Pn42:nAt,1],; // 02 
						aCabeca[oLB01Pn42:nAt,2],;	// 03 
						aCabeca[oLB01Pn42:nAt,3],;	// 04 
						aCabeca[oLB01Pn42:nAt,4],;	// 05 
						aCabeca[oLB01Pn42:nAt,5],;	// 06 
						aCabeca[oLB01Pn42:nAt,6],;	// 07 
						aCabeca[oLB01Pn42:nAt,7],;	// 08 
						aCabeca[oLB01Pn42:nAt,8],;	// 09 
						aCabeca[oLB01Pn42:nAt,9],;	// 10 
 						aCabeca[oLB01Pn42:nAt,10],;	// 11 
 						aCabeca[oLB01Pn42:nAt,11],;	// 12 
 						aCabeca[oLB01Pn42:nAt,12],;	// 13 
 						aCabeca[oLB01Pn42:nAt,13],;	// 14 
 						aCabeca[oLB01Pn42:nAt,14],;	// 15 
 						aCabeca[oLB01Pn42:nAt,15],;	// 16 
 						aCabeca[oLB01Pn42:nAt,16],;	// 17 
 						aCabeca[oLB01Pn42:nAt,17];	// 18 
 						} }
oLB01Pn42:nAt := 1
oLB01Pn42:Default()
oLB01Pn42:bChange := {||If((lSU4Exc .AND. cFilAnt <> Eval(oLB02Pn42:bLine)[1]),(cFilAnt := Eval(oLB02Pn42:bLine)[1]),.T.),; 
						aItens := TKCListBox("SU6", aEmpCont, nPanel, { Eval(oLB01Pn42:bLine)[2] },P_CONT_RESULTADO),;
						oLB02Pn42:SetArray(aItens),;
						oLB02Pn42:bLine:={||{	aItens[oLB02Pn42:nAt,1],;	 // 01 - Codigo
												aItens[oLB02Pn42:nAt,2],;    // 02 - Entidade
												aItens[oLB02Pn42:nAt,3],;    // 03 - Nome
												aItens[oLB02Pn42:nAt,4],;    //	04 - Origem
												aItens[oLB02Pn42:nAt,5],;    //	05 - Contato
												aItens[oLB02Pn42:nAt,6],;    //	06 - Nome
												aItens[oLB02Pn42:nAt,7],;    //	07 - Data
												aItens[oLB02Pn42:nAt,8],;    //	08 - Inicio
												aItens[oLB02Pn42:nAt,9],;    //	09 - Fim
						 						aItens[oLB02Pn42:nAt,10]}},; // 10 - Status
						oLB02Pn42:nAt := 1,;
						oLB02Pn42:Refresh(),;
						aItensSU8 := TKCListBox("SU8", aEmpCont, nPanel, { Eval(oLB01Pn42:bLine)[2] } ,P_CONT_RESULTADO),;
						oLB03Pn42:SetArray(aItensSU8),;
						oLB03Pn42:bLine:={||{	aItensSU8[oLB03Pn42:nAt,1],;
												aItensSU8[oLB03Pn42:nAt,2],;
												aItensSU8[oLB03Pn42:nAt,3],;
												aItensSU8[oLB03Pn42:nAt,4],;
												aItensSU8[oLB03Pn42:nAt,5],;
						 						aItensSU8[oLB03Pn42:nAt,6]} },;
						oLB03Pn42:nAt := 1,;
						oLB03Pn42:Refresh(),;
						cFilAnt := cFilAtu }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox dos Itens da - Lista de Contatos - SU6 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.33),nLeft ListBox oLB02Pn42 Fields;
						Header	STR0006,; // 01 - Codigo
								STR0169,; // 02 - Entidade
								STR0008,; // 03 - Nome
								STR0170,; // 04 - Origem
								STR0171,; // 05 - Contato
								STR0008,; // 06 - Nome
								STR0151,; // 07 - Data
								STR0172,; // 08 - Inicio
								STR0173,; // 09 - Fim
								STR0045;  // 10 - Status
						Size nRight,(nBottom*.3) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
oLB02Pn42:SetArray(aItens)
oLB02Pn42:bLine:={||{	aItens[oLB02Pn42:nAt,1],;		
						aItens[oLB02Pn42:nAt,2],;
						aItens[oLB02Pn42:nAt,3],;
						aItens[oLB02Pn42:nAt,4],;
						aItens[oLB02Pn42:nAt,5],;
						aItens[oLB02Pn42:nAt,6],;
						aItens[oLB02Pn42:nAt,7],;
						aItens[oLB02Pn42:nAt,8],;
						aItens[oLB02Pn42:nAt,9],;
 						aItens[oLB02Pn42:nAt,10] }	}
oLB02Pn42:nAt := 1
oLB02Pn42:Default()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Resulatado das tentativas de ligacao - SU8 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ (nBottom*.66),nLeft 	ListBox oLB03Pn42 Fields;
					Header	STR0150,; // 01 - Lista
							STR0192,; // 02 - Item Lista 
							STR0151,; // 03 - Data
							STR0193,; // 04 - Hora
							STR0194,; // 05 - Ocorrencia
							STR0045;  // 06 - Status
					Size nRight,(nBottom*.3) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
oLB03Pn42:SetArray(aItensSU8)
If LEN(aItensSU8) == 0
   AAdd(aItensSU8,{ "",; 		// 01 - Lista
					"",; 		// 02 - Item Lista
					STOD(""),; 	// 03 - Data
					"",; 		// 04 - Hora  
					"",; 		// 05 - Ocorrencia
					""}) 		// 06 - Status
Endif
oLB03Pn42:bLine:={||{	aItensSU8[oLB03Pn42:nAt,1],;
						aItensSU8[oLB03Pn42:nAt,2],;
						aItensSU8[oLB03Pn42:nAt,3],;
						aItensSU8[oLB03Pn42:nAt,4],;
						aItensSU8[oLB03Pn42:nAt,5],;
 						aItensSU8[oLB03Pn42:nAt,6]} }
oLB03Pn42:nAt := 1
oLB03Pn42:Default()

Eval(oLB01Pn42:bChange)

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn41  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Field Service              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn41(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()											// Salva a area atual
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oGraphic                                                      	// Grafico	
Local nSerie															// Contador de series
Local aSerie   	:= {}													// Array com as series
Local nI		:= 0 													// Contador auxiliar
Local nLenAux 	:= 0													// Contador auxiliar para o FOR

Pergunte(cPerg,.F.)	// Posiciona nas perguntas

If Empty(Mv_Par08)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0124,; //"Falta definir o parametro para o tipo de gráfico deste painel de informações."
									STR0125,; //"Os Tipos de Gráficos disponíveis são:"
									STR0126,; //"	01) GRP_LINE		Codigo GRF01"
									STR0127,; //"	02) GRP_AREA		Codigo GRF02"
									STR0128,; //"	03) GRP_POINT		Codigo GRF03"
									STR0129,; //"	04) GRP_BAR			Codigo GRF04"
									STR0135,; //"	10) GRP_PIE			Codigo GRF10"
									})
	Return(Nil)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Substituir este set pela variavel nSerie ao adicionar o aSerie³
//³para criar varias series.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSerie := Val( Mv_Par08 )

AAdd(aSerie, {nSerie, 0, STR0174, 65280		} )		// CLR_HGREEN 	//"Chamados"
AAdd(aSerie, {nSerie, 0, STR0175, 16711680	} )		// CLR_HBLUE 	//"Outr. Cont."
AAdd(aSerie, {nSerie, 0, STR0171, 16711935	} )		// CLR_HMAGENTA //"Contato"
AAdd(aSerie, {nSerie, 0, STR0062, 12632256	} )		// CLR_HGRAY 	//"Pendente"
AAdd(aSerie, {nSerie, 0, STR0176, 65535		} )		// CLR_YELLOW 	//"Encerrado"
AAdd(aSerie, {nSerie, 0, STR0177, 255		} )		// CLR_HRED 	//"Cliente"

aSerie := TKC010VP43(aSerie, aEmpCont)			// Carrega os valores para as series

TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .70),oExplorer:GetPanel(nPanel),aSerie,CONTROL_ALIGN_BOTTOM)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria um quadro de legenda detalhada dos valores que montam a serie³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ (nBottom * .73),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .75),05 BitMap oBmp1 ResName "BR_VERDE" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .75),15,{|| STR0178 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total geral de chamados técnicos do cliente escolhido"

@ (nBottom * .79),05 BitMap oBmp2 ResName "BR_AZUL" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .79),15,{|| STR0179 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total de chamados técnicos do cliente realizados por outros contatos"

@ (nBottom * .83),05 BitMap oBmp1 ResName "BR_PINK" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .83),15,{|| STR0180 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total de chamados técnicos realizados ao clinte pelo contatos selecionado"

@ (nBottom * .87),05 BitMap oBmp1 ResName "BR_CINZA" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .87),15,{|| STR0181 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total de chamados técnicos realizados pelo contato selecionado, em aberto"

@ (nBottom * .91),05 BitMap oBmp1 ResName "BR_AMARELO" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .91),15,{|| STR0182 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total de chamados técnicos realizados pelo contato selecionado, encerados"

@ (nBottom * .95),05 BitMap oBmp1 ResName "BR_VERMELHO" OF oExplorer:GetPanel(nPanel) Size 7,7 NoBorder When .F. Pixel
TSay():New((nBottom * .95),15,{|| STR0183 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Total de chamados técnicos realizados diretamente pelo field service"

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn42  ºAutor  ³Vendas Cliente      º Data ³  12/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel de Ordem de Servico.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TKC010Pn42(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn45															// Listbox do Cabecalho - AB1
Local aCabeca   := {}													// Array com os registros do AB1 - Cabecalho dos chamados tecnicos
Local oGetDados                                                         // MsGetDados com os itens do chamado tecnico - AB2
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lAB1Exc	:= (X2ModAcess("AB1") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("AB1", aEmpCont, nPanel)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informacoes deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0184,; //"	01} AB1 - Cabeçalho do chamado tecnico"
									STR0185; //"	02) AB2 - Itens do chamado tecnico"
									})
	Return(Nil)
Else

	If lAB1Exc .AND. cFilAnt <> aCabeca[1][10]
		cFilAnt := aCabeca[1][10]
	EndIf   
	
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "AB2"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "AB2", aCabeca[1][1], "" )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "AB2", aCabeca[1][1], "" )
		AAdd(aAllHeader, {"AB2", aHeader})
	Endif

	cFilAnt := cFilAtu
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft ListBox oLB01Pn45 Fields;
				Header	STR0246,; // 01 - Filial
						STR0186,; // 02 - Chamado 
						STR0103,; // 03 - Emissao 
						STR0187,; // 04 - Hora Ini 
						STR0188,; // 05 - Hora Fim 
						STR0171,; // 06 - Contato 
						STR0189,; // 07 - Atendente 
						STR0045,; // 08 - Status 
						STR0190,; // 09 - Ok 
						STR0191;  // 10 - Regiao
				Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn45:Cargo := "FIELDSERVICE"
oLB01Pn45:SetArray(aCabeca)
oLB01Pn45:bLine:={||{	aCabeca[oLB01Pn45:nAt,10],;
						aCabeca[oLB01Pn45:nAt,1],;
						aCabeca[oLB01Pn45:nAt,2],;
						aCabeca[oLB01Pn45:nAt,3],;
						aCabeca[oLB01Pn45:nAt,4],;
						aCabeca[oLB01Pn45:nAt,5],;
						aCabeca[oLB01Pn45:nAt,6],;
						aCabeca[oLB01Pn45:nAt,7],;
						aCabeca[oLB01Pn45:nAt,8],;
						aCabeca[oLB01Pn45:nAt,9] }}
oLB01Pn45:nAt := 1
oLB01Pn45:Default()

oLB01Pn45:bChange := {||	If((lAB1Exc .AND. cFilAnt <> Eval(oLB01Pn45:bLine)[1]),(cFilAnt := Eval(oLB01Pn45:bLine)[1]),.T.),; 
							nPosHeader := Ascan(aAllHeader, {|x| x[1] == "AB2"}),;
							aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "AB2"})][2])),;
							TkMontaItens( "AB2", Eval(oLB01Pn45:bLine)[2], "" ),;
							Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
							cFilAnt := cFilAtu }

If Type("aDados") == "A"						
	aDados[7] := aCabeca
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn45:bChange)

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn43ºAutor  ³Vendas CRM          º Data ³  29/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o painel com graficos das vendas do cliente           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn43(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 5													// Coordenadas de tela
Local nLeft     := 5
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .92) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oGraphic
Local nSerie
Local nI		:= 0 
Local nMax		:= 0
Private aSerie    := {}

Pergunte(cPerg,.F.)		// Posiciona do grupo de perguntas

If Empty(MV_PAR09)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O departamento de tecnologia alterou a classe de grafico do   ³
	//³remote, em funcao disso limitou tb a quantidade de graficos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TKC010SD(oExplorer, nPanel, {	STR0037,; //"Falta definir o parametro para o tipo de gráfico deste painel de informações."
									STR0038,; //"Os Tipos de Gráficos disponíveis são:"
									STR0039,; //"	01) GRP_LINE		Código GRF01"
									STR0040,; //"	02) GRP_AREA		Código GRF02"
									STR0041,; //"	03) GRP_POINT		Código GRF03"
									STR0042,; //"	04) GRP_BAR		Código GRF04"
									STR0048,; //"	10) GRP_PIE		Código GRF10"
									})
	Return(Nil)
Endif

nSerie := Val( MV_PAR09 )
	
AAdd(aSerie, {nSerie, 0, STR0195	, 65280} )		// CLR_HGREEN 	//"Total Loja"
AAdd(aSerie, {nSerie, 0, STR0196	, 16711680} )	// CLR_HBLUE 	//"Total Faturamento"
	
aSerie := TKC010VP44(aSerie, aEmpCont)			// Carrega os valores para as series

TkC010Grap(@oGraphic,nLeft,nTop,nRight,nBottom,oExplorer:GetPanel(nPanel),aSerie,CONTROL_ALIGN_BOTTOM,,X3Picture("F2_VALBRUT"),"$ *@*")

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn44ºAutor  ³Microsiga           º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Painel para exibicao de vendas (SigaLoja)                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMK010C                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn44(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()
Local aCab		:= {} 
Local oLbx		:= Nil 
Local oGetDados	:= Nil
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local bWhile	:= Nil 
Local nPosHeader:= 0     
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSL1Exc	:= (X2ModAcess("SL1") == "E")							// Indica se o SE1 esta como exclusivo

aCab := TKCListBox("SL1", aEmpCont, /*nPanel */)

If Len(aCab) > 0

	aCols := {}
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SL2"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "SL2", aCab[1][1], "" )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "SL2", aCab[1][1], "" )
		AAdd(aAllHeader, {"SL2", aHeader})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	STR0246		,;  //"Filial"
							STR0197		,;  //"Número"	
							STR0057 	,;  //"Vendedor"	
							STR0103  	,;  //"Emissão"	
							STR0198		,;  //"Vlr.Total"	
							STR0199		,;  //"Desconto"	
							STR0200		,;  //"Vlr.Liq."	
							STR0201		,;  //"Dt.Limite"	
							STR0202		,;  //"Documento"	
							STR0203		,;  //"Serie"		
							STR0204		,;  //"PDV"		
							STR0205		,;  //"Emissao NF"
							STR0206		,;  //"Vlr.Bruto"	
							STR0207		,;  //"Vlr.Merc."	
							STR0154		;   //"Operador"	
					Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
	
	oLbx:Cargo := "LOJA"
	oLbx:SetArray(aCab)
	oLbx:bLine:={||{   aCab[oLbx:nAt,15],;
						aCab[oLbx:nAt,1],;
						aCab[oLbx:nAt,2],;
						aCab[oLbx:nAt,3],;
						aCab[oLbx:nAt,4],;
						aCab[oLbx:nAt,5],;
						aCab[oLbx:nAt,6],;
						aCab[oLbx:nAt,7],;
						aCab[oLbx:nAt,8],;
						aCab[oLbx:nAt,9],;
						aCab[oLbx:nAt,10],;
						aCab[oLbx:nAt,11],;
						aCab[oLbx:nAt,12],;
						aCab[oLbx:nAt,13],;
						aCab[oLbx:nAt,14]}}
	oLbx:nAt := 1
	oLbx:Default()	                       
	
	oLbx:bChange := {||	If((lSL1Exc .AND. cFilAnt <> Eval(oLbx:bLine)[1]),(cFilAnt := Eval(oLbx:bLine)[1]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SL2"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SL2"})][2])),;
						TkMontaItens( "SL2", Eval(oLbx:bLine)[2], "" ),;
						Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
						cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))
	
	Eval(oLbx:bChange)
 
Else

	TKC010SD(oExplorer, nPanel, { STR0095,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
								  "",;
								  STR0208,;	//"	01} SL1 - Orçamento"
								  STR0209,;	//"	02) SL2 - Itens do Orçamento"
								  "",;
								  STR0210})	//"Somente orçamentos finalizados serão exibidos"
EndIf

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn45ºAutor  ³Vendas CRM          º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Painel para exibicao de vendas (faturamento)                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn45(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()
Local aCab		:= {} 
Local oLbx		:= Nil 
Local oGetDados	:= Nil
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local bWhile	:= Nil
Local nPosHeader:= 0 
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lSC6Exc	:= (X2ModAcess("SC6") == "E")							// Indica se o SUD esta como exclusivo

aCab := TKCListBox("SC5", aEmpCont, /*nPanel */)

If Len(aCab) > 0        

	aCols := {}
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SC6"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])

		If lSC6Exc .AND. cFilAnt <> aCab[1][13]
			cFilAnt := aCab[1][13]
		EndIf        
		
		TkMontaItens( "SC6", aCab[1][1], "" )
		cFilAnt := cFilAtu
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lSC6Exc .AND. cFilAnt <> aCab[1][13]
			cFilAnt := aCab[1][13]
		EndIf        
		
		TkMontaItens( "SC6", aCab[1][1], "" )
		cFilAnt := cFilAtu
		
		AAdd(aAllHeader, {"SC6", aHeader})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	STR0246		,; // "Filial"
							STR0211		,; // "Pedido"
							STR0177 	,; // "Cliente"
							STR0007		,; // "Loja"
							STR0212		,; // "Cli.Entreg"
							STR0213		,; // "Loj.Entreg"
							STR0214		,; // "Transp."
							STR0215		,; // "Tipo Cli."
							STR0216		,; // "Cond.Pgto."
							STR0217		,; // "Tab.Prc."
							STR0218		,; // "Emissao"
							STR0219		,; // "N. Fiscal"
							STR0203		;  // "Serie"
					Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
	
	oLbx:Cargo := "FATURAMENTO"
	oLbx:SetArray(aCab)
	oLbx:bLine:={||{	aCab[oLbx:nAt,13],;
						aCab[oLbx:nAt,1],;
						aCab[oLbx:nAt,2],;
						aCab[oLbx:nAt,3],;
						aCab[oLbx:nAt,4],;
						aCab[oLbx:nAt,5],;
						aCab[oLbx:nAt,6],;
						aCab[oLbx:nAt,7],;
						aCab[oLbx:nAt,8],;
						aCab[oLbx:nAt,9],;
						aCab[oLbx:nAt,10],;
						aCab[oLbx:nAt,11],;
						aCab[oLbx:nAt,12]}}
	oLbx:nAt := 1
	oLbx:Default()	                       
	oLbx:bChange := {||	If((lSC6Exc .AND. cFilAnt <> Eval(oLbx:bLine)[1]),(cFilAnt := Eval(oLbx:bLine)[1]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SC6"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SC6"})][2])),;
						TkMontaItens( "SC6", Eval(oLbx:bLine)[2], "" ),;
						Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
						cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

	Eval(oLbx:bChange)

Else

	TKC010SD(oExplorer, nPanel, { STR0095,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
								  "",;
								  STR0220,; //"	01} SC5 - Cabecalho do Pedido de Vendas"
								  STR0221,; //"	02) SC6 - Itens do Pedido de Vendas"
								  "",;
								  STR0222}) //"Somente itens com produtos não entregues serão exibidos."
EndIf

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn46ºAutor  ³Vendas CRM          º Data ³  06/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe todos os itens do SC6 (itens dos pedidos de venda) comº±±
±±º          ³entregas pendentes para o cliente                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn46(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()
Local aItens	:= {}
Local aCab		:= {} 
Local oLbx		:= Nil 
Local oGetDados	:= Nil
Local nX		:= 0
Local nPosHeader:= 0
Local cPed		:= ""
Local cSep		:= ""  
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local bWhile	:= Nil
Local cSeek		:= ""
Local nY		:= 0
Local nZ		:= 0
Local aFiliais	:= {}      
Local aCabTmp	:= {}
Local cFilAtu	:= cFilAnt
Local lMultiFil := lTodasFil
Local lSC6Exc	:= (X2ModAcess("SC6") == "E")							// Indica se o SUD esta como exclusivo

//Montar filtro da SC5 sobre o numero do pedido
If lTodasFil .AND. X2ModAcess("SC5") == "E"
    aFiliais	:= aFils
    lTodasFil 	:= .F.
Else
	aFiliais := {cFilAnt}
EndIf

For nX := 1 to Len(aFiliais)
	
	cFilAnt := aFiliais[nX]	
	aItens := TKCListBox("SC6", aEmpCont, /*nPanel*/, /*aFiltro*/)

	For nY := 1 to Len(aItens)
		If !(aItens[nY] $ cPed)
			cPed += cSep + aItens[nY]
			cSep := "/"
		EndIf
	Next nY		

	If Len(cPed) > 0
		aCabTmp := TKCListBox("SC5", aEmpCont, /*nPanel */, cPed )
	EndIf

	For nZ := 1 to Len(aCabTmp)
		AAdd(aCab,aClone(aCabTmp[nZ]))
	Next nZ

	aCabTmp := {}
	cPed := ""
	cSep := ""	

Next nX

lTodasFil := lMultiFil
cFilAnt := cFilAtu 

If Len(aCab) > 0

	aCols := {}
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SC6"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])

		If lSC6Exc .AND. cFilAnt <> aCab[1][13]
			cFilAnt := aCab[1][13]
		EndIf       
		
		TkMontaItens( "SC6", aCab[1][1], "" )		
		cFilAnt := cFilAtu
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lSC6Exc .AND. cFilAnt <> aCab[1][13]
			cFilAnt := aCab[1][13]
		EndIf       
		
		TkMontaItens( "SC6", aCab[1][1], "" )
		
		cFilAnt := cFilAtu
		
		AAdd(aAllHeader, {"SC6", aHeader})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	STR0246		,;
							STR0211		,;
							STR0177		,;
							STR0007		,;
							STR0212 	,;
							STR0213		,;
							STR0214		,;
							STR0215		,;
							STR0216		,;
							STR0217		,;
							STR0218		,;
							STR0219		,;
							STR0203		;
					Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
	
	oLbx:Cargo := "FATURAMENTO"
	oLbx:SetArray(aCab)
	oLbx:bLine:={||{	aCab[oLbx:nAt,13],;
						aCab[oLbx:nAt,1],;
						aCab[oLbx:nAt,2],;
						aCab[oLbx:nAt,3],;
						aCab[oLbx:nAt,4],;
						aCab[oLbx:nAt,5],;
						aCab[oLbx:nAt,6],;
						aCab[oLbx:nAt,7],;
						aCab[oLbx:nAt,8],;
						aCab[oLbx:nAt,9],;
						aCab[oLbx:nAt,10],;
						aCab[oLbx:nAt,11],;
						aCab[oLbx:nAt,12]}}
	oLbx:nAt := 1
	oLbx:Default()	                       
	oLbx:bChange := {||	If((lSC6Exc .AND. cFilAnt <> Eval(oLbx:bLine)[1]),(cFilAnt := Eval(oLbx:bLine)[1]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SC6"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SC6"})][2])),;
				   		TkMontaItens( "SC6", Eval(oLbx:bLine)[2], "" ),;
				   		Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
				   		cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

	Eval(oLbx:bChange)

Else
	TKC010SD(oExplorer, nPanel, { STR0095,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
								  "",;
								  STR0220,;
								  STR0221,;
								  "",;
								  STR0222})
EndIf


RestArea(aArea)

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn47ºAutor  ³Vendas CRM          º Data ³  06/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe todos os itens da ordem de servico do field service   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn47(oExplorer, nPanel, aEmpCont)


Local aArea    	:= GetArea()                                            // Salva a area atual
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn47															// Listbox do Cabecalho - AB1
Local aCabeca   := {}													// Array com os registros do AB1 - Cabecalho dos chamados tecnicos
Local oGetDados                                                         // MsGetDados com os itens do chamado tecnico - AB2
Local cFilAtu	:= cFilAnt												// Filial atual do sistema
Local lAB6Exc	:= (X2ModAcess("AB6") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("AB6", aEmpCont, nPanel)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095,; //"Para que as informacoes deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0223,; //"	01} AB6 - Ordens de ServiÇos" 
									STR0224,; //"	01} AB6 - Ordens de ServiÇos" 
									})
	Return(Nil)
Else
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "AB7"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])

		If lAB6Exc .AND. cFilAnt <> aCabeca[1][9]
			cFilAnt := aCabeca[1][9]
		EndIf  
		
		TkMontaItens( "AB7", aCabeca[1][1], "" )
		cFilAnt := cFilAtu
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lAB6Exc .AND. cFilAnt <> aCabeca[1][9]
			cFilAnt := aCabeca[1][9]
		EndIf  
		
		TkMontaItens( "AB7", aCabeca[1][1], "" )
		AAdd(aAllHeader, {"AB7", aHeader})
		
		cFilAnt := cFilAtu
		
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft ListBox oLB01Pn47 Fields;
				Header  STR0246 ,; // 01 - Filial
						STR0225	,; // 02 - Chamado 
						STR0103	,; // 03 - Emissao 
						STR0193	,; // 04 - Hora Ini 
						STR0216	,; // 05 - Hora Fim 
						STR0189 ,; // 06 - Atendente 
						STR0045 ,; // 07 - Status 
						STR0190 ,; // 08 - Ok 
						STR0191 ;  // 09 - Regiao
				Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn47:Cargo := "ORDEMSERVICO"
oLB01Pn47:SetArray(aCabeca)
oLB01Pn47:bLine:={||{	aCabeca[oLB01Pn47:nAt,9],;
						aCabeca[oLB01Pn47:nAt,1],;
						aCabeca[oLB01Pn47:nAt,2],;
						aCabeca[oLB01Pn47:nAt,3],;
						aCabeca[oLB01Pn47:nAt,4],;
						aCabeca[oLB01Pn47:nAt,5],;
						aCabeca[oLB01Pn47:nAt,6],;
						aCabeca[oLB01Pn47:nAt,7],;
						aCabeca[oLB01Pn47:nAt,8] }}
oLB01Pn47:nAt := 1
oLB01Pn47:Default()

oLB01Pn47:bChange:= {||	If((lAB6Exc .AND. cFilAnt <> Eval(oLB01Pn47:bLine)[1]),(cFilAnt := Eval(oLB01Pn47:bLine)[1]),.T.),;	
				   		nPosHeader := Ascan(aAllHeader, {|x| x[1] == "AB7"}),;
				   		aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "AB7"})][2])),;
				   		TkMontaItens( "AB7", Eval(oLB01Pn47:bLine)[2], "" ),;
				   		Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
				   		cFilAnt := cFilAtu }
				   		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um browser tipo MSGetDados Read Only dos itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

Eval(oLB01Pn47:bChange)

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn49ºAutor  ³Vendas CRM          º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Painel para exibicao das devolucoes das vendas              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn49(oExplorer, nPanel, aEmpCont)

Local aArea		:= GetArea()
Local aCab		:= {} 
Local oLbx		:= Nil 
Local oGetDados	:= Nil
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local bWhile	:= Nil
Local nPosHeader:= 0 
Local cFilAtu	:= cFilAnt
Local lSF1Exc	:= (X2ModAcess("SF1") == "E")							// Indica se o SUD esta como exclusivo

aCab := TKCListBox("SF1", aEmpCont, /*nPanel */)

If Len(aCab) > 0        

	aCols := {}
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SD1"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])
		TkMontaItens( "SD1", aCab[1][1] + aCab[1][2] + aCab[1][10] + aCab[1][11], "" )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		TkMontaItens( "SD1", aCab[1][1] + aCab[1][2] + aCab[1][10] + aCab[1][11], "" )
		AAdd(aAllHeader, {"SD2", aHeader})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	STR0246		,;
							STR0202		,;
							STR0203		,;
							STR0218		,;
							STR0226		,;
							STR0227		,;
							STR0228		,;
							STR0229		,;
							STR0230		,;
							STR0231		; 
					Size nRight,(nBottom * 0.5) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
	
	oLbx:Cargo := "DEVOLUCOES"
	oLbx:SetArray(aCab)
	oLbx:bLine:={||{   aCab[oLbx:nAt,12],;
						aCab[oLbx:nAt,1],;
						aCab[oLbx:nAt,2],;
						aCab[oLbx:nAt,3],;
						aCab[oLbx:nAt,4],;
						aCab[oLbx:nAt,5],;
						aCab[oLbx:nAt,6],;
						aCab[oLbx:nAt,7],;
						aCab[oLbx:nAt,8],;
						aCab[oLbx:nAt,9],;
						aCab[oLbx:nAt,10],;
						aCab[oLbx:nAt,11]}}
	oLbx:nAt := 1
	oLbx:Default()	                       
	oLbx:bChange := {||	If((lSF1Exc .AND. cFilAnt <> Eval(oLbx:bLine)[1]),(cFilAnt := Eval(oLbx:bLine)[1]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "SD1"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "SD1"})][2])),;
						TkMontaItens( "SD1", Eval(oLbx:bLine)[2]+Eval(oLbx:bLine)[3]+Eval(oLbx:bLine)[11]+Eval(oLbx:bLine)[12], "" ),;
						Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
						cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGetDados := MSGetDados():New((nBottom * 0.55),nLeft,(nBottom),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

	Eval(oLbx:bChange)

Else

	TKC010SD(oExplorer, nPanel, { STR0095,; //"Para que as informacoes deste folder sejam mostradas, sao utilizadas as tabelas:"
								  "",;
								  STR0232,;	//"	01} SF1 - Nota Fiscal de entrada"
								  STR0233,;	//"	02) SD1 - Itens da Nota Fiscal de Entrada"
								  "",;
								  STR0234})	//"Somente as devoluções serão exibidas."
EndIf

RestArea(aArea)

Return Nil       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn50ºAutor  ³Vendas CRM          º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Painel para exibicao dos agendamentos tecnicos do field     º±±
±±º          ³service para o cliente atual                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKC010C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn50(oExplorer, nPanel, aEmpCont)

Local aArea    	:= GetArea()
Local nTop      := 05													// Coordenadas de tela
Local nLeft     := 05
Local nBottom	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLB01Pn50															// Listbox do Cabecalho - SE1
Local aCabeca   := {}													// Array com os registros do SE1 - Titulos do financeiro
Local nRec      := ABB->(RecNo())
Local oEnchoice
Local aCoord    := {}
Local cFilAtu	:= cFilAnt												// Filial atual
Local lABBExc	:= (X2ModAcess("ABB") == "E")							// Indica se o SUD esta como exclusivo

aCabeca := TKCListBox("ABB", aEmpCont, nPanel)

If LEN(aCabeca) == 0
	TKC010SD(oExplorer, nPanel, {	STR0095 ,;	//"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
									"",;
									STR0245	})	//"	01} ABB - Agenda de Técnicos"
	Return(Nil)
Endif

aSort(aCabeca,,,{|x,y| DtoS(x[4])+x[5] < DtoS(y[4])+y[5]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Listbox do Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nTop, nLeft	ListBox oLB01Pn50 Fields;
				Header	STR0246 ,;	//"Filial"
						STR0225	,;	//"O.S."
						STR0235	,;	//"Técnico"
						STR0008	,;	//"Nome"
						STR0236	,;	//"Dt.Início"
					 	STR0237	,;	//"Hr.Início"
						STR0238	,;	//"Dt.Fim"
						STR0239	,;	//"Hr.Fim"
						STR0240	,;	//"Hr.Total"
						STR0241	,;	//"Observação"
						STR0242	,;	//"Sacramentado"
						STR0243	,;	//"Compareceu"
						STR0244	; 	//"Atendeu"
				Size nRight,nBottom*.4 NoScroll Of oExplorer:GetPanel(nPanel) Pixel

oLB01Pn50:SetArray(aCabeca)
oLB01Pn50:bLine:={||{	aCabeca[oLB01Pn50:nAt,13],;
						aCabeca[oLB01Pn50:nAt,1],;
						aCabeca[oLB01Pn50:nAt,2],;
						aCabeca[oLB01Pn50:nAt,3],;
						aCabeca[oLB01Pn50:nAt,4],;
						aCabeca[oLB01Pn50:nAt,5],;
						aCabeca[oLB01Pn50:nAt,6],;
						aCabeca[oLB01Pn50:nAt,7],;
						aCabeca[oLB01Pn50:nAt,8],;
						aCabeca[oLB01Pn50:nAt,9],;
						aCabeca[oLB01Pn50:nAt,10],;
						aCabeca[oLB01Pn50:nAt,11],;
						aCabeca[oLB01Pn50:nAt,12] }}
oLB01Pn50:nAt := 1
oLB01Pn50:Default()

oLB01Pn50:bChange:= {||	If((lABBExc .AND. cFilAnt <> Eval(oLB01Pn50:bLine)[1]),(cFilAnt := Eval(oLB01Pn50:bLine)[1]),.T.),;
						nRec := TKC010Brow( "AB6", "E", Eval(oLB01Pn50:bLine)[2] ),;
						oEnchoice:Refresh(),;
						cFilAnt := cFilAtu }    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um Enchoice tipo MsMGet Read Only do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aCoord, { nBottom*.45, nLeft, nBottom, nRight+5 } )

DbSelectArea("AB6")
DbSetOrder(1)
DbSeek(xFilial("AB6")+Eval(oLB01Pn50:bLine)[2])

oEnchoice := MsMGet():New("AB6",nRec,2,,,,,aCoord[1],,3,,,,oExplorer:GetPanel(nPanel),,,,,,.T.)

Eval(oLB01Pn50:bChange)

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn51  ºAutor  ³Vendas & CRM           º Data ³  12/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ticket Medio do Cliente em Questão                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn51(oExplorer, nPanel, aEmpCont)
Local aArea		:= GetArea()												// Salva a area atual
Local oGraphic																// Objeto do definicao do grafico
Local nSerie		:= 0														// Numero de series que contera o grafico
Local aSerie		:= {}														// Valores dos itens que farao parte da serie
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA	
Local nI			:= 0														// Contador Auxiliar
Local cDatas		:= ""														// Pontos de Referencia do Grafico
Local oSay																		// Objeto Say para permitir wordwrap
Local dCorte		:= STOD(aEmpCont[aScan(aEmpCont, {|x| ALLTRIM( x[1] ) == "CORTE"} )][3]) //Data de Corte

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

aSerie := TKC010VP51(aEmpCont)	// Carrega os valores para as series

If Len(aSerie) > 0
	For nI := 1 To Len(aSerie[1][2])
		cDatas +=  + Iif(nI > 1," ,"," ") + aSerie[1][2][nI][1] 
	Next nI
EndIf

TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .75),oExplorer:GetPanel(nPanel),aSerie,,,X3Picture("F2_VALBRUT"),"$ *@*")

@ (nBottom * .83),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .85),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel

TSay():New((nBottom * .85),21,{|| STR0247+TRIM(Posicione("SX2",1,TRIM(aEmpCont[9][3]),"X2NOME()")) },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) //"Ticket Médio por "

@ (nBottom * .90),08 BitMap oBmp2 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
oSay := TSay():New((nBottom * .90),21,{|| STR0248+DtoC(dCorte)+STR0249+cDatas },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom-(nBottom * .85)) //"Informações Para: "#" em "
oSay:lWordWrap := .T. 

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn52  ºAutor  ³Vendas & CRM           º Data ³  14/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faturamento por Categoria de Produto/Grupo                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn52(oExplorer, nPanel, aEmpCont)
Local aArea		:= GetArea()												// Salva a area atual
Local oGraphic																// Objeto do definicao do grafico 1
Local oGraphic2																// Objeto do definicao do grafico 2
Local aSerie		:= {}														// Valores dos itens que farao parte da serie 1
Local aSerie2		:= {}														// Valores dos itens que farao parte da serie 2
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA	
Local nI			:= 0														// Contador Auxiliar
Local oSay																		// Objeto Say para permitir wordwrap

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

aSerie := TKC010VP52(aEmpCont,1)	// Carrega os valores para a serie 1
aSerie2 := TKC010VP52(aEmpCont,2)	// Carrega os valores para a serie 2

If Len(aSerie) == 0 .AND. Len(aSerie2) == 0
	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
										"",;
										" 01} SF2 -"+TRIM(Posicione("SX2",1,"SF2","X2NOME()")),;
										" 02} SD2 -"+TRIM(Posicione("SX2",1,"SD2","X2NOME()")),;
										" 01} ACV -"+TRIM(Posicione("SX2",1,"ACV","X2NOME()")),;
										" 01} ACU -"+TRIM(Posicione("SX2",1,"ACU","X2NOME()"));										
									})
Else
	TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .45),oExplorer:GetPanel(nPanel),aSerie,,STR0250,X3Picture("F2_VALBRUT"),"$ *@*") //"Categoria X Produto"

	TkC010Grap(@oGraphic2,(nBottom * .55),02,nRight,(nBottom * .45),oExplorer:GetPanel(nPanel),aSerie2,,STR0251,X3Picture("F2_VALBRUT"),"$ *@*") //"Categoria X Grupo Produto"
EndIf

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn53  ºAutor  ³Vendas & CRM           º Data ³  14/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Paineis de Vendas no Varejo                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn53(oExplorer, nPanel, aEmpCont, cPanel)
Local aArea		:= GetArea()												// Salva a area atual
Local oGraphic																// Objeto do definicao do grafico 1
Local aSerie		:= {}														// Valores dos itens que farao parte da serie 1
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA
Local cTitle	

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

aSerie := TKC010VP53(aEmpCont,cPanel)	// Carrega os valores para a serie


TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .80),oExplorer:GetPanel(nPanel),aSerie,,,X3Picture("F2_VALBRUT"),"$ *@*")

@ (nBottom * .90),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

@ (nBottom * .92),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel

TSay():New((nBottom * .93),21,{|| STR0252 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom-(nBottom * .93)) //"Status das Vendas do Varejo" 

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn54  ºAutor  ³Vendas & CRM           º Data ³  15/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Paineis de Regras Desconto Varejo                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn54(oExplorer, nPanel, aEmpCont, cPanel)
Local aArea		:= GetArea()                                            // Salva a area atual
Local nTop			:= 05															// Coordenadas de tela
Local nLeft		:= 05
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLbx																			// Listbox do Cabecalho - MEI
Local aCab			:= {}															// Array com os registros do MEI
Local oGetDados 																	// Getdados com os itens - MEJ	
Local cFilAtu		:= cFilAnt														// Filial atual do sistema
Local lMEIExc		:= (X2ModAcess("MEI") == "E")								// Indica se o MEI esta como exclusivo
Local aTitulo		:= {}															// Header do Listbox
Local aCampos		:= {}															// Campos do Header
Local nPosCod		:= 0															// Posicao do Codigo
Local nPosFil		:= 0															// Posicao da Filial


Default cPanel := "" // Para release 11.7 o controle sera pelo nome do panel

aCab := TKCListBox("MEI", aEmpCont, nPanel,,cPanel)

//Campos do Listbox do Cabeçalho
DbSelectArea("SX3")
DbSetOrder(1)
MsSeek("MEI")		
While !SX3->(Eof()) .AND. X3_ARQUIVO == "MEI" 
	If (X3Uso(X3_USADO,12) .OR. X3_CAMPO == "MEI_FILIAL") .AND. MEI->(FieldPos(SX3->X3_CAMPO)) > 0 // 12 = sigaloja		
		AAdd(aCampos,X3_CAMPO)
		AAdd(aTitulo,X3Titulo())				
	End
	DbSkip()
End

If Len(aCab) > 0        

	aCols := {}
	nPosCod := AScan(aCampos,"MEI_CODREG")
	nPosFil := AScan(aCampos,"MEI_FILIAL")		
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "MEJ"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])

		If lMEIExc .AND. cFilAnt <> aCab[1][nPosFil]
			cFilAnt := aCab[1][nPosFil]
		EndIf        
		
		TkMontaItens( "MEJ", aCab[1][nPosCod], "" ,2)
		cFilAnt := cFilAtu
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lMEIExc .AND. cFilAnt <> aCab[1][nPosFil]
			cFilAnt := aCab[1][nPosFil]
		EndIf        
		
		TkMontaItens( "MEJ", aCab[1][nPosCod], "" ,2)
		cFilAnt := cFilAtu
		
		AAdd(aAllHeader, {"MEJ", aHeader})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	{} Size nRight,(nBottom * 0.65) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

	oLbx:aHeaders := aTitulo	
	oLbx:Cargo := cPanel
	oLbx:SetArray(aCab)
	oLbx:bLine:={|| aCab[oLbx:nAt] }
	oLbx:nAt := 1
	oLbx:Default()
	oLbx:bLDblClick := {||	SaveInter(), DbSelectArea("MEI"), DbSetOrder(1), MEI->(MsSeek(Eval(oLbx:bLine)[nPosFil]+Eval(oLbx:bLine)[nPosCod])),;						
								LJ3021Man("MEI",MEI->(Recno()),2,.T.), RestInter()}                      
	oLbx:bChange := {||	If((lMEIExc .AND. cFilAnt <> Eval(oLbx:bLine)[nPosFil]),(cFilAnt := Eval(oLbx:bLine)[nPosFil]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "MEJ"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "MEJ"})][2])),;						
						TkMontaItens( "MEJ", Eval(oLbx:bLine)[nPosCod], "" ,2),;						
						Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
						cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGetDados := MSGetDados():New((nBottom * 0.7),nLeft,(nBottom-20),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

	Eval(oLbx:bChange)

	@ (nBottom -18),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL
	
	@ (nBottom -15),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
	TSay():New((nBottom -13),21,{|| STR0253 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom) //"Para Visualizar a regra de um duplo clique." 

Else

	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
										"",;
										" 01} MEI -"+TRIM(Posicione("SX2",1,"MEI","X2NOME()")),;
										" 02} MEJ -"+TRIM(Posicione("SX2",1,"MEJ","X2NOME()"));
									})
EndIf

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn55  ºAutor  ³Vendas & CRM           º Data ³  14/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Paineis de Vendas Perdidas                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn55(oExplorer, nPanel, aEmpCont, cPanel)
Local aArea		:= GetArea()												// Salva a area atual
Local oGraphic																// Objeto do definicao do grafico 1
Local oGraphic2																// Objeto do definicao do grafico 2
Local aSerie		:= {}														// Valores dos itens que farao parte da serie 1
Local aList		:= {}
Local aCab			:= {}
Local aItens		:= {}
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA
Local oLbx	

Pergunte(cPerg,.F.)	// Posiciona nos parametros de usuario

aSerie		:= TKC010VP55(aEmpCont,1,cPanel)	// Carrega os valores para a serie

aSerie2	:= TKC010VP55(aEmpCont,2,cPanel)	// Carrega os valores para a serie

aList	:= TKC010VP56(aEmpCont,aSerie2,cPanel)	// Carrega os valores para o listbox
aCab	:= aList[1]
aItens	:= aList[2]

If Len(aSerie) > 0 .OR. Len(aSerie2) > 0 .OR. Len(aItens) > 0

	If Len(aSerie) > 0
		TkC010Grap(@oGraphic,02,02,nRight,(nBottom * .38),oExplorer:GetPanel(nPanel),aSerie,,,/*pict*/,/*mask*/)
	EndIf
	
	If Len(aSerie2) > 0
		TkC010Grap(@oGraphic2,(nBottom * .40),02,nRight,(nBottom * .38),oExplorer:GetPanel(nPanel),aSerie2,,,/*pict*/,/*mask*/)
	EndIf

	If Len(aItens) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Listbox  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ (nBottom * 0.78), 02 ListBox oLbx Fields;
									 Header {} Size nRight,(nBottom * 0.15) NoScroll Of oExplorer:GetPanel(nPanel) Pixel
		oLbx:aHeaders := aCab	
		oLbx:SetArray(aItens)
		oLbx:nAt := 1
		oLbx:bLine:={|| aItens[oLbx:nAt] }
		oLbx:Default()
		@ (nBottom * .95),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

		@ (nBottom * .96),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel

		TSay():New((nBottom * .96),21,{|| STR0254 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom-(nBottom * .96)) //"Lista de Produtos de Vendas Perdidas com Disponibilidade em estoque."			
	EndIF
	
Else

	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
										"",;
										" 01} MBR -"+TRIM(Posicione("SX2",1,"MBR","X2NOME()")),;										
									})
EndIf 

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010Pn56  ºAutor  ³Vendas & CRM           º Data ³  15/08/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Paineis de Cartão Fidelidade                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Perfil do Contato                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC010Pn56(oExplorer, nPanel, aEmpCont, cPanel)
Local aArea		:= GetArea()                                            // Salva a area atual
Local nTop			:= 05															// Coordenadas de tela
Local nLeft		:= 05
Local nBottom		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)
Local oLbx																			// Listbox do Cabecalho - MEI
Local aCab			:= {}															// Array com os registros do MEI
Local oGetDados 																	// Getdados com os itens - MEJ	
Local cFilAtu		:= cFilAnt														// Filial atual do sistema
Local lMBOExc		:= (X2ModAcess("MBO") == "E")								// Indica se esta como exclusivo
Local aTitulo		:= {}															// Header do Listbox
Local aCampos		:= {}															// Campos do Header
Local nPosCod		:= 0															// Posicao do Codigo
Local nPosFil		:= 0															// Posicao da Filial


Default cPanel := "" // Para release 11.7 o controle sera pelo nome do panel

aCab := TKCListBox("MBO", aEmpCont, nPanel,,cPanel)

//Campos do Listbox do Cabeçalho
DbSelectArea("SX3")
DbSetOrder(1)
MsSeek("MBO")		
While !SX3->(Eof()) .AND. X3_ARQUIVO == "MBO" 
	If (X3Uso(X3_USADO,12) .OR. X3_CAMPO == "MBO_FILIAL") .AND. MBO->(FieldPos(SX3->X3_CAMPO)) > 0 // 12 = sigaloja		
		AAdd(aCampos,X3_CAMPO)
		AAdd(aTitulo,X3Titulo())				
	End
	DbSkip()
End

If Len(aCab) > 0        

	aCols := {}
	nPosCod := AScan(aCampos,"MBO_CODBAR")
	nPosFil := AScan(aCampos,"MBO_FILIAL")		
	nPosHeader := Ascan(aAllHeader, {|x| x[1] == "MBP"})
	If nPosHeader > 0
		aHeader := aClone(aAllHeader[nPosHeader][2])

		If lMBOExc .AND. cFilAnt <> aCab[1][nPosFil]
			cFilAnt := aCab[1][nPosFil]
		EndIf        
		
		TkMontaItens( "MBP", aCab[1][nPosCod], "" ,2)
		cFilAnt := cFilAtu
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a montagem do aHeader e aCols pela FillGetDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lMBOExc .AND. cFilAnt <> aCab[1][nPosFil]
			cFilAnt := aCab[1][nPosFil]
		EndIf        
		
		TkMontaItens( "MBP", aCab[1][nPosCod], "" ,2)
		cFilAnt := cFilAtu
		
		AAdd(aAllHeader, {"MBP", aHeader})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Listbox do Cabecalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nTop, nLeft ListBox oLbx Fields;
					Header	{} Size nRight,(nBottom * 0.4) NoScroll Of oExplorer:GetPanel(nPanel) Pixel

	oLbx:aHeaders := aTitulo	
	oLbx:Cargo := cPanel
	oLbx:SetArray(aCab)
	oLbx:bLine:={|| aCab[oLbx:nAt] }
	oLbx:nAt := 1
	oLbx:Default()
								                
	oLbx:bChange := {||	If((lMBOExc .AND. cFilAnt <> Eval(oLbx:bLine)[nPosFil]),(cFilAnt := Eval(oLbx:bLine)[nPosFil]),.T.),;
						nPosHeader := Ascan(aAllHeader, {|x| x[1] == "MBP"}),;
						aHeader := If(nPosHeader==0,{},aClone(aAllHeader[Ascan(aAllHeader, {|x| x[1] == "MBP"})][2])),;						
						TkMontaItens( "MBP", Eval(oLbx:bLine)[nPosCod], "" ,2),;						
						Iif(oGetDados<>Nil,oGetDados:oBrowse:Refresh(),Nil),;
						cFilAnt := cFilAtu}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta um browser tipo MSGetDados Read Only dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGetDados := MSGetDados():New((nBottom * 0.45),nLeft,(nBottom * 0.8),nRight+5,2,"","","",.T.,,,.F.,,,,,,oExplorer:GetPanel(nPanel))

	Eval(oLbx:bChange)

	@ (nBottom * 0.85),02 TO nBottom,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL
	
	@ (nBottom *0.88),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
	TSay():New((nBottom *0.89),21,{|| STR0255 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom) //"Cartões Fidelidade e Saldos."
	
	@ (nBottom *0.93),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
	TSay():New((nBottom *0.94),21,{|| STR0256 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE,nRight-10,nBottom) //"Serão mostrados apenas os saldos ainda válidos." 

Else

	TKC010SD(oExplorer, nPanel, {	STR0001,; //"Para que as informações deste folder sejam mostradas, são utilizadas as tabelas:"
										"",;
										" 01} MBO -"+TRIM(Posicione("SX2",1,"MBO","X2NOME()")),;
										" 02} MBP -"+TRIM(Posicione("SX2",1,"MBP","X2NOME()"));
									})
EndIf

RestArea(aArea)
Return(Nil)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
