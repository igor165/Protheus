#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER101.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER101   ºAutor  ³Microsiga           º Data ³  30/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para tratar a emissao do relatorio mensal.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Folha de pagamento  - Mexico                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³ Data    ³ BOPS   | Motivo da Alteracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauricio T.³26/06/06 ³--------|Acerto na totalizacao dos lancamentos,  º±±
±±º           ³         ³        |posicionamentos, ordenacao.             º±±
±±ºRonan      ³26/07/06 ³--------|Ajuste no estilo horizontal, mostrando  º±±
±±º           ³         ³        |em uma linha separada a verba com mais  º±±
±±º           ³         ³        |de uma ocorrencia.                      º±±
±±ºKelly      ³26/04/07 ³--------|Considerar bases de provento e desconto º±±
±±º           ³         ³        |ao tratar valores.                      º±±
±±ºValdeci L. ³30/01/08 ³140682  ³Alteracao na forma de chamada da funcao ³±±
±±º           ³         ³        ³ffiltro e filtragem apenas da SRA e SRK ³±±
±±º           ³         ³        ³e SRV ja que a somente estes campos sao ³±±
±±º           ³         ³        ³exibidos em tela                        ³±±
±±³Erika K    ³02/06/08 ³--------³Alteracao do nome do pergunte para inte ³±±
±±³           ³         ³       	 ³gracao de dicionarios Mexico e R1.2.  ³±±
±±³Kelly      ³27/06/08 ³ 148918  ³Ajuste no grupo de perguntas GPER101.   ³±±
±±³Gisele V.  ³08/07/08 ³ 148300  ³Alteracao do nome da variavel aArray.   ³±±
±±ºMarcelo    ³05/09/08 ³ 153401  |Incluido pergunte "Considera Base" para º±±
±±º           ³         ³          |definir se as bases deverao ser consideº±±
±±º           ³         ³         |radas na soma dos proventos/descontos   º±±
±±ºMarcelo    ³05/09/08 ³ 143402  |Ajuste no relatorio sintetico por C.C.  º±±
±±º           ³         ³         |Ajuste nas msg de erro do relatorio     º±±
±±º           ³         ³         |horizontal e vertical/sintetico         º±±
±±ºValdeci L. ³14/07/09 ³ 173902009|Aumento no tamanho da picture na impr. º±±
±±º           ³         ³          |dos totais e valores de referencia.    º±±
±±ºAlceu P.	³02/09/09 ³          ³Ajuste para Localização Angola.		 º±±
±±ºFrancisco  ³23/12/09 ³ 000030790³Compatibilizar para Versao Corporativa º±±
±±ºMohanad 	³03/02/12 ³ 027762012³ANG - Inclusão de leitura do Mnemônico º±±
±±º           ³         ³    TELRWP|P_MDOLARRH para ser utilizado como parâº±±
±±º           ³         ³          |metro na função XMOEDA()(Moeda Destino)º±±
±±ºRaquel H.  ³29/02/12 ³ 036022012³Alinhamento de campos do relatorio,    º±±
±±º           ³         ³    TENG40|ajustes realizados com e sem gestao    º±±
±±º           ³         ³          |coorporativa.                          º±±
±±ºR.Berti    ³24/08/12 ³ TFQQDI   ³Ajustada impressao do salario e helps. º±±
±±º           ³		   ³	       ³                                       º±±
±±ºJonathanGlz³05/05/15 ³PCREQ-4256³Se elimina la funcion AjustaSX1, la    º±±
±±º           ³		   ³	       ³cualrealiza la modificacion al diccio- º±±
±±º           ³		   ³	       ³nario dedatos(SX1) por motivo de       º±±
±±º           ³		   ³	       ³adecuacion de nueva estructura de SXs  º±±
±±º           ³		   ³	       ³para version 12                        º±±
±±ºAlex Hdez. ³13/01/16 ³PCREQ-7944³Se paso a la v12 a partir del fuente deº±±
±±º           ³         ³          ³v11 con la fecha 26/08/15              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */


Function GPER101(nChoice)

LOCAL aArea			:= GetArea()
LOCAL cDesc1 		:= STR0001					//"Relatorio por Codigo"
LOCAL cDesc2 		:= STR0002					//"Ser  impresso de acordo com os parametros solicitados pelo"
LOCAL cDesc3 		:= STR0003					//"usu rio."
LOCAL aOrd			:={STR0004,STR0005,STR0006}	//"Matricula"###"Centro de Custo"###"Nome"
LOCAL nColRel		:= 37 						// Variavel que determina a posicao inicial das coluna.
LOCAL nCont			:= 0
LOCAL lAllVerbas	:= .t.
LOCAL CPERG			:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn 	:= {STR0007, 1,STR0008, 1, 2, 1, "", 1}	//"Zebrado"###"Administra‡„o"
Private aSomaTotal	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOrdem
Private lAbortPrint := .F.
Private lAglutPd    := ( GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
Private aVerbas		:= {}
Private	nTotalGeral	:= 0
Private nTotal      := 0
Private nProvento	:= 0
Private nDesconto	:= 0
Private nLiquido	:= 0
Private nHorasTotal	:= 0
Private nDiasTotal	:= 0
Private aFilArray   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE titulo
PRIVATE AT_PRG := "GPER101"
PRIVATE wCabec0
PRIVATE wCabec1
PRIVATE wCabec2
PRIVATE CONTFL   := 1
PRIVATE LI       := 0
PRIVATE COLUNAS  := 232
PRIVATE nTamanho := "M"
PRIVATE nChar	 := 15
Private cPict1	:=	If (MsDecimais(1)==2,"@E 99,999,999,999.99",TM(99999999999,17,MsDecimais(1)))  // "@E 99,999,999,999.99

DEFAULT nChoice := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial  De                               ³
//³ mv_par02        //  Filial  Ate                              ³
//³ mv_par03        //  Centro de Custo De                       ³
//³ mv_par04        //  Centro de Custo Ate                      ³
//³ mv_par05        //  Matricula De                             ³
//³ mv_par06        //  Matricula Ate                            ³
//³ mv_par07        //  Nome De                                  ³
//³ mv_par08        //  Nome Ate                                 ³
//³ mv_par09        //  Formato Vertical / Horizontal            ³
//³ mv_par10        //  Relatorio Analitico ou Sintetica         ³
//³ mv_par10        //  Se lista todos os codigos encontrados    ³
//³ mv_par12        //  Lista Salario do Cadastro ?              ³
//³ mv_par13        //  Cria String com Situacao do Funcionario  ³
//³ mv_par14        //  Cria String contendo Categorias          ³
//³ mv_par15        //  Cont. Codigos a Listar                   ³
//³ mv_par16        //  Imprimir Total da Empresa                ³
//³ mv_par17        //  Processo                                 ³
//³ mv_par18        //  Imprimir roteiro                         ³
//³ mv_par19        //  Periodo                                  ³
//³ mv_par20        //  Numero de pagamento                      ³
//³ mv_par21        //  Imprimir Roteiro	                       ³
//³ mv_par22        //  Considera Base		                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if nChoice # 2
	Pergunte("GPER101",.F.)
	CPERG := "GPER101"
Endif	

aFilArray := {"SRA","SRC", "SRV"}
ffiltro("GPER101",aFilArray,2)//2 - Cria as Variaveis de filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit   	:= STR0011				//"VALORES POR CODIGO "
wnrel	:="GPER101"             //Nome Default do relatorio em Disco
wnrel := SetPrint("SRA",wnrel, CPERG ,@cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)
If	nLastKey = 27
	Return
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if  nChoice # 2
	FilialDe  	:= mv_par01
	FilialAte 	:= mv_par02
	CcDe      	:= mv_par03						// Centro de Custo DE
	CcAte     	:= mv_par04						// Centro de Custo ATE
	MatDe     	:= mv_par05						// Matricula DE
	MatAte    	:= mv_par06						// Matricula ATE
	NomDe     	:= mv_par07						// Nome DE
	NomAte    	:= mv_par08						// Nome ATE
	nVerHor   	:= mv_par09						// 1-Vertical ou 2-Horizontal
	nSinAna   	:= mv_par10						// Analitico ou Sintetico
	lSalario  	:= If(mv_par11 == 1,.T.,.F.)	// Salario Cadastro
	cSituacao 	:= mv_par12						// Situação
	cCategoria	:= mv_par13						// Categoria
	cCodigos  	:= ALLTRIM(mv_par14)			// Codigos ( Verbas )
	cCodigos  	+= ALLTRIM(mv_par15)			// Codigos ( Verbas )
	lAllVerbas 	:= If(mv_par16 == 1,.T.,.F.)	// Imprimir todas as verbas
	lImpEmpr  	:= If(mv_par17 == 1,.T.,.F.)	// Listar total empresa
	cProcesso	:= 	mv_par18        			// Processo				C 5
	cPeriodo	:=	mv_par19        			// Periodo             	C 6
	cPagamento	:=	mv_par20        			// Numero de pagamento 	C 2
	cRoteiro	:=	mv_par21        			// Imprimir roteiro    	C 3
	lConsBase   := If(mv_par22 == 1,.T.,.F.)    //Se considera base na soma dos proventos e descontos   comentado junior.
Else
	FilialDe  	:= SRA->RA_FILIAL
	FilialAte 	:= SRA->RA_FILIAL
	CcDe      	:= SRC->RC_CC						// Centro de Custo DE
	CcAte     	:= SRC->RC_CC						// Centro de Custo ATE
	MatDe     	:= SRA->RA_MAT						// Matricula DE
	MatAte    	:= SRA->RA_MAT						// Matricula ATE
	NomDe     	:= SRA->RA_NOME						// Nome DE
	NomAte    	:= SRA->RA_NOME						// Nome ATE
	nVerHor   	:= 1								// 1-Vertical ou 2-Horizontal
	nSinAna   	:= 2								// Analitico ou Sintetico
	lSalario  	:= .T.								// Salario Cadastro
	cSituacao 	:= SRA->RA_SITFOLH 					// Situação
	cCategoria	:= SRA->RA_CATFUNC					// Categoria
	cCodigos  	:= ''								// Codigos ( Verbas )
	cCodigos  	+= ''								// Codigos ( Verbas )
	lAllVerbas 	:= .T.								// Imprimir todas as verbas
	lImpEmpr  	:= .F.								// Listar total empresa
	cProcesso	:= 	SRA->RA_PROCES        			// Processo				C 5
	cPeriodo	:=	cPeriodo        				// Periodo             	C 6
	cPagamento	:=	cSemana        					// Numero de pagamento 	C 2
	cRoteiro	:=	cRoteiro        				// Imprimir roteiro    	C 3
	lConsBase   := .T.     							//Se considera base na soma dos proventos e descontos   comentado junior.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina para varrer as verbas escolhidas no parametro e atribuir a sua coluna.³
//³Vertical/Sintetico															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TITULO := 	STR0012

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina para varrer as verbas escolhidas no parametro e atribuir a sua coluna.³
//³Vertical e Horizontal														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
	Aadd(aVerbas,{Substr(cCodigos,nCont,3),nColRel,0})
	nColRel:= nColRel + 15
Next

If nVerHor == 1
	If lAllVerbas
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A finalidade desta rotina é devido a funcao que retorna as verbas em aberto e fechado  ³
		//³que esta sendo usado neste programa, recebe um array com as verbas a serem pesquisadas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVerbas	:= {}
		DbSelectArea("SRV")
		DbSetOrder(1)
		ffiltro("GPER101",aFilArray,1/*Exec Filtro*/, 3/*Inicio Exec*/, 3/*Fim Exec*/, .T./*Forc Atual*/)
		dbSeek(xFilial("SRV"))
		While !Eof() .And. SRV->RV_FILIAL == xFilial("SRV")
			Aadd(aVerbas,{SRV->RV_COD,0})
			dbSkip()
		EndDo
	Endif

	If Empty(aVerbas)
	   MsgAlert(STR0034,STR0035)  //- Favor, selecione as verbas ou habilite o parametro de todas as verbas. ### Falta parametro
	   Return
	Endif

	Aadd(aVerbas,{STR0013,nColRel,0}) //"Total Liquido"

	wCabec1 		:= Space(10)+STR0014+cProcesso+Space(10)+STR0015+cPeriodo+Space(10)+STR0016+cPagamento+Space(10)+STR0017+cRoteiro
	If cPaisLoc == "ANG"
		wCabec2 	:= STR0041  //"Fil. C.Custo                  Matr.     Nome                       Cod Descrição              Referencia     Valor "
	Else
		wCabec2 	:= IF(nSinAna == 2, STR0018, STR0042)  //"Fil. C.Custo                  Matr.     Nome                       Cod Descrição              Referencia     Valor "
	Endif
	Aadd(aSomaTotal ,{0,0,0})
	nTamanho     := "M"
	Colunas      := 130
Endif

If nVerHor = 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nVerHor = 2  relatorio horizontal   ³
	//³Define o máximo de Verbas a listar. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAllVerbas
		MsgAlert(STR0036, STR0037)  //"E permitido imprimir todas as verbas apenas no formato vertical." ####"Atencao"
		Return
	Endif

	If Len(aVerbas) > 5 .And. cPaisLoc == "ANG"
		MsgAlert("No formato horizontal é permitido imprimir até 5 verbas.")
	 	Return
	ElseIF Len(aVerbas) > 12
		MsgAlert(STR0038, STR0037)  //"No formato horizontal é permitido imprimir até 12 verbas." ####"Atencao"
	 	Return
	Endif

	If Empty(aVerbas)
   		MsgAlert(STR0039,STR0035)	// "Favor, selecione as verbas!"###"Falta parametro"
   		Return
	Endif

	If cPaisLoc <> "ANG"
		Aadd(aVerbas,{STR0013,nColRel,0}) //"Total Liquido"
	Endif

	nTamanho	:= "G"
	Colunas     := 220
	nChar		:= 15
	aReturn[4]	:= 1
	wCabec1 	:= Space(30)+STR0014+cProcesso+Space(20)+STR0015+cPeriodo+Space(20)+STR0016+cPagamento+Space(20)+STR0017+cRoteiro
	wCabec2 	:= STR0019   //"Fil.Matr. Nome"
Endif

If nLastKey = 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Passa parametros de controle da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,"SRA",,,nTamanho)
RptStatus({|| RunReport() },Titulo)

RestArea( aArea )

ffiltro("GPER101",aFilArray,0)//0- Limpa os filtros

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER101   ºAutor  ³Microsiga           º Data ³  01/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Titulo)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Acesso do Usuario                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local lPass				:= .t.
Local cVerbaStatus  	:= ""
Local cDescrVerbas		:= ""
Local _cTpVerba			:= ""
Local cDescVerba		:= ""
Local cDescCentro		:= ""
Local nCont				:= 0
Local nFilCont			:= 0
Local _cPerAntMat		:= ""
Local cLin				:= ""
Local cLinTot			:= ""
Local nColuna 			:= 35
Local nTCont
Local nValor            := 0
Local cValor
Local nAux
Local cVrb:= Space(03)
Local nTot:= 0   
Local cVerbs := "" 
Local nTotVal := 0  
Local nTotHrs := 0 
Local nTotVer	 := 0  
Local nTotX	:= 0     

Private _cFilialAnt		:= ""
Private cCCusto 		:= ""
Private nVlrHoras		:= 0
Private nVlrTotal		:= 0
Private	nHorasTipo		:= 0
Private nTValorProvento	:= 0
Private nTValorDesconto	:= 0
Private nTHorasTipo		:= 0
Private	nTDiasTipo		:= 0
Private nDiasTipo		:= 0
Private nSBHoras		:= 0
Private nSBSalario 		:= 0
Private nPosVerba		:= 0
Private nSubLinha		:= 0
Private nVlCCHr			:= 0
Private nVlCCVl 		:= 0
Private nPosVA 			:= 0
Private nRefVertSint	:= 0
Private nVlrVertSint	:= 0
Private nValorProvento	:= 0
Private nValorDesconto	:= 0
Private aVerbasRet		:= {}
Private aFilHorAnalSint	:= {}
Private aPerAberto		:= {}
Private aPerFechado		:= {}
Private aVerbasVAnalit	:= {}
Private aVertSintCC		:= {}
Private aVerVertSint	:= {}
Private dDataPgto       := ctod('')
Private nDolarRH		:= 1

Private nEsp            := 0

If cPaisLoc == "ANG"
	dbSelectArea("RCA")
	dbSetorder(1)
	dbseek(xFilial('RCA') + "P_MDOLARRH")
	nDolarRH := RCA->RCA_CONTEU
	If Valtype(nDolarRH) == "C"
		nDolarRH := Val(nDolarRH)
	EndIf
EndIf

dbSelectArea("RCH")
dbSetorder(9)
dbseek( xFilial('RCH') + cPeriodo )
dDataPgto := RCH->RCH_DTPAGO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³--Salvar Ordem Selecionada SETPRINT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem    := aReturn[8]
dbSelectArea("SRA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a ordem do Index que será usada pelo o SRA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(FilialDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := FilialAte + MatAte
ElseIf nOrdem == 2
	dbSetOrder(2)
	dbSeek(FilialDe + CcDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := FilialAte + CcAte + MatAte
ElseIf nOrdem == 3
	dbSetOrder(3)
	dbSeek(FilialDe + NomDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := FilialAte + NomAte + MatAte
Endif

If ( nVerHor == 1 .and. nSinAna == 1 )
	If nOrdem == 3
		MsgAlert(STR0040, STR0037)  //"Não é possível imprimir relatório sintético por ordem de nome." ####"Atencao"
	 	Return
	EndIf
EndIf

cFilAnterior := Replicate("!",FWGETTAMFILIAL)
cCcAnt  := "!!!!!!!!!"
wCabec2	:= wCabec2 + Space(20)
ffiltro("GPER101",aFilArray,1/*Exec Filtro*/, 1/*Inicio Exec*/, 1/*Fim Exec*/, .T./*Forc Atual*/) // Executa Filtro
If nVerHor == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o cabeçalho(descricao) do relatorio Horizontal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescrVerbas 	:= 	""
	For nCont:= 1 to Len(aVerbas)
		If nCont < Len(aVerbas)
			If cPaisLoc == "ANG"
				cDescrVerbas  := Space(5) + aVerbas[nCont][1] + "-" + DescPd(aVerbas[nCont][1], SRA->RA_FILIAL, 08) + Space(02) + DescPd(aVerbas[nCont][1], SRA->RA_FILIAL, 08) + "(D)" + Space(2)
			Else
				cDescrVerbas  := aVerbas[nCont][1] + "-" + DescPd(aVerbas[nCont][1], SRA->RA_FILIAL, 08) + Space(03)
			Endif
		Else
			If cPaisLoc == "ANG"
				cDescrVerbas  :=	Space(5) + aVerbas[nCont][1] + "-" + DescPd(aVerbas[nCont][1], SRA->RA_FILIAL,08) + Space(02) + DescPd(aVerbas[nCont][1], SRA->RA_FILIAL, 08) + "(D)" + Space(2)
			Else
				cDescrVerbas  := aVerbas[nCont][1]
			Endif
		Endif
		wCabec2	:= wCabec2 + cDescrVerbas
	Next
Endif

dbSelectArea("SRA")
SetRegua(SRA->(RecCount()))
_cFilialAnt	:= SRA->RA_FILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta função busca todos os periodos em aberto e fechado dos funcionarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetPerAbertFech(cProcesso,cRoteiro,cPeriodo,cPagamento,,,@aPerAberto,@aPerFechado)

If Empty(aPerAberto) .And. Empty(aPerFechado)
   MsgAlert(STR0043,STR0044)
   Return
Endif

While !Eof() .And. &cInicio <= cFim
	IncRegua()

	If lAbortPrint
		Exit
	Endif

	If (SRA->RA_NOME < NomDe)  .Or. (SRA->RA_NOME > NomAte) .Or. ;
		(SRA->RA_MAT < MatDe)  .Or. (SRA->RA_MAT > MatAte)  .Or. ;
		(SRA->RA_CC < CcDe)    .Or. (SRA->RA_CC > CcAte)
		SRA->(dbSkip())
		Loop
	EndIf

	If !( SRA->RA_SITFOLH $ cSituacao ) .OR.  !( SRA->RA_CATFUNC $ cCategoria )
		SRA->(dbSkip())
		Loop
	Endif

	aVerbasRet:= RetornaVerbasFunc(SRA->RA_FILIAL,SRA->RA_MAT,,cRoteiro,aVerbas,aPerAberto,aPerFechado)

	If Len(aVerbasRet) == 0
		SRA->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Verba, no array de retorno.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVerbasRet 	:= ASort(aVerbasRet,,,{|x,y| x[3] < y[3] })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Relatorio Horizontal nVerHor = 2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVerHor == 2
		nSubLinha	:=	0

		If nSinAna == 2 // Horizontal - Analitico
			//verificar se eh de outra filial, fazer a quebra
			If _cFilialAnt<>SRA->RA_FILIAL
				// 						   FILIAL        NOME DA FILIAL
	        	// Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxxxxxxxxxxx
				// Sem Gestao Coorporativa xx            xxxxxxxxxxxxxxx
				ImpR( Replicate("-",Colunas), "C" )
				If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15, nEsp:= 18)
				cLinTot := _cFilialAnt + " " + SM0->M0_FILIAL
                cLinTot+=Space(nEsp)

			    If(cPaisLoc <> "ANG", nTCont := (Len(aVerbas)-1), nTCont := Len(aVerbas))
				For nCont:= 1 to nTCont
					nExist := Ascan(aFilHorAnalSint,{ |x| x[1] = aVerbas[nCont][1] } )
					nValor :=0
		   			For nAux:= nExist+1 to Len(aFilHorAnalSint)
						 If (aVerbas[nCont][1] ==  aFilHorAnalSint[nAux][1])
						 	nValor+=aFilHorAnalSint[nAux][2]
						 EndIf
		   	   		Next
					If nExist > 0
						nValor += aFilHorAnalSint[nExist][2]
					Else
						nValor := 0
					EndIf

                    cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLinTot+= cValor + Space(1)

				    If cPaisLoc == "ANG"
					    cLinTot +=Transform( xMoeda(nValor,1,nDolarRH,dDataPgto) , "@E 999,999,999.99" )
					Endif

				Next nCont
				If cPaisLoc <> "ANG"
					cValor:= AllTrim(CValToChar(Transform( nTotalGeral, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLinTot+= cValor + Space(1)
				EndIf

				ImpR( cLinTot, "C" )
				ImpR( Replicate("-",Colunas), "C" )
				ImpR( "", "C" )
				aFilHorAnalSint	:= {}
			Endif
			// 						   FILIAL        MATRICULA  NOME
        	// Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxx     xxxxxxxxxxxxxxxxxxxx
			// Sem Gestao Coorporativa xx            xxxxxx     xxxxxxxxxxxxxxxxxxxx
			cLin := SRA->RA_FILIAL + " " + SRA->RA_MAT + " " + Substr(SRA->RA_NOME, 1, 20)
			If( fIsCorpManage( FWGrpCompany() ), cLin := SubStr(cLin,1,30), cLin)

		Endif

		If nSinAna == 1 // Sintetico
			If _cFilialAnt <> SRA->RA_FILIAL
			   	// 						   FILIAL        NOME DA FILIAL
	        	// Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxxxxxxxxxxx
				// Sem Gestao Coorporativa xx            xxxxxxxxxxxxxxx
			    If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15, nEsp:= 18)
				cLinTot := _cFilialAnt + " " + SM0->M0_FILIAL
                cLinTot+=Space(nEsp)
				nTCont := Len(aVerbas)-1
				For nFilCont:= 1 to nTCont
					nExist := Ascan(aFilHorAnalSint,{ |x| x[1] = aVerbas[nFilCont][1] } )
					nValor :=0
					For nAux:= nExist+1 to Len(aFilHorAnalSint)
						 If (aVerbas[nFilCont][1] ==  aFilHorAnalSint[nAux][1])
						 	nValor+=aFilHorAnalSint[nAux][2]
						 EndIf
					Next

					If nExist > 0
						nValor += aFilHorAnalSint[nExist][2]
					Else
						nValor := 0
					EndIf

					cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLinTot+= cValor + Space(1)

				    If cPaisLoc == "ANG"
					    cLinTot +=Transform( xMoeda(nValor,1,nDolarRH,dDataPgto) , "@E 999,999,999.99" )
					Endif

				Next
				If cPaisLoc <> "ANG"
					cValor:= AllTrim(CValToChar(Transform( nTotalGeral, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLinTot+= Space(aVerbas[Len(aVerbas),2]-Len(cLinTot)-1) + cValor
		   		Endif
				ImpR( cLinTot, "C" )
				aFilHorAnalSint	:= {}
			Endif
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Totalizar os lancamentos por verbas                 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		For nCont:= 1 to len(aVerbasRet)
			nPosVerba	:= Ascan(aVerbas,{ |x| x[1] = aVerbasRet[nCont][3] } )
			If nPosVerba == 0
				Loop
			Endif
		  	If nSinAna == 2 // Analitico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Horizontal e Analitico, Impressao dos valores das   ³
				//³  verbas em coluna pre estabelecida no aVerbas.      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aVerbas[nPosVerba,3] += aVerbasRet[nCont][7]
			Endif

			_cTpVerba 	:= PosSrv( aVerbasRet[nCont][3],SRA->RA_FILIAL,"RV_TIPOCOD" )

			If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
				nSubLinha	:= nSubLinha 	+ aVerbasRet[nCont][7]
				nTotalGeral	:= nTotalGeral 	+ aVerbasRet[nCont][7]
			ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
				nSubLinha	:= nSubLinha 	- aVerbasRet[nCont][7]
				nTotalGeral	:= nTotalGeral 	- aVerbasRet[nCont][7]
			Endif

			nExist := Ascan(aSomaTotal,{ |x| x[1] = aVerbasRet[nCont][3] } )
			IF nExist = 0 .Or. !lAglutPd
				// numero da verba, valor da verba, posicao da coluna a ser impressa
				Aadd(aSomaTotal,{aVerbasRet[nCont][3],aVerbasRet[nCont][7],aVerbas[nPosVerba][2]})
			Else
				aSomaTotal[nExist][2]:= aSomaTotal[nExist][2] + aVerbasRet[nCont][7]
			Endif

			nExist := Ascan(aFilHorAnalSint,{ |x| x[1] = aVerbasRet[nCont][3] } )
			IF nExist = 0 .Or. !lAglutPd
				// numero da verba, valor da verba, posicao da coluna a ser impressa
				Aadd(aFilHorAnalSint,{aVerbasRet[nCont][3],aVerbasRet[nCont][7],aVerbas[nPosVerba][2]})
			Else
				aFilHorAnalSint[nExist][2]:= aFilHorAnalSint[nExist][2] + aVerbasRet[nCont][7]
			Endif
		Next nCont

		// alterado aqui
		If nSinAna == 2  // Horizontal e Analitico       
		    cVrb:= Space(03)
		   	If cPaisLoc == "ANG"
				cLin+=Space( 8 )
			EndIf
			For nCont:= 1 to Len(aVerbasRet)
				nPosVerba:= Ascan(aVerbas,{ |x| x[1] = aVerbasRet[nCont, 3] } )
				If nPosVerba>0
					If cVrb == aVerbasRet[nCont, 3]
						ImpR(cLin, "C")
						If cPaisLoc == "ANG"
							cLin	+= Space(aVerbas[nPosVerba,2]-1)
							cValor	:= AllTrim(CValToChar(Transform( aVerbasRet[nCont, 7], "@E 999,999,999.99")))
							cValor	+= Space(14-Len(cValor))
			   				cLin	:= Space(aVerbas[nPosVerba,2]-1)+cValor
							cValor	:= AllTrim(CValToChar(Transform( xMoeda(aVerbasRet[nCont, 7],1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
							cValor	+= Space(14-Len(cValor))
							cLin	+= Space( 1 )+ cValor
						Else
							cLin	:= SRA->RA_FILIAL + " " + SRA->RA_MAT + " " + Substr(SRA->RA_NOME, 1, 20) + AllTrim(CValToChar(Transform(aVerbasRet[nCont, 7], "@E 999,999,999.99")))
							cValor	:= AllTrim(CValToChar(Transform(aVerbasRet[nCont, 7], "@E 999,999,999.99")))
							cValor	+= Space(14 - Len(cValor))
					    	cLin	+= Space(ABS(aVerbas[nPosVerba, 2] - Len(cLin)) - 1)// + cValor
						Endif
					Else
					   If cPaisLoc == "ANG"
							cValor	:= AllTrim(CValToChar(Transform( aVerbasRet[nCont, 7], "@E 999,999,999.99")))
							cValor	+= Space(14-Len(cValor))
							cLin	+= Space(aVerbas[nPosVerba,2]-2-Len(cLin)-1) + cValor
							cValor	:= AllTrim(CValToChar(Transform( xMoeda(aVerbasRet[nCont, 7],1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
							cValor	+= Space(14-Len(cValor))
							cLin	+= Space( 1 ) + cValor + Space(3)
					    Else
					    	cValor	:= AllTrim(CValToChar(Transform( aVerbasRet[nCont, 7], "@E 999,999,999.99")))
							cValor	+= Space(14-Len(cValor))
					    	cLin	+= Space(ABS(aVerbas[nPosVerba,2]-Len(cLin))-1) + cValor
					    Endif
						cVrb:= aVerbasRet[nCont, 3]
					EndIf
				EndIf
			Next nCont
			If cPaisLoc <> "ANG"
				cValor:= AllTrim(CValToChar(Transform( nSubLinha, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= Space(aVerbas[Len(aVerbas),2]-Len(cLin)-1) + cValor
			Endif
			ImpR( cLin, "C" )
		Endif

	ElseIf nVerHor == 1  // Vertical
		If lPass
			cCCusto	:= SRA->RA_CC
		Endif

		If nSinAna == 2  // Vertical e Analitico
			If !lPass
				If cPaisLoc == "ANG"
					cLin:= "Val Tot.-" + Space(1) // "Valores Totais  - "
                Else
					// Valores Totais  -
					// xxxxxxxxxxxxxxxxxxx
					cLin	:= AllTrim(STR0021)
		   			cLin    += Space(21-Len(cLin))
                Endif
                ImpTotais( @cLin							,; 	// conteudo da linha a ser impresso
                		   nHorasTipo						,;	// horas
                		   nDiasTipo						,;	// dias
                		   nValorProvento					,;	// Provento
                		   nValorDesconto					,;  // desconto
                		   (nValorProvento-nValorDesconto)	,; 	// liquido
                		  )

				nHorasTotal		:= nHorasTotal 		+ nHorasTipo
				nDiasTotal		:= nDiasTotal 		+ nDiasTipo
				nProvento		:= nProvento 		+ nValorProvento
				nDesconto		:= nDesconto 		+ nValorDesconto
				nLiquido		:= nLiquido 		+ (nValorProvento-nValorDesconto)
				nTValorProvento	:= nTValorProvento 	+ nValorProvento
				nTValorDesconto	:= nTValorDesconto 	+ nValorDesconto
				nTHorasTipo		:= nTHorasTipo		+ nHorasTipo
				nTDiasTipo		:= nTDiasTipo		+ nDiasTipo

				nValorProvento	:= 	nValorDesconto	:= 	nHorasTipo	:= 	nDiasTipo	:= 0

				If Alltrim(cCCusto) <> Alltrim(SRA->RA_CC) .Or. _cFilialAnt <> SRA->RA_FILIAL
					ImpR( ""  , "C" )
					ImpR( Replicate("-",Colunas), "C" )

					If cPaisLoc == "ANG"
						cLin:= "Tot.C.C.:" + Space( 1 ) //"Total C.Custo:"
					Else
						// Total C.C:  Centro de Custo
						// xxxxxxxxxx  xxxxxxxxx
						cLin	:= AllTrim(STR0027)+AllTrim(cCCusto)
		   				cLin    += Space(21-Len(cLin))
					Endif

	                ImpTotais( @cLin,; 								// conteudo da linha a ser impresso
    	            		   nTHorasTipo, ;						// horas
        	        		   nTDiasTipo, ;						// dias
            	    		   nTValorProvento, ;					// Provento
                			   nTValorDesconto,;            	    // desconto
                			   (nTValorProvento-nTValorDesconto),; 	// liquido
                			  )
					nTValorProvento	:= 	nTValorDesconto	:= 	nTHorasTipo	:= 	nTDiasTipo	:= 0
					ImpR( Replicate("=",Colunas), "C" )
					ImpR( "", "C" )
					cCCusto	:= SRA->RA_CC
				Endif
			Endif

			dbSelectArea("SRA")
			//                          FILIAL        CENTRO DE CUSTO MATRICULA NOME
			// Com Gestao Coorporativa  xxxxxxxxxxxx  xxxxxxxxx       xxxxxx    xxxxxxxxxxxxxxxxxxxx
			// Sem Gestao Coorporativa  xx            xxxxxxxxx       xxxxxx    xxxxxxxxxxxxxxxxxxxx
			If( fIsCorpManage( FWGrpCompany() ), nEsp:= 30-FwGetTamFilial-1-9, nEsp:= 18)
			cLin:= SRA->RA_FILIAL+" "+cCCusto+Space(nEsp)+aVerbasRet[1][2]+" "+Substr(SRA->RA_NOME,1,20)

			If lSalario
				nSpace := Len( cLin )
				cLin+= Space( 1 ) + STR0028 + Transform( SRA->RA_HRSMES, "@E 99,999.99" ) + ' ' + Transform( SRA->RA_SALARIO, "@E 9,999,999.99" )
				ImpR( cLin, "C" )
				cLin := Space( nSpace )
			Endif

		Else // Vertical e Sintetico
			If aReturn[8] == 2 	// Vertical / Sintetico / Ordem de C.Custo

				If Alltrim(cCCusto) <> Alltrim(SRA->RA_CC) .Or. _cFilialAnt <> SRA->RA_FILIAL
					aVertSintCC:=ASort(aVertSintCC,,,{ |a,b| a[1]+a[2] < b[1]+b[2] })
					//                          FILIAL        CENTRO DE CUSTO DESC CCC
					// Com Gestao Coorporativa  xxxxxxxxxxxx  xxxxxxxxx       xxxxxxxxxxxxxxxxxxxxxxxxx
					// Sem Gestao Coorporativa  xx            xxxxxxxxx       xxxxxxxxxxxxxxxxxxxxxxxxx
					If( fIsCorpManage( FWGrpCompany() ), nEsp:= 0, nEsp:= 2)
						For nCont:= 1 to Len(aVertSintCC)
							cCentroCusto	:= aVertSintCC[nCont][1]
							cDescCentro		:= DescCC(cCentroCusto,xFilial("SRA"),25)
							
							cLin := _cFilialAnt + " " + cCCusto + " " + SubStr(cDescCentro,1,25) + Space(nEsp) // Descrrição do centro de custo vem vazia
							cLin := SubStr(cLin,1,40)
							ImpR(cLin, "C")

							If nCont > 1
								ImpR( Replicate("-",Colunas), "C" )
							Endif

							ImpR("", "C")
							cCentroCusto	:= aVertSintCC[nCont][1]
							cDescCentro		:= DescCC(cCentroCusto,xFilial("SRA"),25)

							While !(nCont > Len(aVertSintCC)) .And. aVertSintCC[nCont][1] == cCentroCusto
								cDescVerba	:= PosSrv( aVertSintCC[nCont][2] , SRA->RA_FILIAL , "RV_DESC" )
								cLin:= aVertSintCC[nCont][2]+ "-" + cDescVerba
								cLin:= SubStr(cLin,1,18)
								cLin := Space( 67 ) + cLin  + If(cPaisLoc == "ANG", Space( 3 ), Space( 5 )) +;
										Transform( aVertSintCC[nCont][3], "@E 999,999,999.99" ) + Space( 2 ) + ;
										Transform( aVertSintCC[nCont][4], "@E 999,999,999.99" ) +;
										If(cPaisLoc == "ANG", Space( 1 ) + Transform(xMoeda(((aVertSintCC[nCont][4])),1,nDolarRH,dDataPgto) , "@E 999,999,999.99" ), "")
								ImpR( cLin, "C")
								// Totalizador de empresa
								_cTpVerba 	:= PosSrv( aVertSintCC[nCont][2],SRA->RA_FILIAL,"RV_TIPOCOD" )
								If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
									nVlCCHr		:= nVlCCHr + aVertSintCC[nCont][3]
									nVlCCVl		:= nVlCCVl + aVertSintCC[nCont][4]
									nVlrTotal	:= nVlrTotal + aVertSintCC[nCont][4]
									nVlrHoras	:= nVlrHoras + aVertSintCC[nCont][3]
									If lImpEmpr
										nRefVertSint	:= nRefVertSint + aVertSintCC[nCont][3]
										nVlrVertSint	:= nVlrVertSint + aVertSintCC[nCont][4]
									EndIf
								ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
									nVlCCHr		:= nVlCCHr - aVertSintCC[nCont][3]
									nVlCCVl		:= nVlCCVl - aVertSintCC[nCont][4]
									nVlrTotal	:= nVlrTotal - aVertSintCC[nCont][4]
									nVlrHoras	:= nVlrHoras - aVertSintCC[nCont][3]
									If lImpEmpr
										nRefVertSint	:= nRefVertSint - aVertSintCC[nCont][3]
										nVlrVertSint	:= nVlrVertSint - aVertSintCC[nCont][4]
									Endif
								Endif
								nCont:= nCont + 1
								If !(nCont > Len(aVertSintCC))
									cLin:= Space(Len(_cFilialAnt+" "+aVertSintCC[nCont][1] + "- "+cDescCentro))
								EndIf
							EndDo
							ImpR( "", "C" )
							// Total de centro de custos  Centro de Custo
							// xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxx
							cLin := AllTrim(STR0029) + " " + cCentroCusto
							cValor:= AllTrim(CValToChar(Transform( nVlCCVl, "@E 999,999,999.99")))
							If cPaisLoc == "ANG"
								cLin+= Space ( 70 )
								cValor:= AllTrim(CValToChar(Transform( nVlCCVl, "@E 999,999,999.99")))
								cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
								cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlCCVl,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
								cLin+=Space(14-Len(cValor))	 + cValor
							Else
								cLin+=Space(14-Len(cValor)) + Space( 71 ) + cValor
							EndIf

							ImpR( cLin, "C" )

							nVlCCHr		:= 0
							nVlCCVl		:= 0
							If nCont < Len(aVertSintCC)
								nCont--
							EndIf
						Next nCont
					ImpR( Replicate("=",Colunas),"C" )
                    aVertSintCC	:= {}

                    If _cFilialAnt <> SRA->RA_FILIAL
		                 // 					   Total de la sucursal    FILIAL
			        	// Com Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxx
						// Sem Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xx
					   	If( fIsCorpManage( FWGrpCompany() ), nEsp:= 107-FwGetTamFilial-1-21, nEsp:= 83)
						cLin := AllTrim(STR0030) + " " + _cFilialAnt + Space(nEsp)
						If cPaisLoc == "ANG"
		      				cLin+= Space( 3 )
							cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
							cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
							cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlrTotal,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
							cLin+=Space(14-Len(cValor))	 + cValor
							ImpR(  cLin , "C" )
		      			Else
		      				cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
							cLin+=Space(14-Len(cValor))
							ImpR(  cLin + cValor, "C" )
		      			Endif

						ImpR( Replicate("-",Colunas),"C" )
						nVlrTotal := 0
						nVlrHoras := 0
                    EndIf
                EndIf

				For nCont:= 1 to Len(aVerbasRet)
					nPosVerba	:= Ascan(aVertSintCC,{ |x| x[1] = SRA->RA_CC .And. x[2] = aVerbasRet[nCont][3] } ) //aVerbasRet[nCont][12] centro de custo
					IF nPosVerba = 0
						// 					centro de custo,verba,valor em referencia,valor da horas
						Aadd(aVertSintCC,{SRA->RA_CC,aVerbasRet[nCont][3],aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
					Else
						aVertSintCC[nPosVerba][3]:= aVertSintCC[nPosVerba][3] + aVerbasRet[nCont][6]
						aVertSintCC[nPosVerba][4]:= aVertSintCC[nPosVerba][4] + aVerbasRet[nCont][7]
					Endif
				Next nCont
			Else
				If _cFilialAnt <> SRA->RA_FILIAL
					// 						   FILIAL        NOME DA FILIAL
			        // Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxxxxxxxxxxx
					// Sem Gestao Coorporativa xx            xxxxxxxxxxxxxxx
					If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15, nEsp:= 18)
					cLin := _cFilialAnt + " " + SM0->M0_FILIAL + Space(nEsp)

					ImpR( cLin, "C" )

					aVerVertSint:= ASort(aVerVertSint,,,{ |a,b| a[1] < b[1] })
					nVlrHoras := nVlrTotal := 0

					For nCont:= 1 to Len(aVerVertSint)
						If Empty(aVerVertSint[nCont][1] )
							loop
						Endif

						cLin := aVerVertSint[nCont][1] + "-" + aVerVertSint[nCont][2]
						cLin := SubStr(cLin,1,18)
						cLin := Space( 67 ) + cLin + Space( 5 )+;
						      	Transform( aVerVertSint[nCont][3], "@E 999,999,999.99" ) + Space( 2 ) + ;
						      	Transform( aVerVertSint[nCont][4], "@E 999,999,999.99" )

						ImpR( cLin, "C" )

						_cTpVerba 	:= PosSrv( aVerVertSint[nCont][1] , SRA->RA_FILIAL , "RV_TIPOCOD" )
						If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
							nVlrTotal	:= nVlrTotal + aVerVertSint[nCont][4]
							nVlrHoras	:= nVlrHoras + aVerVertSint[nCont][3]
							// Totalizador de empresa
							If lImpEmpr
								nRefVertSint	:= nRefVertSint + aVerVertSint[nCont][3]
								nVlrVertSint	:= nVlrVertSint + aVerVertSint[nCont][4]
							EndIf
						ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
							nVlrTotal	:= nVlrTotal - aVerVertSint[nCont][4]
							nVlrHoras	:= nVlrHoras - aVerVertSint[nCont][3]
							// Totalizador de empresa
							If lImpEmpr
								nRefVertSint	:= nRefVertSint - aVerVertSint[nCont][3]
								nVlrVertSint	:= nVlrVertSint - aVerVertSint[nCont][4]
							EndIf
						Endif
					Next nCont
					ImpR( Replicate("-",Colunas), "C" )
					 // 				       Total de la sucursal    FILIAL
		        	// Com Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxx
					// Sem Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xx
				   	If( fIsCorpManage( FWGrpCompany() ), nEsp:= 107-FwGetTamFilial-1-21, nEsp:= 83)
					cLin := AllTrim(STR0030) + " " + _cFilialAnt + Space(nEsp)
					cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))
					ImpR(  cLin + cValor, "C" )
					ImpR( Replicate("-",Colunas), "C" )

				   	aVerVertSint	:= {}
				EndIf

				For nCont:= 1 to Len(aVerbasRet)// somatorio do Vertica Sintetico ordem normal
					nExist := Ascan(aVerVertSint,{ |x| Alltrim(x[1]) = Alltrim(aVerbasRet[nCont][3]) } )
					IF nExist = 0 .Or. !lAglutPd
						cDescrVerbas :=	PosSrv(aVerbasRet[nCont][3],aVerbasRet[nCont][1], "RV_DESC" )
						// numero da verba     , descricao,qtde referencia,valor verba
						Aadd(aVerVertSint,{aVerbasRet[nCont][3],Substr(cDescrVerbas,1,20),aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
					Else
						aVerVertSint[nExist][3]:= aVerVertSint[nExist][3] + aVerbasRet[nCont][6]
						aVerVertSint[nExist][4]:= aVerVertSint[nExist][4] + aVerbasRet[nCont][7]
					Endif
				Next nCont
			Endif

		Endif

		If nSinAna = 2 	// Analitico
			ImpR(cLin, "C")
			For nCont:=1 to Len(aVerbasRet)
				cLin:= aVerbasRet[nCont][3]+ "-" + DescPd(aVerbasRet[nCont][3],aVerbasRet[nCont][1],20)
				cLin:= SubStr(cLin,1,18)
				cLin := Space( 67 ) + cLin  + If(cPaisLoc == "ANG" , Space( 3 ), Space( 5 )) +;
		      	Transform( aVerbasRet[nCont][6], "@E 999,999,999.99" ) + Space( 2 ) + ;
		      	Transform( aVerbasRet[nCont][7], "@E 999,999,999.99" ) + ;
		      	If(cPaisLoc == "ANG", Space( 1 ) + Transform( xMoeda(aVerbasRet[nCont][7],1,nDolarRH,dDataPgto) , "@E 999,999,999.99" ), "")

				ImpR( cLin, "C" )
				nPosVA := Ascan(aVerbasVAnalit,{ |x| x[1] = aVerbasRet[nCont][3] } )
				If nPosVA == 0
					//	codigo da verba,descricao da verba,valor da referencia,valor
					Aadd(aVerbasVAnalit,{aVerbasRet[nCont][3],DescPd(aVerbasRet[nCont][3],aVerbasRet[nCont][1],20),aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
				Else
					aVerbasVAnalit[nPosVA][3]	:= aVerbasVAnalit[nPosVA][3] + aVerbasRet[nCont][6]
					aVerbasVAnalit[nPosVA][4]	:= aVerbasVAnalit[nPosVA][4] + aVerbasRet[nCont][7]
				Endif

				cVerbaStatus:= 	PosSrv(aVerbasRet[nCont][3],aVerbasRet[nCont][1], "RV_TIPO" )

				_cTpVerba 	:= PosSrv( aVerbasRet[nCont][3],SRA->RA_FILIAL,"RV_TIPOCOD" )
				If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
					nValorProvento	:= nValorProvento + aVerbasRet[nCont][7]
				ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
					nValorDesconto	:= nValorDesconto + aVerbasRet[nCont][7]
				Endif

				If cVerbaStatus == "H"
					nHorasTipo	:= 	nHorasTipo + aVerbasRet[nCont][6]
				ElseIf cVerbaStatus == "D"
					nDiasTipo	:= 	nDiasTipo + aVerbasRet[nCont][6]
				Endif
				_cPerAntMat :=  Alltrim(aVerbasRet[nCont][10]+aVerbasRet[nCont][2])
			Next
		Endif
		lPass	:= .f.
	Endif

	If Len(aVerbasRet) > 0

		cCCusto := SRA->RA_CC

	Endif

	_cFilialAnt	:= SRA->RA_FILIAL
	dbSelectArea("SRA")
	dbSkip()

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do valores SubTotais quando o flag estiver para imprimir.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVerHor == 2

	dbSelectArea("SRA")
	// horizontal e Analitico
	If nSinAna == 2       
		// 						   FILIAL        NOME DA FILIAL
        // Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxxxxxxxxxxx
		// Sem Gestao Coorporativa xx            xxxxxxxxxxxxxxx

		If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15, nEsp:= 18)
		ImpR( "", "C" )
		ImpR( Replicate("-",Colunas), "C" )
		cLin	:= _cFilialAnt + " " + SM0->M0_FILIAL
		cLin+=Space(nEsp)

        If(cPaisLoc <> "ANG", nTCont := (Len(aVerbas)-1), nTCont := Len(aVerbas))
		For nCont:= 1 to nTCont
			// alterado aqui
			nTot:= 0
			If ( ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) $ "1*3" .and. lConsBase ) .or. ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) == "1" ) )// soma
				aEval( aFilHorAnalSint, {|x| nTot+= Iif(x[1]==aVerbas[nCont,1], x[2], 0)})
			ElseIf ( ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) $ "2*4" .and. lConsBase ) .or. ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) == "2" ) )// subtrai
				aEval( aFilHorAnalSint, {|x| nTot-= Iif(x[1]==aVerbas[nCont,1], x[2], 0)})
			EndIf
			If cPaisLoc == "ANG"
				cLin+= Space( 2 )
				cValor:= AllTrim(CValToChar(Transform( nTot, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor  + Space( 1 )
				cValor:= AllTrim(CValToChar(Transform( xMoeda(nTot,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor
			Else
				cValor:= AllTrim(CValToChar(Transform( nTot, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor + Space(1)
				nTotal+=nTot
			Endif

		Next nCont
		If cPaisLoc <> "ANG"
			cValor:= AllTrim(CValToChar(Transform( nTotal, "@E 999,999,999.99")))
			cValor+=Space(14-Len(cValor))
			cLin+= cValor + Space(1)
		Endif
        ImpR( cLin, "C" )
	   	ImpR( "", "C" )
		If lImpEmpr
			// Valor total empresa:
			// xxxxxxxxxxxxxxxxxxxx
			cLin	:= AllTrim(STR0031)
			cLin    += Space(36-Len(cLin))

			If cPaisLoc == "ANG"
				nTCont := Len(aVerbas)
			Else
				nTCont := (Len(aVerbas)-1)
			Endif
			For nCont:= 1 to nTCont
				// alterado aqui
				nTot:= 0
				If ( ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) $ "1*3" .and. lConsBase ) .or. ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) == "1" ) )// soma
					aEval( aSomaTotal, {|x| nTot+= Iif(x[1]==aVerbas[nCont,1], x[2], 0)})
				ElseIf ( ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) $ "2*4" .and. lConsBase ) .or. ( PosSrv(aVerbas[nCont,1],xFilial("SRA"),"RV_TIPOCOD" ) == "2" ) )// subtrai
					aEval( aSomaTotal, {|x| nTot-= Iif(x[1]==aVerbas[nCont,1], x[2], 0)})
				EndIf

				If cPaisLoc == "ANG"
				    cLin+= Space( 2 )
					cValor:= AllTrim(CValToChar(Transform( nTot, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLin+= cValor  + Space( 1 )
					cValor:= AllTrim(CValToChar(Transform( xMoeda(nTot,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLin+= cValor
				Else
					cValor:= AllTrim(CValToChar(Transform( nTot, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLin+= cValor + Space(1)
				Endif
			Next nCont
			If cPaisLoc <> "ANG"
				cValor:= AllTrim(CValToChar(Transform( nTotalGeral, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor + Space(1)
			EndIf
			ImpR( Replicate("=",Colunas), "C" )
			ImpR( cLin, "C" )
			ImpR( Replicate("=",Colunas), "C" )
        EndIf
	ElseIf nSinAna == 1 // Sintetico       
		// 						   FILIAL        NOME DA FILIAL
        // Com Gestao Coorporativa xxxxxxxxxxxx  xxxxxxxxxxxxxxx
		// Sem Gestao Coorporativa xx            xxxxxxxxxxxxxxx
		If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15, nEsp:= 18)
		cLin	:= _cFilialAnt + " " + SM0->M0_FILIAL
        cLin+=Space(nEsp)

		If(cPaisLoc <> "ANG", nTCont := (Len(aVerbas)-1), nTCont := Len(aVerbas))
		For nCont:= 1 to nTCont
			nExist := Ascan(aFilHorAnalSint,{ |x| x[1] = aVerbas[nCont][1] } )
			nValor :=0
			For nAux:= nExist+1 to Len(aFilHorAnalSint)
				 If (aVerbas[nCont][1] ==  aFilHorAnalSint[nAux][1])
				 	nValor+=aFilHorAnalSint[nAux][2]
				 EndIf
			Next

			If nExist > 0
				nValor += aFilHorAnalSint[nExist][2]
			Else
			 	nValor := 0
			EndIf
		    If cPaisLoc == "ANG" .And. nVerHor = 2
		    	cLin+= Space( 2 )
	    		cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor  + Space( 1 )
				cValor:= AllTrim(CValToChar(Transform( xMoeda(nValor,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor  + Space( 1 )
			Else
				cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor + Space(1)
				nTotal+=nValor
			Endif
		Next
		If cPaisLoc <> "ANG"
				cValor:= AllTrim(CValToChar(Transform( nTotal, "@E 999,999,999.99")))
				cValor+=Space(14-Len(cValor))
				cLin+= cValor + Space(1)
		Endif
		ImpR( cLin, "C" )

		If lImpEmpr
			ImpR( Replicate("-",Colunas), "C")
			If cPaisLoc == "ANG"
				cLin	:= AllTrim(STR0031)
				If cLin == "Valor total Empresa:"
		        	nColuna := 32 - Len(cLin)
					cLin	+= Space(If(nColuna > 0, nColuna, 1))
				Else
		        	nColuna := 35 - Len(cLin)
					cLin	+= Space(If(nColuna > 0, nColuna, 1))
				Endif
			Else
				// Valor total empresa:
		   		// xxxxxxxxxxxxxxxxxxxx
				cLin	:= AllTrim(STR0031)
		   		cLin    += Space(36-Len(cLin))
			Endif

			If(cPaisLoc <> "ANG", nTCont := (Len(aVerbas)-1), nTCont := Len(aVerbas))
			For nCont:= 1 to nTCont
				nExist := Ascan(aSomaTotal,{ |x| x[1] = aVerbas[nCont][1] } )
				nValor :=0
				For nAux:= nExist+1 to Len(aSomaTotal)
					 If (aVerbas[nCont][1] ==  aSomaTotal[nAux][1])
					 	nValor+=aSomaTotal[nAux][2]
					 EndIf
				Next
				If nExist > 0
					nValor += aSomaTotal[nExist][2]
				Else
					nValor := 0
				EndIf
				If cPaisLoc == "ANG"
					cLin+= Space( 3 )
					cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLin+= cValor  + Space( 1 )
					cValor:= AllTrim(CValToChar(Transform( xMoeda(nValor,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
					cValor+=Space(14-Len(cValor))
					cLin+= cValor
				Else
					cValor:= AllTrim(CValToChar(Transform( nValor, "@E 999,999,999.99")))
		   			cValor+=Space(14-Len(cValor))
					cLin+= cValor + Space(1)
				Endif
			Next
			If cPaisLoc <> "ANG"
				cValor:= AllTrim(CValToChar(Transform( nTotalGeral, "@E 999,999,999.99")))
				cLin+=Space(14-Len(cValor))
				cLin+= cValor + Space(1)
			EndIf
			ImpR( cLin, "C" )
			ImpR( Replicate("=",Colunas), "C")
		Endif
	Endif

ElseIf nVerHor == 1  // Vertical
		nSBHoras	:= nSBHoras 	+ SRA->RA_HRSMES
		nSBSalario	:= nSBSalario 	+ SRA->RA_SALARIO

		If nSinAna == 2  // Vertical e Analitico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rotina para a impressao do SubTotal do centro de custo e do           ³
			//³totalizador da empresa, de acordo com o parametro de total de empresa.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If cPaisLoc == "ANG"
				cLin:= "Val Tot.-" + Space(1) // "Valores Totais  - "
			Else
			   	// Valores Totais  -
				// xxxxxxxxxxxxxxxxxxx
				cLin	:= AllTrim(STR0021)
		   		cLin    += Space(21-Len(cLin))
			Endif

			ImpTotais( @cLin,; 							// conteudo da linha a ser impresso
               		   nHorasTipo, ;					// horas
               		   nDiasTipo, ;						// dias
               		   nValorProvento, ;				// Provento
               		   nValorDesconto,;                 // desconto
               		   (nValorProvento-nValorDesconto),; // liquido
               		  )

			nTValorProvento	:= nTValorProvento 	+ nValorProvento
			nTValorDesconto	:= nTValorDesconto 	+ nValorDesconto
			nTHorasTipo		:= nTHorasTipo		+ nHorasTipo
			nTDiasTipo		:= nTDiasTipo		+ nDiasTipo

			nValorProvento	:= 	nValorDesconto	:= 	nHorasTipo	:= 	nDiasTipo	:= 0

			ImpR( Replicate("-",Colunas), "C" )

			If cPaisLoc == "ANG"
				cLin:= "Tot.C.C.:"+Space(1) //"Total C.Custo:"
			Else
				// Total C.C:  Centro de Custo
				// xxxxxxxxxx  xxxxxxxxx
				cLin	:= AllTrim(STR0027)+AllTrim(cCCusto)
   				cLin    += Space(21-Len(cLin))
			Endif

            ImpTotais( @cLin,; 								// conteudo da linha a ser impresso
            		   nTHorasTipo, ;						// horas
   	        		   nTDiasTipo, ;						// dias
       	    		   nTValorProvento, ;					// Provento
           			   nTValorDesconto,;            	    // desconto
           			   (nTValorProvento-nTValorDesconto),; 	// liquido
           			  )
			nTValorProvento	:= 	nTValorDesconto	:= 	nTHorasTipo	:= 	nTDiasTipo	:= 0
			ImpR( Replicate("=",Colunas), "C" )
			ImpR( "", "C" )

			If lImpEmpr
				ImpR( Replicate("-",Colunas), "C")
   				// Valor total empresa:
				// xxxxxxxxxxxxxxxxxxxx
				cLin	:= AllTrim(STR0031)
				cLin    += Space(36-Len(cLin))
				// codigo da verba,descricao da verba,valor da referencia,valor
				aVerbasVAnalit 	:= ASort(aVerbasVAnalit,,,{|x,y| x[1] < y[1] })
				For nCont:= 1 To Len(aVerbasVAnalit)
					If nCont == 1
						cLin+= Space(67-Len(cLin)) + SubStr(aVerbasVAnalit[nCont][1]+"-"+Substr(aVerbasVAnalit[nCont][2],1,20), 1, 18)+;
						 	   Space( 4 ) + Transform( aVerbasVAnalit[nCont][3], "@E 999,999,999.99")
					Else
						cLin:= Space(67) + SubStr(aVerbasVAnalit[nCont][1]+"-"+Substr(aVerbasVAnalit[nCont][2],1,20), 1, 18)+;
						 	   Space ( 4 ) + Transform( aVerbasVAnalit[nCont][3], "@E 999,999,999.99")
					EndIf
					If cPaisLoc == "ANG"
						cLin+= Space( 1 ) + Transform( aVerbasVAnalit[nCont][4], "@E 999,999,999.99")
						cLin+= + Space( 1 ) + Transform( xMoeda(aVerbasVAnalit[nCont][4],1,nDolarRH,dDataPgto) , "@E 999,999,999.99" )
   				    Else
						cLin+= Space( 2 ) + Transform( aVerbasVAnalit[nCont][4], "@E 999,999,999.99")
   			        Endif
					ImpR( cLin, "C" )
				Next nCont
				ImpR( Replicate("-",Colunas), "C" )
			Endif

		ElseIf nSinAna == 1  // Vertical e Sintetico
			cDescCentro		:= DescCC(cCCusto,_cFilialAnt,25)

			If aReturn[8] == 1
				// 							FILIAL        NOME DA FILIAL
				// Com Gestao Coorporativa  xxxxxxxxxxxx  xxxxxxxxxxxxxxx
				// Sem Gestao Coorporativa  xx            xxxxxxxxxxxxxxx
			   	If( fIsCorpManage( FWGrpCompany() ), nEsp:= 36-FwGetTamFilial-1-15 , nEsp:= 18)
			   	cLin:= _cFilialAnt + " " + SM0->M0_FILIAL + Space(nEsp)

				ImpR(cLin, "C")

				For nCont:= 1 to Len(aVerbasRet)
					nPosVerba	:= Ascan(aVertSintCC,{ |x| x[1] = SRA->RA_CC .And. x[2] = aVerbasRet[nCont][3] } ) //aVerbasRet[nCont][12] centro de custo
					IF nPosVerba = 0
						Aadd(aVertSintCC,{SRA->RA_CC,aVerbasRet[nCont][3],aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
					Else
						aVertSintCC[nPosVerba][3]:= aVertSintCC[nPosVerba][3] + aVerbasRet[nCont][6]
						aVertSintCC[nPosVerba][4]:= aVertSintCC[nPosVerba][4] + aVerbasRet[nCont][7]
					Endif
				Next nCont
		       /* For nCont := 1 to Len(aVertSintCC)
					cDescVerba	:= PosSrv( aVertSintCC[nCont][2] , SRA->RA_FILIAL , "RV_DESC" )
					cLin:= aVertSintCC[nCont][2]+ "-" + cDescVerba
					cLin := SubStr(cLin,1,18)
					cLin:= Space( 67 ) + cLin + If (cPaisLoc == "ANG" , Space( 3 ), Space( 5 )) +;
					       TransForm( aVertSintCC[nCont][3], "@E 999,999,999.99" ) + Space( 2 ) +;
					       TransForm( aVertSintCC[nCont][4], "@E 999,999,999.99" )	+;
					      	If(cPaisLoc == "ANG", Space( 1 ) + Transform(xMoeda(((aVerVertSint[nCont][4])),1,nDolarRH,dDataPgto) , "@E 999,999,999.99" ), "")
					ImpR( cLin, "C")
	            Next nCont  */
				aVerVertSint	:=	ASort(aVerVertSint,,,{ |a,b| a[1] < b[1] })
				aTotVerbs:= aClone(aVerVertSint)
				nVlrHoras := nVlrTotal := 0
				nTotVer:= Len(aVerVertSint)
				For nCont:= 1 to Len(aVerVertSint)
					If Empty(aVerVertSint[nCont][1] )
						loop
					Endif
					//agrupa y suma los conceptos
					If cVerbs != aVerVertSint[nCont][1] .AND. cPaisLoc == "CHI"
						nTotVal := 0  
						nTotHrs := 0	
						 For nTotX:= 1 to Len(aTotVerbs)
						 	If aTotVerbs[nTotX][1] == aVerVertSint[nCont][1]
						 		nTotVal := nTotVal + aTotVerbs[nTotX][4]
								nTotHrs := nTotHrs + aTotVerbs[nTotX][3]
							Else
						 		 Loop
						 	EndIf
						 Next nTotX 
					EndIf
					
					//nTotVal := nTotVal + aVerVertSint[nCont][4]
					//nTotHrs := nTotHrs + aVerVertSint[nCont][3]
					cLin := aVerVertSint[nCont][1] + "-" + aVerVertSint[nCont][2]
					cLin := SubStr(cLin,1,18)
					cLin := Space( 67 ) + cLin  + If(cPaisLoc == "ANG", Space( 3 ), Space( 5 )) +;
					      If(cPaisLoc == "CHI", Transform( nTotHrs, "@E 999,999,999.99" ), Transform( aVerVertSint[nCont][3], "@E 999,999,999.99" )) + Space( 2 ) + ;
					      If(cPaisLoc == "CHI", Transform( nTotVal, "@E 999,999,999.99" ), Transform( aVerVertSint[nCont][4], "@E 999,999,999.99" )) +;
					      	If(cPaisLoc == "ANG", Space( 1 ) + Transform(xMoeda(((aVerVertSint[nCont][4])),1,nDolarRH,dDataPgto) , "@E 999,999,999.99" ), "")

					If cPaisLoc == "CHI"  
					//Imprime el concepto y su total por grupo
						If  cVerbs != aVerVertSint[nCont][1] 
							 ImpR( cLin, "C" )
						EndIf
					Else
							ImpR( cLin, "C" )
					EndIf

					_cTpVerba 	:= PosSrv( aVerVertSint[nCont][1] , xFilial("SRA") , "RV_TIPOCOD" )
					If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
						nVlrTotal	:= nVlrTotal + aVerVertSint[nCont][4]
						nVlrHoras	:= nVlrHoras + aVerVertSint[nCont][3]
						nRefVertSint:= nRefVertSint + aVerVertSint[nCont][3]
						nVlrVertSint:= nVlrVertSint + aVerVertSint[nCont][4]

					ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
						nVlrTotal	:= nVlrTotal - aVerVertSint[nCont][4]
						nVlrHoras 	:= nVlrHoras + aVerVertSint[nCont][3]
						nRefVertSint:= nRefVertSint - aVerVertSint[nCont][3]
						nVlrVertSint:= nVlrVertSint - aVerVertSint[nCont][4]
					Endif
					cVerbs := aVerVertSint[nCont][1]
				Next nCont

				ImpR( Replicate("-",Colunas), "C" )
				 // 				       Total de la sucursal    FILIAL
	        	// Com Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxx
				// Sem Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xx
			   	If( fIsCorpManage( FWGrpCompany() ), nEsp:= 107-FwGetTamFilial-1-21, nEsp:= 83)
				cLin := AllTrim(STR0030) + " " + _cFilialAnt + Space(nEsp)
				If cPaisLoc == "ANG"
					cLin+= Space( 3 )
					cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
					cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlrTotal,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))	 + cValor
					ImpR(  cLin , "C" )
				Else
					cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))
					ImpR(  cLin + cValor, "C" )
				Endif

				ImpR( Replicate("=",Colunas), "C" )

			ElseIf aReturn[8] == 2 	// Vertical / Sintetico / Ordem de C.Custo
				//                          FILIAL        CENTRO DE CUSTO DESC CCC
				// Com Gestao Coorporativa  xxxxxxxxxxxx  xxxxxxxxx       xxxxxxxxxxxxxxxxxxxxxxxxx
				// Sem Gestao Coorporativa  xx            xxxxxxxxx       xxxxxxxxxxxxxxxxxxxxxxxxx
				If( fIsCorpManage( FWGrpCompany() ), nEsp:= 0, nEsp:= 2)
				cLin:= _cFilialAnt + " " + cCCusto + " " + SubStr(cDescCentro,1,25) + Space(nEsp)
				cLin:= SubStr(cLin,1,40)

				cLin := ALLTRIM(cLin)

				ImpR(cLin, "C")

				aVertSintCC:=ASort(aVertSintCC,,,{ |a,b| a[1]+a[2] < b[1]+b[2] })

				For nCont:= 1 to Len(aVertSintCC)
					If nCont > 1
						ImpR( Replicate("-",Colunas), "C" )
					Endif

                    ImpR( "","C")
					cCentroCusto	:= aVertSintCC[nCont][1]
					cDescCentro		:= DescCC(cCentroCusto,xFilial("SRA"),25)
					While !(nCont > Len(aVertSintCC)) .And. aVertSintCC[nCont][1] == cCentroCusto
						cDescVerba	:= PosSrv( aVertSintCC[nCont][2] , SRA->RA_FILIAL , "RV_DESC" )
						cLin := aVertSintCC[nCont][2]+ "-" + cDescVerba
						cLin := SubStr(cLin,1,18)
						cLin := Space( 67 ) + cLin  + If(cPaisLoc == "ANG", Space( 3 ), Space( 5 )) +;
						      	Transform( aVertSintCC[nCont][3], "@E 999,999,999.99" ) + Space( 2 ) + ;
						      	Transform( aVertSintCC[nCont][4], "@E 999,999,999.99" ) +;
					         	If(cPaisLoc == "ANG", Space( 1 ) + Transform(xMoeda(((aVertSintCC[nCont][4])),1,nDolarRH,dDataPgto) , "@E 999,999,999.99" ), "")
						ImpR( cLin, "C")
						// Totalizador de empresa
						_cTpVerba 	:= PosSrv( aVertSintCC[nCont][2],SRA->RA_FILIAL,"RV_TIPOCOD" )
						If ( ( _cTpVerba	$ "1*3" .and. lConsBase ) .or. ( _cTpVerba	== "1" ) )
							nVlCCHr		:= nVlCCHr + aVertSintCC[nCont][3]
							nVlCCVl		:= nVlCCVl + aVertSintCC[nCont][4]
							nVlrTotal	:= nVlrTotal + aVertSintCC[nCont][4]
							nVlrHoras	:= nVlrHoras + aVertSintCC[nCont][3]
							If lImpEmpr
								nRefVertSint	:= nRefVertSint + aVertSintCC[nCont][3]
								nVlrVertSint	:= nVlrVertSint + aVertSintCC[nCont][4]
							EndIf
						ElseIf ( ( _cTpVerba	$ "2*4" .and. lConsBase ) .or. ( _cTpVerba	== "2" ) )
							nVlCCHr		:= nVlCCHr - aVertSintCC[nCont][3]
							nVlCCVl		:= nVlCCVl - aVertSintCC[nCont][4]
							nVlrTotal	:= nVlrTotal - aVertSintCC[nCont][4]
							nVlrHoras	:= nVlrHoras - aVertSintCC[nCont][3]
							If lImpEmpr
								nRefVertSint	:= nRefVertSint - aVertSintCC[nCont][3]
								nVlrVertSint	:= nVlrVertSint - aVertSintCC[nCont][4]
							Endif
						Endif
						nCont:= nCont + 1
						If !(nCont > Len(aVertSintCC))
							cLin:= Space(Len(_cFilialAnt+" "+aVertSintCC[nCont][1] + "- " + cDescCentro))
						EndIf
					EndDo
					ImpR( "", "C" )
					// Total de centro de custos  Centro de Custo
		         	// xxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxx
					cLin := AllTrim(STR0029) + " " + cCentroCusto
					cValor:= AllTrim(CValToChar(Transform( nVlCCVl, "@E 999,999,999.99")))
					If cPaisLoc == "ANG"
						cLin+= Space ( 70 )
						cValor:= AllTrim(CValToChar(Transform( nVlCCVl, "@E 999,999,999.99")))
						cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
						cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlCCVl,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
						cLin+=Space(14-Len(cValor))	 + cValor
					Else
						cLin+=Space(14-Len(cValor)) + Space( 71 ) + cValor
					EndIf

					ImpR( cLin, "C" )

					nVlCCHr		:= 0
					nVlCCVl		:= 0
					If nCont < Len(aVertSintCC)
						nCont--
					EndIf
				Next nCont
				ImpR( Replicate("=",Colunas), "C" )
	            aVertSintCC	:= {}
                // 						   Total de la sucursal    FILIAL
	        	// Com Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxx
				// Sem Gestao Coorporativa xxxxxxxxxxxxxxxxxxxxx   xx
			   	If( fIsCorpManage( FWGrpCompany() ), nEsp:= 107-FwGetTamFilial-1-21, nEsp:= 83)
				cLin := AllTrim(STR0030) + " " + _cFilialAnt + Space(nEsp)
      			If cPaisLoc == "ANG"
      				cLin+= Space( 3 )
					cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
					cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlrTotal,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))	 + cValor
					ImpR(  cLin , "C" )
      			Else
      				cValor:= AllTrim(CValToChar(Transform( nVlrTotal, "@E 999,999,999.99")))
					cLin+=Space(14-Len(cValor))
					ImpR(  cLin + cValor, "C" )
      			Endif
      			ImpR( Replicate("-",Colunas), "C" )
				nVlrTotal := 0
				nVlrHoras := 0
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rotina para somar o total da empresa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lImpEmpr .And. nRefVertSint <> 0 .And. nVlrVertSint <> 0
				// Valor total empresa:
				// xxxxxxxxxxxxxxxxxxxx
				cLin	:= AllTrim(STR0031)
				cLin    += Space(36-Len(cLin))
				//-- Foi retirado a totalizacao de referencia pois esta incoerente na soma dos tipos - horas/dias
				//-- A totalizacao nas variaveis continuam no sistema, pois se o usuario solicitar, bastar ativar o total da variavel nRefVertSint

					If cPaisLoc == "ANG"
						cLin+= Space( 68 )
						cValor:= AllTrim(CValToChar(Transform( nVlrVertSint, "@E 999,999,999.99")))
						cLin+=Space(14-Len(cValor))	 + cValor  + Space( 1 )
						cValor:= AllTrim(CValToChar(Transform( xMoeda(nVlrVertSint,1,nDolarRH,dDataPgto), "@E 999,999,999.99")))
						cLin+=Space(14-Len(cValor))	 + cValor
					Else
						cValor:= AllTrim(CValToChar(Transform( nVlrVertSint, "@E 999,999,999.99")))
						cLin+=Space(14-Len(cValor))
						cLin+= Space( 70 ) + cValor
					Endif

					ImpR( cLin, "C" )
				ImpR( Replicate("=",Colunas), "C" )
			Endif
		Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
Set Filter to
dbSetOrder(1)
ffiltro("GPER101",aFilArray,1/*Exec Filtro*/, 1/*Inicio Exec*/, 1/*Fim Exec*/, .T./*Forc Atual*/) // Executa Filtro
Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³imptotais ºRonan  ³Microsiga           º Data ³  05/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime os totais para diversos niveis                      º±±
±±º          ³                                                            º±±
±±º-----------------------------------------------------------------------º±±
±±ºParametros															  º±±
±±º   cLin   -  contenudo da linha a ser impresso						  º±±
±±º   nHor   -  qtde de horas a ser impressa							  º±±
±±º   nDia   -  qtde de dias a ser impresso							      º±±
±±º   nProv  -  Proventos												  º±±
±±º   nDesc  -  Descontos												  º±±
±±º   nLiq   -  liquido 												  º±±
±±º																		  º±±
±±º																		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ somente neste programa                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTotais(cLin, nHor, nDia, nProv, nDesc, nLiq)

If (nHor>0) .Or. (nDia>0) .Or. (nProv>0) .Or. (nDesc>0) .Or. (nLiq>0)

	If cPaisLoc == "ANG"
		cLin+= STR0022 + Transform( nHor,"@E 9999.99" )
		cLin+= Space( 2 ) + STR0023 + Space( 1 ) + Transform( nDia,"@E 99999" )
		cLin+= Space( 1 ) + Substr(STR0024,1,9) + Space( 1 ) + Transform( nProv,"@E 99,999,999,999.99" )
 		cLin+= Space( 1 ) + "Dolar:" + Space( 1 ) + Transform( xMoeda(nProv,1,nDolarRH,dDataPgto) , "@E 999,999,999.99" )
		cLin+= Space( 1 ) + STR0025  + Space( 1 ) + Transform( nDesc,"@E 999,999,999.99" )
		cLin+= Space( 1 ) + "Dolar:" + Space( 1 ) + Transform( xMoeda(nDesc,1,nDolarRH,dDataPgto) , "@E 999,999,999.99" )
    Else
    	cLin+= STR0022 + Transform( nHor,"@E 9999.99" )
		cLin+= Space( 4 ) + STR0023 + Space( 2 ) + Transform( nDia,"@E 99999" )
		cLin+= Space( 2 ) + Substr(STR0024,1,9) + Space( 1 ) + Transform( nProv,"@E 99,999,999,999.99" )
		cLin+= Space( 2 ) + STR0025 + Space( 1 ) + Transform( nDesc,"@E 999,999,999.99" )
		cLin+= Space( 4 ) + STR0026 + Space( 3 ) + Transform( nLiq,"@E 999,999,999.99" )
	Endif
	ImpR( cLin, "C" )
	ImpR( "", "C" )
EndIf

Return Nil
