#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSR734.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR734 ³ Autor ³ Natie Sugahara         ³ Data ³ 11/09/03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ RECEITA X DESPESAS POR CONTRATO                            ³±±±
±±³          ³                                                            ³±±±
±±³          ³                                                            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR734()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³          |      |             |                                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR734()
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Define variaveis padroes para todos os relatorios...                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR734"
PRIVATE nLimite     := 132
PRIVATE nTamanho    := "M"
PRIVATE nQtdeClas	:= 0
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR734"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0002), 1,oEmToAnsi(STR0003) , 1, 1, 1, "",1 }
PRIVATE aOrd		:= {}
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCabec
PRIVATE Colunas		:= 132
PRIVATE AT_PRG  	:= "PLSR734"
PRIVATE wCabec0 	:= 1
PRIVATE wCabec1		:= ""
PRIVATE wCabec2		:= ""
PRIVATE wCabec3		:= ""
PRIVATE wCabec4		:= ""
PRIVATE wCabec5		:= ""
PRIVATE wCabec6		:= ""
PRIVATE wCabec7		:= ""
PRIVATE wCabec8		:= ""
PRIVATE wCabec9		:= ""
PRIVATE CONTFL		:= 1
PRIVATE cPathPict	:= ""

Pergunte(cPerg,.F.)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Envia controle para a funcao SETPRINT                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="Plsr734"					           //Nome Default do relatorio em Disco
wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  | Verifica se foi cancelada a operacao                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nLastKey  == 27
	Return
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Configura impressora                                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
SetDefault(aReturn,cAlias)
If nLastKey = 27
	Return
Endif

MsAguarde({|lEnd| R734Imp( @lEnd,wnRel,cAlias ) },Titulo )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R734Imp  ³ Autor ³ Natie Sugahara        ³ Data ³ 11/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Emite relatorio                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function R734Imp()
Local   cSQL			:= ""
Local   cDet			:= ""
Local   nOrdem  		:= aReturn[8]
Local   nX				:= 0
Local   nTotReceita		:= 0
Local   nTotDespesa 	:= 0

Private cSQLCond		:= ""
Private aData			:= {} 					//-- Array Totais

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Acessa parametros do relatorio...                                        ³
  ³ Variaveis utilizadas para parametros                                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cCodOpe 	:= mv_par01					//-- codigo da Operadora
cGrupoDe	:= mv_par02					//-- Codigo Grupo Empresa De
cGrupoAte	:= mv_par03					//-- Codigo Grupo Empresa Ate
cCodContDe	:= mv_par04					//-- Codigo Contrato de
cCodContAte := mv_par05					//-- Codigo Contrato Ate
cCodSubCDe	:= mv_par06					//-- Codigo Sub-Contrato De
cCodSubCAte	:= mv_par07					//-- Codigo Sub-contrato Ate
cCodFamDe	:= mv_par08					//-- Codigo Familia De
cCodFamAte	:= mv_par09					//-- Codigo Familia Ate
cDataDe 	:= mv_par10  				//-- Mes/ano De
cDataAte 	:= mv_par11  				//-- Mes/ano Ate
nSinAnal	:= mv_par12 				//-- Modo Sintetico ( Sub-contrato -PJ Familia- PF )/ Modo Analitico ( Usuario da Familia )
cTipoAnaR   := mv_par13                 //-- Considerar receitas baixadas, em aberto ou ambas

IF EMPTY(cDataDe)
	IF EMPTY(cDataAte)  
		MSGINFO(STR0021)
		Return
	ENDIF
ENDIF
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Processa valores da Receita e Despesa Apurados                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	PLR734Receita()

	PLR734Custo()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Texto do Cabecalho de Acordo com nSinAnal                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
Wcabec1 := If(nSinAnal = 1, oemToAnsi(STR0009),  oemToAnsi(STR0008) )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Ordena em  ordem  decrescente p/ Receita x Despesa                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
aSort(aData,,,{|x,y| x[3]+ x[4] > y[3] + y[4] }  )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inicializa a Impressao                                             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
For nX := 1 to Len(aData)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Verifica se foi abortada a impressao...                            ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	  ³ Exibe mensagem...                                                  ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	MsProcTXT("Imprimindo " + aData[nx,1] + "..." )
    nSaldo := (aData[nx,3] - aData[nX,4] )
    If nSinAnal = 2
        cDet := Transform(aData[nX,1], "@R ####.####.######-##" ) + space(1)
 	Else
		cDet := Transform(aData[nx,1] , "@R ####.####.############-###.#########-###" )  + space(1)
 	Endif
	cDet	+= aData[nX,2] + space(1)
	cDet	+= Transform(aData[nX,3], "@E 99,999,999.99" ) + space(1)
	cDet	+= Transform(aData[nX,4], "@E 99,999,999.99" ) + space(1)
	cDet	+= Transform(If(aData[nX,3]>0, (nSaldo/aData[nX,3]	) * 100,0),  "@E 999,999.99") + space(1)
	cDet    += Transform(nSaldo     , "@E 9,999,999.99" )
    Impr(cDet, "C" )
    nTotReceita	+= aData[nX,3]
    nTotDespesa += aData[nX,4]
Next nX
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Impressao dos totais do Relatorio                                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
If li + 3 >= 58
	Li := 0
Endif
Impr(__PrtThinLine() ,"C")
nSaldo := (nTotReceita - nTotDespesa )
If nSinanal = 1				//-- Modo Sintetico
	cDet 	:= space(41)+ oEmToansi(STR0007) +Space(15) + Transform(nTotREceita,  "@E 99,999,999.99 ") + space(1)
Else
	cDet 	:= space(20)+ oEmToansi(STR0007) +Space(15) + Transform(nTotREceita,  "@E 99,999,999.99 ") + space(1)
Endif
cDet 	+= Transform(nTotDespesa,  "@E 99,999,999.99 " )+ space(1)
cDet	+= Transform(If(nTotReceita>0, (nSaldo / nTotReceita)*100 ,0 ), "@E 999,999.99" ) + space(1)
cDet    += Transform(nSaldo     , "@E 9,999,999.99" )
Impr(cDet, "C")
Impr(__PrtThinLine() ,"C")
Impr("","C")

/*      10        20        30        40        50        60        70        80        90       100       120       130
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Modo Analitico
Codigo Familia      Nome Usuario                    Receita       Despesa   %           Saldo
####.####.######-## xxxxxxxxxxxxxxxxxxxxxxxxx 99,999,999.99 99,999,999.99 999.99 9,999,999.99
                    Media Geral               99.999,999.99 99,999,999.99 999.99 9,999,999.99

Modo Sintetico
Contrato                   Sub-Contrato  Descricao                       Receita       Despesa   %           Saldo
####.####.############-###.#########-### xxxxxxxxxxxxxxxxxxxxxxxxx 99,999,999.99 99,999,999.99 999.99 9,999,999.99
                                         Media Geral               99.999,999.99 99,999,999.99 999.99 9,999,999.99

*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Libera impressao                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
m_pag := 0
Impr("","F")

If  aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
EndIf
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fim do Relat¢rio                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLR734ReceitaºAutor  ³Microsiga           º Data ³  11/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Receita do Usuario apurado no periodo                         º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  PLR734Receita()
Local cSQLSE1 	:= ""
Local cChave 	:= ""
Local cNome 	:= ""
Local nPos 		:= 0

cSQLSE1 	:= "SELECT  E1_CODINT , E1_CODEMP, E1_MATRIC , E1_CONEMP, "
cSQLSE1     += "        E1_VERCON , E1_SUBCON, E1_VERSUB , E1_ANOBASE   , E1_MESBASE   , E1_VALOR, "
cSQLSE1		+= "		E1_PREFIXO, E1_NUM   , E1_PARCELA, E1_TIPO "
cSQLSE1 	+= "FROM  " + SE1->(RetSQLName("SE1"))           + " WHERE "
cSQLSE1 	+= "E1_FILIAL = '" + SE1->(xFilial("SE1"))      + "' AND "
cSQLSE1 	+= "D_E_L_E_T_ = ''                             AND "
cSQLSE1  	+= "E1_CODINT = '"  + cCodOpe             + "' AND "
cSQLSE1     += "E1_CODEMP >='"+ cGrupoDe +"' AND E1_CODEMP  <= '"+ cGrupoAte   +"' AND "
cSQLSE1 	+= "E1_ANOBASE+E1_MESBASE >='"    + Subs(cDataDe,3,4)+Subs(cDataDe,1,2)  +"' AND E1_ANOBASE+E1_MESBASE    <= '"+ Subs(cDataAte,3,4)+Subs(cDataAte,1,2)   +"' AND "
cSQLSE1 	+= "E1_CONEMP >='" + cCodContDe           +"' AND E1_CONEMP  <= '"+ cCodContAte            +"' AND "
cSQLSE1 	+= "E1_SUBCON >='" + cCodSubCDe           +"' AND E1_SUBCON  <= '"+ cCodSubCAte            +"' AND "
cSQLSE1		+= "E1_MATRIC >='" + cCodFamDe            +"' AND E1_MATRIC  <= '"+ cCodFamAte             +"' "

If     cTipoAnaR == 1 //Baixadas
       cSQLSE1 += " AND E1_SALDO = 0 "
ElseIf cTipoAnaR == 2 //Em Aberto
       cSQLSE1 += " AND E1_SALDO > 0 "
Else
       //ambas... nao precisa de condicao nenhuma...
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Se houver filtro executa parse para converter expressoes adv para SQL    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ! Empty(aReturn[7])
	cSQLSE1 	+= " and " + PLSParSQL( aReturn[7] )
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Define order by de acordo com a ordem...                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSQLSE1 	+=  "ORDER BY E1_FILIAL ,  E1_CODINT , E1_CODEMP ,  E1_CONEMP ,  E1_VERCON , E1_SUBCON, E1_VERSUB , E1_MATRIC  "
cSQLSE1 	:=  PLSAvaSQL( cSQLSE1 )
PLSQuery(cSQLSE1,"SE1Trb")

SE1Trb->(DbGoTop())
While !SE1Trb->( Eof() )
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se foi abortada a impressao...                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif

	cSql := "SELECT BM1_CODINT, BM1_CODEMP, BM1_MATRIC, BM1_TIPREG, BM1_CONEMP, BM1_VERCON, BM1_SUBCON, "
	cSql += "BM1_VERSUB, BM1_VALOR FROM "+RetSqlName("BM1")+" WHERE BM1_FILIAL = '"+xFilial("BM1")+"' "
	cSql += "AND BM1_PREFIX = '"+SE1Trb->E1_PREFIXO+"' "
	cSql += "AND BM1_NUMTIT = '"+SE1Trb->E1_NUM+"' "
	cSql += "AND BM1_PARCEL = '"+SE1Trb->E1_PARCELA+"' "
	cSql += "AND BM1_TIPTIT = '"+SE1Trb->E1_TIPO+"' "
	cSql += "AND "+RetSqlName("BM1")+".D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRBM1")

	While !TRBM1->( Eof() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe mensagem...                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsProcTXT("Processando Receita " + TRBM1->(BM1_CODINT + '.'+ BM1_CODEMP + '.' + BM1_MATRIC + '-' + BM1_TIPREG) + "..." )

		cChave 	:= If( nSinAnal = 1 ,	TRBM1->( BM1_CODINT + BM1_CODEMP +  BM1_CONEMP +  BM1_VERCON + BM1_SUBCON + BM1_VERSUB ),;
										TRBM1->( BM1_CODINT + BM1_CODEMP + BM1_MATRIC + BM1_TIPREG) )

		cNome 	:= If (nSinAnal = 1 , fDesc("BQC" ,cChave, "BQC_DESCRI"), Posicione("BA1", 2, xFilial("BA1")+cChave,"BA1_NOMUSR") )
		cNome 	:= Substr(cNome + space(25) ,  1,25)
		nPos 	:= Ascan(aData,  {|x|x[1] = cChave } )

		If nPos > 0
			aData[nPos,3] += If( nSinAnal = 1, SE1Trb->E1_VALOR, TRBM1->BM1_VALOR)
		Else
			aadd(aData ,{  cChave, ;
			cNome , ;
			If( nSinAnal = 1, SE1Trb->E1_VALOR, TRBM1->BM1_VALOR),;
			0  ;
			} )
		Endif

		TRBM1->( dbSkip() )
	Enddo
	TRBM1->( dbCloseArea() )
	SE1Trb->(DbSkip())
Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha arquivo...                                                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
SE1Trb->(dbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLR734CustoºAutor ³Microsiga           º Data ³  11/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Custo do Usuario apurado no periodo                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  PLR734Custo()
Local cSQL 		:= ""
Local cChave 	:= ""
Local cNome		:= ""
Local nPos 		:= 0
Local dDataDe	:= ctod('//')
Local dDataAte	:= ctod('//')
Local dDataAux	:= ctod('//')

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ (cDataDe/cDataAte)                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
dDataDe 	:= CtoD( "01/" + substr(cDataDe ,1,2) + "/" + substr(cDataDe ,3,4) )
dDataAux	:= CtoD( "01/" + substr(cDataAte,1,2) + "/" + substr(cDataAte,3,4) )
dDataAte	:= CtoD(strzero(Last_Day(dDataAux),02)+ "/" + substr(cDataAte,1,2) + "/" + substr(cDataAte,3,4) )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Faz filtro no arquivo...                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSQL 	:= "SELECT  BD6_CODOPE ,BD6_CODESP , BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_CONEMP, "
cSQL    += "        BD6_VERCON, BD6_SUBCON , BD6_VERSUB, BD6_NOMUSR, BD6_VLRPAG, BD6_FASE  , BD6_SITUAC  "
cSQL 	+= "FROM  " + RetSQLName("BD6") + " WHERE "
cSQL 	+= "BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSQL 	+= "D_E_L_E_T_ = ''                       AND "
cSQL 	+= "BD6_FASE   = '4' AND "									//-- Somente Faturado
cSQL 	+= "BD6_SITUAC = '1' AND " 									//-- Ativo
cSQL 	+= "BD6_CODOPE = '"  + cCodOpe  + "' AND "
cSQL 	+= "BD6_CODEMP >='"+ cGrupoDe       +"' AND BD6_CODEMP  <= '"+ cGrupoAte     +"' AND "
cSQL    += "BD6_DATPRO >='"             + dtos(dDataDe)  +"' AND BD6_DATPRO             <= '"+ dtos(dDataAte)+"' AND "
cSQL    += "BD6_CONEMP >= '"            +cCodContDe      +"' AND "
cSQL    += "BD6_CONEMP <= '"            +cCodContAte     +"' AND "
cSQL    += "BD6_SUBCON >= '"            +cCodSubCDe      +"' AND "
cSQL    += "BD6_SUBCON <= '"            +cCodSubCAte     +"' AND "
cSQL    += "BD6_MATRIC >='" + cCodFamDe            +"' AND BD6_MATRIC  <= '"+ cCodFamAte             +"' "


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Se houver filtro executa parse para converter expressoes adv para SQL    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ! Empty(aReturn[7])
	cSQL += " and " + PLSParSQL( aReturn[7] )
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Define order by de acordo com a ordem...                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSQL += "ORDER BY BD6_FILIAL ,  BD6_CODOPE , BD6_CODEMP ,  BD6_CONEMP ,  BD6_VERCON , BD6_SUBCON, BD6_VERSUB , BD6_MATRIC ,  BD6_TIPREG  "

cSQL := PLSAvaSQL(cSQL)
TCQUERY cSQL NEW ALIAS "BD6Trb"

BD6Trb->(DbGoTop())

While !( BD6Trb->(EOF() ) )
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Verifica se foi abortada a impressao...                            ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	  ³ Exibe mensagem...                                                  ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	MsProcTXT("Processando Despesas " + BD6Trb->( BD6_CODOPE + BD6_CODEMP + BD6_MATRIC )  + "..." )

	cChave 	:= If( nSinAnal = 1 , BD6Trb->(BD6_CODOPE+ BD6_CODEMP +  BD6_CONEMP + BD6_VERCON +  BD6_SUBCON + BD6_VERSUB  ) , BD6Trb->( BD6_CODOPE + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG ) )
	cNome 	:= If (nSinAnal = 1 , fDesc("BQC" ,cChave, "BQC_DESCRI") , LEFT(BD6Trb->BD6_NOMUSR,25) )
	cNome 	:= Substr(cNome + space(25) ,  1,25)
	nPos 	:= Ascan(aData,  {|x|x[1] = cChave } )
	If nPos > 0
		aData[nPos,4] := aData[nPos,4] + BD6Trb->BD6_VLRPAG
	Else
		aadd(aData ,{ cChave, ;
		               cNome, ;
		               0 , ;
		               BD6Trb->BD6_VLRPAG ;
		             } )
	Endif
	BD6Trb->(DbSkip())
Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha arquivo...                                                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-|*/
BD6Trb->(dbCloseArea())

Return
