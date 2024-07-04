#INCLUDE "FINA840.ch"
#include "PROTHEUS.CH"
#include "FOLDER.CH"
#INCLUDE "FWMVCDEF.CH"                       
#INCLUDE 'FWLIBVERSION.CH' 

#DEFINE _PL_ chr(13)+chr(10)

STATIC aCtbTmp
STATIC lMod2	:= .T.
Static _lMetric	:= Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA840   บAutor  ณGuilherme C. Leal       บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina baseada na FINA840. Serve para gera็ใo de Recibos.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador  ณ Data   ณ   BOPS   ณ  Motivo da Alteracao                	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJ.Aurelio    ณ01/11/01ณNC001503  ณEm atualizacao bancaria, o "if" so a per-ณฑฑ
ฑฑณ             ณ        ณ          ณmite quando nTipo == 2, e a data de baixaณฑฑ
ฑฑณ             ณ        ณ          ณesta pegando do arquivo SEL.             ณฑฑ									
ฑฑณJ.Aurelio    ณ03/12/01ณ11894     ณEm Fa840TudoOk, nao permitit que se ava  ณฑฑ
ฑฑณ             ณ        ณ          ณ-nce p/ segundo processo se data emissao ณฑฑ								
ฑฑณ             ณ        ณ          ณestiver vazia.                           ณฑฑ
ฑฑณSergio F.    ณ20/02/02ณ13395     ณAjuste na emissao do Recibo com o tipo   ณฑฑ
ฑฑณ             ณ        ณ          ณ"EF".                                    ณฑฑ
ฑฑณPaulo Aug.   ณ07/08/02ณ          ณInclusao do Cobrador e Calculo da Comis. ณฑฑ
ฑฑณ             ณ        ณ          ณpara ele                                 ณฑฑ
ฑฑณC.Denardi    ณ19/08/03ณ66207     ณInclusao da opcao de modificar as colun. ณฑฑ
ฑฑณ             ณ        ณ          ณexibidas do SA1,SE1, gravando no profile ณฑฑ
ฑฑณC.Denardi    ณ11/09/03ณ66637     ณRetirar campo Memo do TwBrowse em SA1,SE1ณฑฑ
ฑฑณWagner       ณ08/06/10ณ          ณImplementado campo Naatureza no Recibo   ณฑฑ
ฑฑณMontenegro   ณ        ณ          ณImplementado tributa็ใo e contabiliza็ใo ณฑฑ
ฑฑณ             ณ        ณ          ณdo ITF.                                  ณฑฑ
ฑฑณ             ณ        ณ          ณImplementado consistencia na sele็ใo de  ณฑฑ
ฑฑณ             ณ        ณ          ณBancos X Natureza e Bancos X Tipo Valor  ณฑฑ
ฑฑณRenan        ณ14/03/11ณ          ณARG = Novo painel de resumo de reten็๕es ณฑฑ
ฑฑณGuedes       ณ        ณ          ณe simula็ใo da contabiliza็ใo.		      ณฑฑ
ฑฑณ             ณ        ณ          ณ                                         ณฑฑ
ฑฑณ             ณ        ณ          ณSe agrega localizaci๓n para MEX ya que   ณฑฑ
ฑฑณM.Camargo    ณ22/07/14ณ          ณocasionaba error al referenciar un objetoณฑฑ
ฑฑณ             ณ        ณ          ณSe modifica array aCposFix ya que EL_TIPOณฑฑ
ฑฑณM.Camargo    ณ30/07/14ณ          ณDOC debe permitir alteraci๓n.            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glezณ02/07/15ณPCREQ-4256ณSe eliminan las funciones AjustaSX1(),   ณฑฑ
ฑฑณ             ณ        ณ          ณFA840PGRFix(), fa840SX3Fix() y           ณฑฑ
ฑฑณ             ณ        ณ          ณfa840SX7Fix() que hacen modificacion a   ณฑฑ
ฑฑณ             ณ        ณ          ณdiccionario por motivo de adecuacion a   ณฑฑ
ฑฑณ             ณ        ณ          ณfuentes para nuevas estructura de  SX    ณฑฑ
ฑฑณ             ณ        ณ          ณpara Version 12.                         ณฑฑ
ฑฑณJonathan Glezณ09/10/15ณPCREQ-4261ณMerge v12.1.8                            ณฑฑ
ฑฑณM.Camargo    ณ17/02/17ณMMI-171   ณARG Grabar la Fecha Contable E1_EMIS1    ณฑฑ
ฑฑณ             ณ        ณ          ณal momento de generar un recibo tipo     ณฑฑ
ฑฑณ             ณ        ณ          ณRA, desde la rutina de Cobranza Mod II   ณฑฑ
ฑฑณ             ณ        ณ          ณconesto se visualizan los RA en el       ณฑฑ
ฑฑณ             ณ        ณ          ณinforme de tํtulos por cobrar(FINR130)   ณฑฑ
ฑฑณ             ณ        ณ          ณpara Version 12. R้plica TVMVJL          ณฑฑ
ฑฑณM.Camargo    ณ01/03/17ณMMI-278   ณARG. Se asigna un nuevo n๚mero de        ณฑฑ
ฑฑณ             ณ        ณ          ณrecibo al grabar. R้plica TWKQF6         ณฑฑ
ฑฑณMarco A. Glz ณ21/03/17ณ MMI-4845 ณSe replica issue(MMI-4578 - V11.8), Se   ณฑฑ
ฑฑณ             ณ        ณ          ณelimina mensaje que muestra cada inclu-  ณฑฑ
ฑฑณ             ณ        ณ          ณsion de cheques por recibo. (ARG)        ณฑฑ
ฑฑณMarco A. Glz ณ06/04/17ณ MMI-4476 ณSe replica llamado(TTREB6 - V11.8), El   ณฑฑ
ฑฑณ             ณ        ณ          ณcual prevee la funcionalidad para Certi- ณฑฑ
ฑฑณ             ณ        ณ          ณficados de Retencion SUSS. (ARG)         ณฑฑ
ฑฑณAlf. Medrano ณ18/05/17ณ MMI-5192 ณReplica de MMI-4881 creaci๓n del punto deณฑฑ
ฑฑณ             ณ        ณ          ณentrada para impresion del recibo en funcณฑฑ
ฑฑณ             ณ        ณ          ณFa840Salvar ARG                          ณฑฑ
ฑฑณ             ณ        ณ MMI-5267 ณReplica de MMI-5004 Persistencia en ํtemsณฑฑ
ฑฑณ             ณ        ณ          ณseleccionados en Grid tํtulos fun RefDataณฑฑ
ฑฑณ             ณ        ณ MMI-5367 ณReplica de MMI-5215 correcci๓n asignar   ณฑฑ
ฑฑณ             ณ        ณ          ณnum serie sugerido Func Fa840Salvar  ARG ณฑฑ
ฑฑณ             ณ02/06/17ณ MMI-5192 ณse quita validaci๓n donde asignaba numeroณฑฑ
ฑฑณ             ณ        ณ          ณserie sugerida en func Fa840Salvar       ณฑฑ
ฑฑณ             ณ        ณ          ณSi el n๚m. serie se asigna manual no se  ณฑฑ
ฑฑณ             ณ        ณ          ณactualiza consecutivo en SX5 ARG         ณฑฑ
ฑฑณ             ณ08/06/17ณ MMI-5833 ณse corrige condici๓n que actualiza los   ณฑฑ
ฑฑณ             ณ        ณ          ณn๚m. de serie en SX5 en func Fa840Salvar ณฑฑ
ฑฑณAlf. Medrano ณ09/06/17ณ          ณmerge main vs 12.1.14                    ณฑฑ
ฑฑณL. Samnaiego ณ12/06/17ณ          ณMerge main vs 12.1.14 (MMI-5059)         ณฑฑ
ฑฑณLuis Enriquezณ30/06/17ณMMI-6167  ณ-En metodo AddIndex de clase FWTemporary-ณฑฑ
ฑฑณ             ณ        ณ          ณTable se modifica a 2 caracteres nombre  ณฑฑ
ฑฑณ             ณ        ณ          ณindice, y correccion de validacion en li-ณฑฑ
ฑฑณ             ณ        ณ          ณnea de campo banco cheque si tipo de doc.ณฑฑ
ฑฑณ             ณ        ณ          ณno es CH.                                ณฑฑ
ฑฑณJose Glez  	ณ02/08/17ณ MMI-6508	ณSe modifica la validacion para el campo  ณฑฑ
ฑฑณ          	ณ        ณ        	ณBanco de Cheques, para que no dejar      ณฑฑ
ฑฑณ           	ณ        ณ        	ณintroducir texto manualmente.            ณฑฑ
ฑฑณL. Samaniego ณ03/08/17ณDMICNS-22 ณSi el arreglo aLinBaixa se encuentra     ณฑฑ
ฑฑณ             ณ        ณ          ณvaci๓, se inicializa nuevamente.         ณฑฑ
ฑฑณDora Vega    ณ15/08/17ณDMINA-177 ณSe modifica la funcion FinTipInt en campoณฑฑ
ฑฑณ           	ณ        ณ          ณEL_TIPODOC agregando las opciones: CH=   ณฑฑ
ฑฑณ           	ณ        ณ        	ณCheque;TF=Deposito;EF=Efectivo.(MEX,CHI).ณฑฑ
ฑฑณIvan Gomez   ณ24/10/17ณDMICNS-63 ณSe agrega valiaci๓n si el manejador de BDณฑฑ
ฑฑณ             ณ        ณ          ณes oracle la declaracion de indices se   ณฑฑ
ฑฑณ             ณ        ณ          ณreduce a dos digitos                     ณฑฑ
ฑฑณRaul Ortiz   ณ13/12/17ณDMICNS-649ณSe realizan modificaciones para uso de   ณฑฑ
ฑฑณ             ณ        ณ          ณtablas temporales - arg                  ณฑฑ
ฑฑณOscar Garcia ณ01/06/18ณDMINA-3209ณSe modifica la funcion FinTipInt, para   ณฑฑ
ฑฑณ           	ณ        ณ        	ณlocalizar Tipos de Metodo de Pago, utili-ณฑฑ
ฑฑณ           	ณ        ณ        	ณzados en Peru.                           ณฑฑ
ฑฑณVeronica F   ณ08/10/18ณDMINA-3968ณSe modifica la funcion FinTipInt, para   ณฑฑ
ฑฑณ           	ณ        ณ        	ณlocalizar Tipos de Metodo de Pago, utili-ณฑฑ
ฑฑณ           	ณ        ณ        	ณzados en Colombia.                       ณฑฑ
ฑฑณ  Marco A.   ณ13/12/18ณDMINA-4775ณSe realizan ajustes para realizar la co- ณฑฑ
ฑฑณ           	ณ        ณ        	ณrrecta compensacion entre documentos NF yณฑฑ
ฑฑณ           	ณ        ณ        	ณNCC. (ARG)                               ณฑฑ
ฑฑณM.Camargo    ณ25/04/19ณDMINA-5693ณSe modifica funci๓n RefData para que sielณฑฑ
ฑฑณ           	ณ        ณ        	ณparแmetro Considera sucursal = No, mues- ณฑฑ
ฑฑณ           	ณ        ณ        	ณtre solamente los documentos de las suc- ณฑฑ
ฑฑณ           	ณ        ณ        	ณursal a las cuales tiene permiso el usua-ณฑฑ
ฑฑณ           	ณ        ณ        	ณrio de protheus. El cambio fue solicitadoณฑฑ
ฑฑณ           	ณ        ณ        	ณpara ARG pero se considera aplica para   ณฑฑ
ฑฑณ           	ณ        ณ        	ณtodos los paises.                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Fina840(cNumFatAut,cDadosAdt,aRecAdt,xCabRec,xDocRec,xFormaRec,xOperacao)

	Local lPanelFin 	:= IsPanelFin()
	LOCAL nRecSE1   	:= SE1->(Recno())
	LOCAL nOrdSE1   	:= SE1->(IndexOrd())
	LOCAL nRecSA1   	:= SA1->(Recno())
	LOCAL nOrdSA1   	:= SA1->(IndexOrd())
	LOCAL bRestSE1  	:= { || SE1->(DbSetOrder(nOrdSE1)), SE1->(DbGoTo(nOrdSE1)), SA1->(DbSetOrder(nOrdSA1)), SA1->(DbGoTo(nOrdSA1)) }
	LOCAL cCodCliTit	:= ""
	LOCAL cLojCliTit	:= ""
	LOCAL cCgcCPFTit	:= ""
	LOCAL cNomCliTit	:= ""
	LOCAL cTelCliTit	:= ""
	LOCAL lIncAdt		:= .F.		//Angola
	Local lRet 			:= .T.
	Local nJ			:= 0
	Local nNumTb		:= 9 // n๚mero de tablas asignadas al arreglo aCtbTmp en funci๓n FA840aCtbA

	Static	cMunp := ""

	Private aTotReceb,lDigita,nAtraso,lGeraLanc,lVenc,cArqTrab,nFiltro,cPerg
	Private lCancel		:= .F.
	Private lCarga		:= .F.
	Private lConsSaldo	:= .T.
	Private nRecnoSEY		:= 0
	Private nRecnoSAQ	:= 0
	Private nSaveSX8 	:= GetSX8Len()
	Private aLinSE1_Ori	:= {} 
	Private aLinSA1_Ori := {}
	Private cCliLoj_Ori := ""
	PRIVATE lTrocaDtRef	:= .F.
	Private lCobrador	:= GetNewPar("MV_UTILCOB",.F.)
	Private lGeraDCam	:= (GetNewPar("MV_DIFCAMR","N") == "S")
	Private lTemMon		:= .F.
	Private lPercRA		:= (GetNewPar("MV_PERRA","N") == "S") 
	Private nItensC		:= GETNEWPAR("MV_ITENSC",1)
	Private lTitAd		:= .F.
	private lLinArr 		:= .F.
	Private lFindITF	:= .T.
	Private lRotAuto	:= xCabRec <> Nil
	Private oPanel
	Private oObjBkp
	private cNomObjT := "oTmpTable"
	Private nNumDocNF:=0
	DEFAULT cNumFatAut	:= ""
	DEFAULT cDadosAdt	:= ""
	DEFAULT aRecAdt		:= {}

	//Declara las variables conforme el n๚mero de tablas asignadas al arreglo aCtbTmp en funci๓n FA840aCtbA
	For nJ := 1  to nNumTb 
		Private &(cNomObjT + alltrim(str(nJ))) := NIL
	Next

	/*
	 * Verifica็ใo do processo que estแ configurado para ser utilizado no M๓dulo Financeiro (Argentina)
	 */
	If lMod2
		If lRotAuto
			If !FinModProc(.F.,@cTxtRotAut)
				lRet := .F.
			EndIf
		Else
			If !FinModProc()
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		FINLoad() //Carrega a tabela Modos de Pago padrใo  
	EndIf 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso seja passado um numero de titulo verifica sua existencia.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet .And. !Empty(cNumFatAut)
	   SE1->(DbSetOrder(1))
	   If ! SE1->(DbSeek(xFilial("SE1")+cNumFatAut))
	      Help(" ",1,"EXISTNUM")
	      Eval(bRestSE1)
	      lRet := .F.
	   Else
	      SA1->(DbSetOrder(1))
	      If ! SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
	         Help(" ",1,"EXISTCLI")
	         Eval(bRestSE1)
	         lRet := .F.
	      Else
	         cCodCliTit := SE1->E1_CLIENTE
	         cLojCliTit := SE1->E1_LOJA
	         cCgcCPFTit := SA1->A1_CGC
	         cNomCliTit := SA1->A1_NOME
	         cTelCliTit := SA1->A1_TEL
	      Endif   
	   Endif  
	   If lRet       
	   		Eval(bRestSE1)
	   EndiF
	Endif

	//ANGOLA
	If lRet .And. !Empty(cDadosAdt)
		lIncAdt	:= .T.

		SA1->(DbSetOrder(1))
		If ! SA1->(DbSeek(xFilial("SA1")+cDadosAdt))
			Help(" ",1,"EXISTCLI")
			Eval(bRestSE1)
			lRet := .F.
		Else
			cCodCliTit	:= SA1->A1_COD
			cLojCliTit	:= SA1->A1_LOJA
			cCgcCPFTit	:= SA1->A1_CGC
			cNomCliTit	:= SA1->A1_NOME
			cTelCliTit	:= SA1->A1_TEL
			aRecAdt		:= {}
		Endif	
	Endif

	If lRet    

		cPerg := "FIN87A"

		If SX6->(Dbseek(xfilial("SX6")+"MV_MDCFIN"))
		    lTemMon	:=Iif(!Empty(GETMV("MV_MDCFIN")),.T.,.F.)
		EndIf

		If cPaisLoc<>"BRA"
			lCobrador:= .T.
		EndIf    
		// Verifica se pode ser incluido mov. com essa data
		If  !dtMovFin(dDataBase,,"2")
			lRet := .F.
		EndIf

		//Carrega Pergunte
		If lRet .And. Empty(cNumFatAut) .and. !lIncAdt .AND. FunName()<>'FINA846'.And. !lRotAuto
			If lPanelFin 
		   		If !PergInPanel(cPerg,.T.)
					Return .T.
				Endif
			ElseIf !pergunte(cPerg,.T.) 
		   		lRet := .F.
			Endif
		ElseIf lRet                          
		   pergunte(cPerg,.F.)
		Endif   


		SX3->(DbSetOrder(2))

		If !SX3->(DBSeek("EL_PREFIXO")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_NUMERO"))  .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_PARCELA")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_BANCO"))   .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_AGENCIA")) .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_CONTA"))   .Or. !X3USO(SX3->X3_USADO) .Or. ;
			!SX3->(DBSeek("EL_TIPODOC")) .Or. !X3USO(SX3->X3_USADO)
		
			Alert(STR0097 + CHR(10) + CHR(10) + ; // "Campos obrigat๓rios nใo habilitados. Verifique os campos abaixo: "
					"EL_PREFIXO" + CHR(10) + ;
					"EL_NUMERO"  + CHR(10) + ;
					"EL_PARCELA" + CHR(10) + ;
					"EL_BANCO"   + CHR(10) + ;
					"EL_AGENCIA" + CHR(10) + ;
					"EL_CONTA"   + CHR(10) + ;
					"EL_TIPODOC")
		
			lCancel:=.T.
			SX3->(DbSetOrder(1))
			lRet :=  .F.
		EndIf

		If lRet
			SX3->(DbSetOrder(1))

			cDocCred:=IIf(Empty(mv_par05).Or. !(mv_par05$MV_CRNEG+"|"+MVRECANT),"NCC",mv_par05)

			//ANGOLA
			//Forco o tipo de titulo de adiantamento para o parametro
			If cPaisLoc == "ANG" .and. lIncAdt
				cDocCred := SuperGetMV("MV_TPADTCD",.T.,Substr(MVRECANT,1,3))
			ElseIf cPaisLoc == "MEX"                    
				cDocCred := Substr(MVRECANT,1,3) // Sempre sera tipo RA no mexico
			Endif                    

			lDigita  	:= If( mv_par01==1,.T.,.F.)  // Mostra Lanctos.
			lAglutina	:= If( mv_par02==1,.T.,.F.)  // Aglutina Lanctos.
			lGeraLanc	:= If( mv_par03==1,.T.,.F.)  // Lanctos. On-Line
			lTrocaDtRef := If( mv_par06==1,.T.,.F.)  // Altera Data
			nFiltro		:= mv_par04

		EndIf

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica no Sigamat.acs se o usuario tem acesso เ baixa de titulos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF lRet .And. Versenha(30)
		While !lCancel
			lCancel:=.T.        
			MontaTela(cNumFatAut,cCodCliTit,cLojCliTit,cCgcCPFTit,cNomCliTit,cNomCliTit,cTelCliTit,lIncAdt,aRecAdt)		

			If ! Empty(cNumFatAut) .or. lIncAdt  .or. lRotAuto
			   lCancel := .T.
			Endif   

			If lCarga
				If !SuperGetMv('MV_SERREC') .And. __lSX8
					While ( GetSX8Len() > nSaveSX8 )	
						RollBackSX8()
					Enddo
				EndIf
				Return !lCancel
			EndIf
		Enddo
		If !SuperGetMv('MV_SERREC') .And. __lSX8
			While ( GetSX8Len() > nSaveSX8 )	
				RollBackSX8()
			Enddo
		EndIf
	Else
		lRet := .F.
		If !lRotAuto
			Alert(STR0001) //"Usuario sem permissใo para acesso เ essa rotina, verifique os acessos do usuario no Configurador."
		Else
			cTxtRotAut += STR0001 +" "+ CRLF
		EndIF
	Endif
	// Desabilitar Teclas de Atalho
	If  lRet .And. !lRotAuto
		Set KEY 17 To
		Set KEY 23 To
		Set KEY 12 To
		Set KEY 13 To
	EndIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de operacao do Recibo.            			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function MontaTela(cNumFatAut,cCodCliTit,cLojCliTit,cCgcCPFTit,cNomCliTit,cNomCliTit,cTelCliTit,lIncAdt,aRecAdt)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz a montagem da tela e seus objetos.                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nIndice 	:= 	""
	Local cSeek		:= 	""
	Local cWhi  	:= 	""
	Local cSelec	:= 	""
	Local cCondMca	:= 	""
	Local c_Alias 	:= 	""
	Local nBase		:= 	005
	Local aGrid		:=	{}
	Local aCpos		:=	{}
	Local aTam		:=	{}
	Local nTop := 0
	Local aCposExtra 	:={}
	Local aCposNo :={}
	Local cTitRec
	Local cTitEmis
	Local cTitCli
	Local cTitLoja
	Local cTitCGC
	Local cTitNom
	Local cTitTel
	Local cTitCob
	Local cTitProv
	Local lSalvou	:=	.F.
	Local cWhenRec
	Local aButtons := {}
	Local nY
	Local nX
	Local nI
	Local nZ
	Local nTotSEL := 0
	Local nTotRec := 0
	Local nMoedSE1 := 0
	Local nMoedSEL := 0
	Local nMotivo := 0
	Local nMot := 0
	Local nValSEL := 0
	Local nTitSE1 := 0
	Local nValaPg := 0
	Local nValDes := 0
	Local nValMul := 0
	Local nValJur := 0
	Local nValIRRF := 0
	Local nIRRF := 0
	Local nRecnSE1 := 0
	Local nPosTpDoc	:= 0
	Local nPosRet	:= 0
	Local nPosImp	:= 0
	Local nPosPref	:= 0
	Local nPosParc	:= 0
	Local nPosTipE1	:= 0
	Local nPosEstEF	:= 0 
	Local nPosCFOEF := 0
	Local nPosBasEF	:= 0
	Local nPosAlqEF	:= 0
	Local nPosRetEF	:= 0
	Local nPosConEF	:= 0
	Local nPosNum	:= 0
	Local nPosPreEF	:= 0 
	Local nPosNumEF	:= 0
	Local nPosParEF	:= 0
	Local nPosTipEF	:= 0
	Local nPosMoeda	:= 0
	Local aCertRet	:= {}
	Local aTmpLinRet	:= {}
	Local aInfGet  := Array(9)
	Local cF3Cli := IIf(cPaisLoc=="ARG", "SA1","SA1AZ0")
	Local lPanelFin := IsPanelFin()
	LOCAL lWhenCli  := .T.
	LOCAL bWhenCli  := { || lWhenCli .And. nPanel==1  }
	Local cMasc3 :=	PesqPict("SE1","E1_VALOR",18)
	Local oSerie := Nil
	Local oRecibo := Nil
	Local oRevisao := Nil // Controle de Versionamento de Recibo de Cobran็a
	Local aColsReten	:= {}
	Local aHeadReten	:= {}
	Local aAltReten		:= {}
	Local aListRes		:= {}
	Local aCabRes		:= {}
	Local aCtbRes		:= {}
	Local nPosHdMoed	:= 0
	Local aHeadCtb		:= {}
	Local aColsCtb		:= {}
	Local aAltCtb		:= {}
	Local lRet		:= .T.
	Local bFilt1 	:= {|| ((FJS->FJS_RCOP == "1") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
	Local bFilt2 	:= {|| ((FJS->FJS_RCOP == "2") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
	Local bFilt3 	:= {|| ((FJS->FJS_RCOP == "3") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
	Local cChave	:= xFilial("FJS")
	Local cAlias	:= "FJS"
	Local cCampo	:= "FJS_TIPO" 
	Local nOrder	:= 1  
	Local lRatImp		:= GetMv("MV_RATIMP",.F.,"0")=="0"
	Local lTelaConModII		:= ExistBlock("TelaConModII")
	Local cOrd := ""
	Local cConSer := ""
	//////////////////////////////////////////
	//       Descricao do array aInfGet     //            
	//////////////////////////////////////////
	// 1 => Linha do Get                    //
	// 2 => Coluna do Get                   //
	// 3 => Largura do Get                  //
	// 4 => Altura do Get                   //
	// 5 => Obejto Pai (Macro Executavel)   //
	// 6 => Valid do Get (Macro Executavel) //
	// 7 => When do Get (Macro Executavel)  //
	// 8 => Picture do Get                  //
	// 9 => Inicializador Padrao            //
	//////////////////////////////////////////


	Private cFunName	:= "FINA840"    // Usado pelo Profile
	Private cProfChave	:= "FINA84001"  // Usado pelo Profile
	Private aCposProf	:= {}			// Lista de campos gravados no Profile
	Private cTitSer
	Private lPreRec		:= .F.
	Private nQtMoedas	:= Moedfin()
	Private aMask		:= Array(nQtMoedas)
	Private aTitulo		:= {STR0002,STR0003,STR0004,STR0005,STR0171,STR0172}		//"Recibo [Resumo de Reten็๕es]"##"Resumo [Simula็ใo da Contabiliza็ใo]"
	Private cTipos
	Private aRLocks		:= {}
	Private nPosCli		:= 0
	Private nPosLoja	:= 0
	Private nPosDesc	:= 0
	Private nPosJuros	:= 0
	Private nPosSaldo	:= 0
	Private nPosMulta	:= 0
	Private nPosMotBx	:= 0
	Private nPosImpRet  := 0
	Private nPosTipo
	Private anPosMoed	:= Array(nQtMoedas)
	Private oValOrig
	Private nValOrig	:= 0
	Private oSaldo
	Private nSaldo		:= 0
	Private oMoedOri
	Private cMoedOri	:= ""
	Private oRetCfg
	Private nRetCfg		:= 0
	Private oParciais
	Private nParciais	:= 0
	Private oValAbat
	Private nTotAbat	:= 0
	Private oDescont
	Private nDescont	:= 0
	Private oMulta
	Private nMulta		:= 0
	Private oJuros
	Private nJuros		:= 0
	Private oValRec
	Private nValRec		:= 0   
	Private nValOri		:= 0
	Private oVlEstrang
	Private nValEstr	:= 0
	Private oCorrec
	Private nCorrec		:= 0
	Private aNomeMoed	:= {}
	Private cOrdSEL
	Private bSEL
	Private aCabSEL
	Private cOrdSA1
	Private bSA1
	Private aCabSA1
	Private cOrdSE1
	Private bSE1
	Private aCabSE1
	Private cMoed
	Private aLinMoed	:= Array(nQtMoedas)
	Private nBaxTit
	Private aLinBaixa
	Private oLBBaixa
	Private nPosBx
	Private aTaxa		:= Array(nQtMoedas)
	Private aoCB		:= Array(3)
	Private oOk			:= LoadBitMap(GetResources(), "LBOK")
	Private oNo			:= LoadBitMap(GetResources(), "LBNO")
	Private oNever		:= LoadBitMap(GetResources(), "DISABLE")
	Private oDlgRecibo
	Private oMasterPanel
	Private oPanelTop
	Private oLBMoed
	Private nQtPassos	:= 4
	Private aHeader		:= {}
	Private aCols		:= {}
	Private aLinRet		:= {}
	Private oGetSEL
	Private aHeadSE1
	Private aHeadSA1
	Private aCposSEL	:= {}
	Private aCposSA1	:= {}
	Private aCposSE1	:= {}
	Private nPanel		:= 1
	Private oPesq
	Private cSerie  	:= Criavar("EL_SERIE")
	Private cRecibo  	:= Criavar("EL_RECIBO")
	Private cRevisao	:= ""
	Private cNatureza	:= Criavar("EL_NATUREZ")
	Private lNatureza	:= .F.
	Private dDataRef 	:= dDatabase
	Private cCliente 	:= Space(TamSX3("EL_CLIENTE")[1])
	Private cLoja		:= Space(TamSX3("EL_LOJA")[1])
	Private cCliOri 	:= Space(TamSX3("EL_CLIENTE")[1])
	Private cLojOri		:= Space(TamSX3("EL_LOJA")[1])
	Private cNome		:= Space(TamSX3("A1_NOME")[1])
	Private cCGC		:= Space(TamSX3("A1_CGC")[1])
	Private cContato	:= Space(TamSX3("A1_CONTATO")[1])
	Private cTel		:= Space(TamSX3("A1_TEL")[1])
	Private cLojCli		:= Space(TamSX3("EL_LOJA")[1])
	// Cobrador
	Private cCobrador	:= Space(TamSX3("EL_COBRAD")[1])
	Private cRecProv	:= Space(TamSX3("EL_RECPROV")[1])
	Private cPesq
	Private aLinReceb	:= {}
	Private oLBReceb
	Private aLinBX		:= {}
	Private oLBBx
	Private oMenu
  
	Private cTiposAdm   := ""
	Private oBtn		:= Array(10)
	Private lDecr		:= .F.
	Private aFiltros	:= {"","","",""}
	Private oPDesc
	Private nPercDesc	:= 0
	Private nDescTot	:= 0
	Private nPercGer	:= 0
	Private nDescGer	:= 0
	Private lConsFilial := If(mv_par09==1,.T.,.F.)
	Private nMoedDesc	:= 1
	Private cDiario		:= ""
	Private oAPerc   
	Private nValPerc	:= 0
	Private aPerc		:= {} 
	Private nAliqPerc	:= 0

	Private cMotBx := Space(TamSx3("E5_MOTBX")[1])
	Private cMotBxSE1 := cMotBx
	Private aDescMotbx:={}
	Private aMotbx:={}
	Private aMotbx1:={}
	Private aDadosAdm:={}

	Private nLastPan	:= 4  //ANGOLA - Numero do ultimo painel
	Private cCalcITF   := SuperGetMv("MV_CALCITF",.F.,"2")
	Private aLinSE1 := {}
	Private oRetTit
	Private aColsSEL	:= {}
	Private aHeaderSEL	:= {}
	Private oRetRes
	Private oDtCtb
	Private oLtCtb
	Private dDtCtb		:= ""
	Private cLtCtb		:= ""
	Private oSimCtb
	Private oCtbDeb
	Private oCtbCre
	Private nCtbDeb		:= 0
	Private nCtbCre		:= 0
	Private nTotSE1 := 0
	Private cCredMed	:= ""
	Private cCredInm	:= ""
	Private cCertRet	:= ""
	Private oSize

Private nValRec2	:=0   
Private nSaldo2	:=0
Private nAtoLBSE1	:=0
Private lBax		:= .T.
Private aLinBaixa2 := {}
	DEFAULT cNumFatAut := ""
	DEFAULT cCodCliTit := ""
	DEFAULT cLojCliTit := ""                                             
	DEFAULT cCgcCPFTit := ""
	DEFAULT cNomCliTit := ""
	DEFAULT cTelCliTit := ""

	//ANGOLA - Inclusao de adiantamento
	DEFAULT lIncAdt	:= .F.
	DEFAULT aRecAdt	:= {}

	/*
	* Controle de Versionamento de Recibo de Cobran็a
	*/
	DbSelectArea("SAE")
	cTiposAdm := GetSAETipos()
	DbSelectArea("SEL")
	cRevisao := PADL("0",TamSX3("EL_VERSAO")[1],"0")


	cCredMed	:=	FinGetTipo(bFilt1,cAlias,cChave,cCampo,nOrder)
	cCredInm	:=	FinGetTipo(bFilt2,cAlias,cChave,cCampo,nOrder)
	cCertRet	:=	FinGetTipo(bFilt3,cAlias,cChave,cCampo,nOrder)

	cCredMed	:=	IIf(Empty(cCredMed),GetSESNew("CH","3"),cCredMed)
	cCredInm	:=	IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	cTiposAdm   :=  IIf(Empty(cTiposAdm),"TJ",cTiposAdm)

	If ! Empty(cNumFatAut)
		lWhenCli := .F.
	Endif

	//ANGOLA - Inclusao de adiantamento
	If lIncAdt
		nLastPan := 2
		lWhenCli := .F.	
	Endif

	If cPaisLoc $ "COS|RUS|"
		nQtPassos 	:= 4
		nLastPan	:= 4
	ElseIf !cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG'
		nQtPassos 	:= 5 
		nLastPan	:= 5
	Else	
		nQtPassos 	:= 6 
		nLastPan	:= 6
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณApos declaracao das variaveis, inicia montagem da tela.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	Posicione("SX3",2,"EL_SERIE"	,"X3_TITULO")
	cTitSer := AllTrim(X3TITULO())
	Posicione("SX3",2,"EL_RECIBO"	,"X3_TITULO")
	cWhenRec:=If(Empty(SX3->X3_WHEN),".T.",SX3->X3_WHEN)

	If cPaisLoc $ "BRA#PTG#ANG"
		cTitRec := STR0006 //Recibo
	Else
		cTitRec := AllTrim(X3TITULO())
	Endif

	Posicione("SX3",2,"EL_EMISSAO"	,"X3_TITULO")
	cTitEmis:= AllTrim(X3TITULO())
	Posicione("SX3",2,"EL_CLIENTE"	,"X3_TITULO")
	cTitCli := AllTrim(X3TITULO())
	Posicione("SX3",2,"EL_LOJA"		,"X3_TITULO")
	cTitLoja:= AllTrim(X3TITULO())
	Posicione("SX3",2,"A1_CGC"		,"X3_TITULO")
	cTitCGC := AllTrim(X3TITULO())
	Posicione("SX3",2,"A1_NOME"		,"X3_TITULO")
	cTitNom := AllTrim(X3TITULO())
	Posicione("SX3",2,"A1_TEL"		,"X3_TITULO")
	cTitTel := AllTrim(X3TITULO())
	Posicione("SX3",2,"EL_COBRAD"	,"X3_TITULO")
	cTitCob:= AllTrim(X3TITULO())
	Posicione("SX3",2,"EL_RECPROV","X3_TITULO")
	cTitProv:= AllTrim(X3TITULO())

	If !lRotAuto
		aSize := MSADVSIZE()

		oSize := FwDefSize():New(.T.)                                                      

		oSize:lLateral := .F.

		oSize:AddObject("MASTER",100,100,.T.,.T.)                

		oSize:lProp := .T.

		oSize:Process()

		DEFINE MSDIALOG oDlgRecibo TITLE STR0006 From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //"Recibo"
		odlgRecibo:lMaximized := .T.
	EndIf

	If ExistBlock("F087AF3")
		cF3Cli := ExecBlock("F087AF3",.F.,.F.)
	EndIf	
	If !lRotAuto

		oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),;
		oSize:GetDimension("MASTER","COLINI"),;
		,oDlgRecibo,,,,,,oSize:GetDimension("MASTER","XSIZE"),;
		oSize:GetDimension("MASTER","YSIZE"),.F.,.F.)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณCria campos do cabecalho.   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		oPanelTop := TPanel():New(000,000,,oMasterPanel,,,,,,370,70,.F.,.F.)
		oPanelTop:Align := CONTROL_ALIGN_TOP  

		@ 001, 001 TO 070,390  OF oPanelTop  PIXEL //"Dados Gerais"
		nTop+=003
		If SuperGetMV('MV_SERREC')
			cConSer := POSICIONE("SX3",2,"FJT_SERIE","X3_F3")  
			@ nTop+3,005 SAY STR0140 				Size 040,015 Pixel 	Of oPanelTop  //"Serie/Recibo"  
			@ nTop+1,050 MSGET oSerie Var cSerie	Size 020,008 Pixel 	Of oPanelTop PICTURE PesqPict("SEL","EL_SERIE",TamSX3("EL_SERIE")[1]) F3 Iif(!Empty(cConSer),cConSer,"RN")  Valid Fa840Ser(@cSerie, @cRecibo) HASBUTTON When nPanel==1    
			@ nTop+3,085 SAY OemtoAnsi("-") 							Of oPanelTop PIXEL 
			@ nTop+1,090 MSGET oRecibo Var cRecibo	Size 075,008 Pixel 	Of oPanelTop When (nPanel==1 .And. &(cWhenRec)) Valid {||FA840Vld('cRecibo',cNumFatAut)}  
			/*
			* Controle de Versionamento de Recibo de Cobran็a
			*/
			@ nTop+3,168 SAY STR0203				Size 100,015 Pixel 	Of oPanelTop //"Revisใo"
			@ nTop+1,190 MSGET oRevisao Var cRevisao Size 030,008 Pixel Of oPanelTop WHEN .F.
		Else      
			@ nTop+3,005 SAY cTitRec 				Size 040,015 Pixel 	Of oPanelTop  //"Recibo"
			@ nTop+1,045 MSGET oRecibo Var cRecibo	Size 075,008 Pixel 	Of oPanelTop When  (nPanel==1 .And. &(cWhenRec)) Valid {||FA840Vld('cRecibo',cNumFatAut)}  
			/*
			* Controle de Versionamento de Recibo de Cobran็a
			*/
			@ nTop+3,135 SAY STR0203				Size 120,015 Pixel 	Of oPanelTop //"Revisใo"
			@ nTop+1,160 MSGET oRevisao Var cRevisao Size 030,008 Pixel Of oPanelTop WHEN .F.
		Endif

		nTop+=013

		@ nTop+3,005 SAY cTitEmis 					SIZE 040,015 PIXEL OF oPanelTop   //"Emissao"
		@ nTop+1,035 MSGET oDataRef Var dDataRef	Size 054,008 Pixel Of oPanelTop VALID IIf(dtMovFin(dDataRef,,"2") ,.T.,.F.) When lTrocaDtReF // VALID {|| FAMoedas(dDataRef),RefData(3),".T."}When nPanel==1

		@ nTop+3,100 SAY STR0165 					SIZE 050,015 PIXEL OF oPanelTop   // "Natureza"
		@ nTop+1,130 MSGET cNatureza F3 "SED"		SIZE 085,008 When nPanel==1 Valid F840VldNat(cNatureza,cCalcITF,@lNatureza) PIXEL of oPanelTop HASBUTTON
	EndIf	

	If ! Empty(cNumFatAut) .or. lIncAdt  //ANGOLA
		cCliente	:= cCodCliTit
		cLoja		:= cLojCliTit
		cCGC		:= cCgcCPFTit
		cNome		:= cNomCliTit
		cTel		:= cTelCliTit
	Endif
	If !lRotAuto
		nTop+=013
		@ nTop+3,005 SAY cTitCli 					Size 040,015 Pixel Of oPanelTop		//"Cliente"
		@ nTop+1,035 MSGET oCliente Var cCliente 	Size 050,008 Pixel Of oPanelTop PICTURE	PesqPict("SEL","EL_CLIENTE",TamSX3("EL_CLIENTE")[1]) F3 cF3Cli VALID F840ValCli(@cCliente,@cLoja,cNumFatAut) HASBUTTON When Eval(bWhenCli)
		@ nTop+3,090 SAY cTitLoja 					Size 040,015 Pixel Of oPanelTop		//"Loja"
		@ nTop+1,120 MSGET oLoja Var cLoja			Size 020,008 Pixel Of oPanelTop PICTURE	PesqPict("SEL","EL_LOJA",TamSX3("EL_LOJA")[1]) VALID Iif(ExistCpo("SA1",cCliente+cLoja), (F840ValCli(@cCliente,@cLoja) .And. FA840AtuCli(cNumFatAut)),.F.) When Eval(bWhenCli)
		@ nTop+3,180 SAY cTitCGC					Size 030,015 Pixel Of oPanelTop		//"CGC"
		@ nTop+1,215 MSGET cCGC 					Size 055,008 Pixel Of oPanelTop	PICTURE	PesqPict("SA1","A1_CGC",TamSX3("A1_CGC")[1]) When If(cPaisLoc=="CHI" .and. nPanel==1,.T.,.F.)

		nTop+=013
		@ nTop+3,005 SAY cTitNom 					Size 040,015 Pixel Of oPanelTop		//"Nome"
		@ nTop+1,035 MSGET cNome 					Size 235,008 Pixel Of oPanelTop	When .F.

		nTop+=013
		@ nTop+3,005 SAY cTitTel 					Size 040,015 Pixel Of oPanelTop		//"Tel. "
		@ nTop+1,035 MSGET cTel  					Size 040,008 Pixel Of oPanelTop	PICTURE	PesqPict("SA1","A1_TEL",TamSX3("A1_CGC")[1]) When .F.

		If  lCobrador 
			@ nTop+3,090 SAY cTitCob				Size 040,015 Pixel Of oPanelTop		//Cobrador
			@ nTop+1,120 MSGET cCobrador			Size 050,008 Pixel Of oPanelTop	PICTURE	PesqPict("SEL","EL_COBRAD",TamSX3("EL_COBRAD")[1])	F3 "SAQ" Valid {||FA840Cob("1")} HASBUTTON When nPanel==1
		EndIf

		If cPaisLoc <>"BRA"
			@ nTop+3,180 SAY cTitProv				Size 040,015 Pixel Of oPanelTop		//Recibo Provisorio
			@ nTop+1,215 MSGET cRecProv				Size 075,008 Pixel Of oPanelTop	PICTURE	PesqPict("SEL","EL_RECPROV",TamSX3("EL_RECPROV")[1]) Valid {||FA840Cob("2")} When nPanel==1  //	F3 "SA1" VALID If(CheckSX3("EL_COBRAD",.T.,If(cContato=space(cContato),.t.,.f.)), When nPanel==1
		EndIf
	EndIf
	If  UsaSeqCor()                                                         
		SX3->(DbSetorder(2))
		SX3->(DbSeek("EL_DIACTB"))
		cDiario		:=	Criavar("EL_DIACTB",.T.)          
		cTitDiar	:=	AllTrim(X3TITULO())
		IF !lRotAuto 
			@ nTop+3,305 SAY cTitDiar					Size 040,015 Pixel Of oPanelTop	//Recibo Provisorio
			@ nTop+1,340 MSGET cDiario F3 SX3->X3_F3	Size 020,008 Pixel Of oPanelTop HASBUTTON When CtbWdia() Valid CTBvldDiario(cDiario,dDataBase) 
		EndIf
		SX3->(DbSetorder(1))
	Endif	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณCria barra onde ficarao as informacoes referentes a cada Grid.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	If !lRotAuto 
		If lPanelFin
			oPanBut:= TPanel():New(055,000,,oMasterPanel,,,,,,570,15,.F.,.F.)
			oPanBut:Align := CONTROL_ALIGN_TOP
		Else
			oPanBut:= TPanel():New(087,000,,oMasterPanel,,,,,,370,15,.F.,.F.)
			oPanBut:Align := CONTROL_ALIGN_TOP
			oPanBut:nHeight := 35
		Endif

		@ 000,000 BITMAP oBmp RESNAME "TOOLBAR" NOBORDER ADJUST PIXEL OF oPanBut
		oBmp:Align := CONTROL_ALIGN_ALLCLIENT
		cPesq := Space(50)

		@ 001,251 MSGET oPesq VAR cPesq Size 070,008 Pixel Of oPanBut ON CHANGE FA840Buscar(lIncAdt) When (nPanel < nlastPan .And. nPanel < 4)
		nBase:=001

		If Type("cOrd") == "U"
			cOrd	:= STR0223
		EndIf
		@003,350 SAY STR0222  SIZE 45,8 PIXEL OF oPanBut //Alt. Valor de Baixa
		@001,410 COMBOBOX oCBX VAR cOrd ITEMS {STR0223,STR0224} SIZE 25,15 PIXEL  OF oPanBut WHEN nPanel == 3 // "SIM" "NรO"

		@001,001 BTNBMP oBtn[1] RESOURCE "PREV" 		SIZE 25,25 ACTION (nPanel -= 1,FA840AValPan(nPanel,nLastPan),ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt))				OF oPanBut WHEN nPanel > 1
		@001,030 BTNBMP oBtn[2] RESOURCE "NEXT" 		SIZE 25,25 ACTION (IIF(Fa840TudoOk(cNumFatAut,lIncAdt),(nPanel +=1,ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt)),))	OF oPanBut WHEN nPanel < nLastPan
		@001,070 BTNBMP oBtn[10] RESOURCE "BMPINCLUIR"	SIZE 25,25 ACTION (A840Marca())		   																				OF oPanBut WHEN !lIncAdt .and. nPanel == 2 
		@001,105 BTNBMP oBtn[4] RESOURCE "BMPINCLUIR"	SIZE 25,25 ACTION (A840Sugerir())		   																				OF oPanBut WHEN nPanel == 3 .and. !lIncAdt .And. ValType(aLinSE1[1][Len(aLinSE1[1])-1]) == "N" 
		@001,155 BTNBMP oBtn[5] RESOURCE "PRECO"		SIZE 25,25 ACTION (A840Desconto())		 																				OF oPanBut WHEN (nPanel >= 3 .And. nPanel < 5) .and. !lIncAdt
		@001,374 BTNBMP oBtn[6] RESOURCE "FILTRO"		SIZE 25,25 ACTION (A840Filtrar(nPanel,cNumFatAut))																		OF oPanBut WHEN (nPanel > 1) .And. (nPanel < nLastPan .And. nPanel < 4)
		@001,400 BTNBMP oBtn[7] RESOURCE "VCDOWN"		SIZE 25,25 ACTION (lDecr:=.F.,Fa840Ord(nPanel),oBtn[7]:Hide(),oBtn[8]:Show())	   										OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)
		@001,400 BTNBMP oBtn[8] RESOURCE "VCUP"			SIZE 25,25 ACTION (lDecr:=.T.,Fa840Ord(nPanel),oBtn[8]:Hide(),oBtn[7]:Show())	   										OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)
		@001,645 BTNBMP oBtn[9] RESOURCE "PESQUISA"		SIZE 25,25 ACTION (aoCB[1]:SetFocus(),FA840Buscar(lIncAdt))	   														OF oPanBut WHEN (nPanel < nLastPan .And. nPanel < 4)

		oBtn[1]:cToolTip := STR0022 //"Voltar   (Ctrl+Q)"
		oBtn[2]:cToolTip := STR0023 //"Avancar   (Ctrl+W)"
		oBtn[4]:cToolTip := STR0064 //"Sugerir"
		oBtn[5]:cToolTip := STR0065 //"Desconto Geral"
		oBtn[6]:cToolTip := STR0066 //"Filtrar"
		oBtn[7]:cToolTip := STR0067 //"Ordem Descrescente"
		oBtn[8]:cToolTip := STR0068 //"Ordem Crescente"
		oBtn[9]:cToolTip := STR0024 //"Buscar (Ctrl+L)"
		oBtn[10]:cToolTip :=STR0111 // "Inverte Selecao (Ctrl+M)"
		oBtn[7]:Hide()

		if GetRemoteType() <> 5 //Tratamiento HTML
			SetKEY(17,oBtn[1]:bAction)
		Else
			SetKEY(17,oBtn[1]:bAction)
		Endif
		SetKEY(23,oBtn[2]:bAction)
		SetKEY(12,oBtn[9]:bAction)
		SetKEY(13,oBtn[10]:bAction)
		oPanel := {}
	EndIF
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณDevolve todos os tipos de Titulos validos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	cTipos := GetSESTipos({|| ES_BXRCOP == "1"},"1")  

	cTipos += "/"+MVNOTAFIS+"/"+MVRECANT+"/"+"DP /FT /NV /"
	If Right(Trim(MV_CRNEG),1) == "," //Se encontrar uma virgula retira
		cTipos += Left(Trim(MV_CRNEG),Len(MV_CRNEG)-1)
	Else
		ctipos += Trim(MV_CRNEG)
	EndIf		
	If cPaisloc $ "COS"
		cTipos += "/LTR/"   
	EndIf
	If cPaisloc $ "BRA/PTG"
		cTipos += "/CH /LJ /"   
	Else
		cTipos += "/NDC/DC"   		
	Endif
	If  ExistBLock('A087TIPTI')
		cTipos	+=	ExecBlock('A087TIPTI',.F.,.F.)	
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณCria um panel para cada passo.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	//ANGOLA
	//Nao mostrar a tela de selecao de titulos a baixar
	//na inclusใo de adiantamento
	If lIncAdt 
		aoCB 	:= Array(1)
		nQtPassos := nLastPan
		nI:=1
		aNomeMoed := {}
		For nI := 1 To nQtMoedas
			cTitMoed:= SuperGetMv("MV_MOEDA"+Alltrim(Str(nI)))
			AAdd(aNomeMoed,cTitMoed)
		Next nI
	Endif
	If !lRotAuto
		nx:= 1
		For nx := 1 to nQtPassos
			Aadd(oPanel,TPanel():New(000,000,,oMasterPanel,,,,,,350,110,.F.,.F.))
			nPan := nX
		Next

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤ
	//ณPANEL 1	 ณ
	//ภฤฤฤฤฤฤฤฤฤฤ
	c_Alias 	:= "SEL"
	nIndice 	:= 1
	cSeek		:= "ZZZZZZ"
	cSelec	:= ".F."
	cWhi  	:= ".F."
	nPainel	:= 1

	AAdd(aCposNo,"EL_FILIAL")
	AAdd(aCposNo,"EL_SERIE")
	AAdd(aCposNo,"EL_RECIBO")
	AAdd(aCposNo,"EL_DTDIGIT")
	AAdd(aCposNo,"EL_CANCEL")
	AAdd(aCposNo,"EL_PREREC")
	AAdd(aCposNo,"EL_CLIENTE")
	AAdd(aCposNo,"EL_LOJA")
	AAdd(aCposNo,"EL_VLMOED1")
	AAdd(aCposNo,"EL_COBRAD")
	AAdd(aCposNo,"EL_RECPROV")
	AAdd(aCposNo,"EL_CLIORIG")  
	AAdd(aCposNo,"EL_LOJORIG")
	AAdd(aCposNo,"EL_TPCRED")

	aGrid	:= FA840Head(c_Alias,,.F.,aCposNo)   	//MOnta cabecalho

	aHeader	:=	aClone(aGrid[1])			// Campo + Tamanho + Titulo + Descricoes, etc....
	aCposSEL:=	aClone(aGrid[2])			// Somente campos validos
	aCabSEL	:=	aClone(aGrid[3])			// Somente Titulo dos campos que estao no aCposSEL

	/*Monta a array com os campos que poderao ser alterados */
	ACpoAlter := {}
	aCposFix := {"EL_TPCRED"}//{"EL_TIPODOC","EL_TPCRED"}
	If !lRotAuto
		For nI := 1 To Len(aHeader)
			If Ascan(aCposFix,{|cpo| AllTrim(cpo) == AllTrim(aHeader[nI,2])}) == 0
				Aadd(aCpoAlter,aHeader[nI,2])
			Endif
		Next

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณMonta linhas de acordo com os campos acima definidos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		aCols 	:= MontaGrid(c_Alias,cWhi,cSelec,.F.,".F.",cSeek,nIndice,aCposSEL)

	EndIf

	If cPaisLoc == "ARG"
		aTempSFE := {"FE_EST", "FE_CFO", "A2_AGREGAN", "A2_CONCSUS"} //"FE_VALBASE", "FE_ALIQ", "FE_RETENC"       

		DbSelectArea("SX3")
		DbSetOrder(2)      
		For nX:=1 To Len(aTempSFE)
			DbSeek(aTempSFE[nX])
			AADD(aHeader,{ TRIM(X3TITULO()), x3_campo, x3_picture,x3_tamanho, x3_decimal,x3_valid,x3_usado, x3_tipo, x3_F3, x3_context} ) 
		Next

		nCampos	:=	Len(aCols[1])
		nUsado := Len(aCols) 
		For nI	:= nCampos	 To Len(aHeader)
			If nI == nCampos
				aCols[nUsado,nI] := Criavar(aHeader[nI,2],.F.)
			Else
				aAdd(aCols[1], Criavar(aHeader[nI,2],.F.))	
			EndIF
		Next
		aAdd(aCols[1], .F.)  

		For nI := 1 To Len(aTempSFE)
			Aadd(aCpoAlter,aTempSFE[nI])
		Next
	EndIF

	If !lRotAuto
		Private aRotina := { { "RDMAKE" ,"SIGAIXB", 0 , 3}}
		AADD(aRotina,aClone(aRotina[1]))
		AADD(aRotina,aClone(aRotina[1]))

		oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT

		oGetSEL	:= MSGetDados():New(000,000,109,331,Iif(lCarga,4,1),"Fa840LinOk(.F.)","Fa840TudoOk(cNumFatAut,lIncAdt)",,.T.,aCpoAlter,,.F.,,"a840FldOk()",,,"A840DelLin()",oPanel[nPainel])
		oGetSel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		cOrdSEL	:= aCabSEL[1]
		bSEL	:= {|u| If( PCount() == 0, cOrdSEL, cOrdSEL:= u ) }

		aoCB[1]	:= TComboBox():New(001,205,bSEL,aCabSEL,040,015,oPanBut, ,{||FA840Ord(1,)} , , , ,.t.,,,,)
	EndIF
	//ฺฤฤฤฤฤฤฤฤฤฤ
	//ณPANEL 2	 ณ
	//ภฤฤฤฤฤฤฤฤฤฤ
	//ANGOLA - Inclusao de adiantamentos nao tera a tela de selecao de titulosclientes
	If !lIncAdt
		nIndice	:= 1
		c_Alias 	:= "SA1"
		cSeek	:= "ZZZZZZZZ"
		cWhi  	:= ".F."
		cSelec	:= ".F."
		cCondMca:= ".F."
		nPainel	:= 2

		///////////////////////////////////////////////////////
		// Verifica se existe lista de campos para cliente   //
		// no Profile do usuario, para que possa resgata-la  //
		///////////////////////////////////////////////////////
		If ( FindProfDef(cUserName,cFunName,cProfChave,c_Alias) )
			aCposProf := A840Prof(c_Alias)
			aGrid	  := FA840Head(c_Alias,Aclone(aCposProf),.T.)   	//Monta cabecalho
		Else
			aGrid	:= FA840Head(c_Alias,,.T.)   	//Monta cabecalho
		Endif
		aHeadSA1:= aClone(aGrid[1])
		aCposSA1:= aClone(aGrid[2])
		aCabSA1	:= aClone(aGrid[3])
		aTam	:= aClone(aGrid[4])

		If !lRotAuto
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณMonta linhas de acordo com os campos acima definidos.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			aLinSA1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSA1,lIncAdt)  //ANGOLA
			oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
			oLBCli	:= TwBrowse():New(000,000,000,000,,aCabSA1,aTam,oPanel[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oLBCli:Align := CONTROL_ALIGN_ALLCLIENT
			oLBCli:lColDrag	:= .T.
			oLBCli:nFreeze	:= 1
			oLBCli:SetArray(aLinSA1)
			cBLinSA1:= "{If(aLinSA1[oLBCli:nAt,1]>0,oOk,If(aLinSA1[oLBCli:nAt,1]<0,oNo,oNever))"
			oLBCli:bLDblClick :={ || aLinSA1[oLBCli:nAt,1] := aLinSA1[oLBCli:nAT,1] * -1}
			nI:=2
			For nI:= 2 to Len(aCposSA1)
				c_Picture:= Alltrim(Posicione("SX3",2,aCposSA1[nI],"X3_PICTURE"))
				cBLinSA1:= cBLinSA1 + ", Transform(aLinSA1[oLBCli:nAT][" + alltrim(Str(nI))+ "], '" + c_Picture + "')"
			Next nI
			oLBCli:bLine:= { || &(cBLinSA1 + "}") }

			cOrdSA1 := aCabSA1[2]
			bSA1	:= {|u| If( PCount() == 0, cOrdSA1, cOrdSA1:= u ) }
			aoCB[2]	:= TComboBox():New(001,205,bSA1,aCabSA1,040,015,oPanBut, ,{||FA840Ord(2)} , , , ,.t.,,,,)
		EndIf
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤ
	//ณ PANEL 3	 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤ
	//ANGOLA - Inclusao de adiantamentos nao tera a tela de selecao de titulos
	If !lIncAdt

		c_Alias 	:= "SE1"
		nIndice 	:= 2
		cWhi  	:= ".F."
		cCondMca	:= ".F."
		cSelec	:= ".F."
		cSeek	:= "ZZZZZZZZ"
		nPainel	:= 3	


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณExecblock para poder modificar os campos no Lisbox do SE1.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		If ExistBlock("FA087COL")
			aCpos := ExecBlock("FA087COL",.F.,.F.)
		Else
			///////////////////////////////////////////////////////
			// Verifica se existe lista de campos para titulo    //
			// no Profile do usuario, para que possa resgata-la  //
			///////////////////////////////////////////////////////
			If ( FindProfDef(cUserName,cFunName,cProfChave,c_Alias) )
				aCpos := A840Prof(c_Alias)
			Else
				aCpos	:= {	"E1_PREFIXO","E1_NUM"	,"E1_PARCELA"	,"E1_TIPO"		,"E1_EMISSAO", ;
				"E1_MOEDA"	,"E1_VALOR"	,"E1_SALDO"		,"E1_DESCONT"	,"E1_JUROS", ;
				"E1_MULTA" 	,"E1_VENCREA"}

				DbSelectArea("SX3")
				DbSetOrder(1)
				DbSeek(c_Alias,.F.)
				Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
					If x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. AScan(aCpos,Alltrim(X3_CAMPO))==0 .And. X3_TIPO <> "M"
						AAdd(aCpos,X3_CAMPO)
					Endif
					DbSkip()
				Enddo
			Endif       
		Endif

		///////////////////////////////////////////////////
		// Rastreia aCpos para retirar campos do tipo MEMO
		// Necessario ser desta forma, devido ao ponto de
		//   entrada do usuario, que pode criar a aCols com
		//   campo tipo MEMO
		cAliasBM := Alias()  
		DbSelectArea( "SX3" )
		DbSetOrder(2)
		For nZ := 1 to Len(aCpos)
			DbSeek( Alltrim(aCpos[nZ]) )
			If ( X3_TIPO = "M" )
				Adel( aCpos, nZ )
				Asize( aCpos, Len(aCpos)-1 )
			Endif
		Next nZ
		SX3->(DbSetOrder(1))
		DbSelectArea( cAliasBM )


		aGrid	    := FA840Head(c_Alias,Aclone(aCpos),.T.) //Monta cabecalho
		aHeadSE1	:= aClone(aGrid[1])
		aCposSE1	:= aClone(aGrid[2])
		aCabSE1		:= aClone(aGrid[3])
		aTam		:= aClone(aGrid[4])

		If !lConsFilial
			aAux:=CposToHead({"E1_FILIAL"})
			AEval(aAux,{|x| AAdd(aHeadSE1,x)})
			AAdd(aCposSE1,"E1_FILIAL")
			AAdd(aCabSE1 ,X3Titulo())
			AAdd(aTam    ,12)
		EndIf
		nI := 0
		for nI := 1 to nQtMoedas
			&("nBxMoeda" + Alltrim(Str(nI))) := 0
		Next nI
		nBaixar		:=0
		nDescTot	:=0
		nDescSE1	:=0
		nJurSE1		:=0
		nMultaSE1	:=0
		nImpRetSE1	:= 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณApos montagem dos campos insere campos que sao|
		//ณindispensaveis para o funcionamento da rotina.|
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

		//				 Variavel			Titulo			 		 Tamanho
		AAdd(aCposExtra,{"nBaixar"		,STR0025				,25}) //"Vlr. Baixa"
		AAdd(aCposExtra,{"nDescTot"	,STR0069  			,25}) //Valor de desconto geral, rateado pelo item //"Desc. Geral"
		nI:=0
		for nI:=1 to nQtMoedas
			AAdd(aCposExtra,{"nBxMoeda" + Alltrim(Str(nI)),STR0026 + SuperGetMv("MV_MOEDA"+ Alltrim(Str(nI))),25}) //"Bx "
		Next nI
		AAdd(aCposExtra,{"nDescSE1"	,STR0027					,25,}) //"Descontos"
		AAdd(aCposExtra,{"nJurSE1"		,STR0028					,25,}) //"Juros"
		AAdd(aCposExtra,{"nMultaSE1"	,STR0029					,25,}) //"Multa"
		AAdd(aCposExtra,{"cMotBxSE1"	,Posicione("SX3",2,"E5_MOTBX","X3Titulo()"),25}) //"Motivo da Baixa"
		if  cPaisLoc == "COS"
			AAdd(aCposExtra,{"nImpRetSE1"	,"Imp. Retido",25}) //"Reten็ใo"
		endif	
		nI:=1
		For nI:=1 To Len(aCposExtra)
			AAdd(aCposSE1	,aCposExtra[nI][1])
			AAdd(aCabSE1	,aCposExtra[nI][2])
			AAdd(aTam		,aCposExtra[nI][3])
		Next nI

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณMonta linhas de acordo com os campos acima definidos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		If !lRotAuto
			aLinSE1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.)
			oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
			oLBSE1	:= TwBrowse():New(000,000,000,000,,aCabSE1,aTam,oPanel[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oLBSE1:Align := CONTROL_ALIGN_ALLCLIENT
			oLBSE1:lColDrag	:= .T.
			oLBSE1:nFreeze	:= 1
			oLBSE1:SetArray(aLinSE1)
			cBLinSE1 := "{If(aLinSE1[oLBSE1:nAt,1]>0,oOk,If(aLinSE1[oLBSE1:nAt,1]<0,oNo,oNever))"
			oLBSE1:bLDblClick :={ || A840Pagtos(oLBSE1:nAt,cNumFatAut,(oCBX:nAt == 1))}

			nMx	:= AScan(aCposSE1,"E1_MOEDA")
			nI	:= 2
			For nI:= 2 to Len(aCposSE1)
				nX3:=AScan(aHeadSE1,{|x| Alltrim(x[2])==Alltrim(aCposSE1[nI])})
				If nX3>0 .And. aHeadSE1[nX3][8]=="N" .And. aHeadSE1[nX3][4]>=9
					cPesqPict := Iif(cPaisLoc $ "ARG" .And. Alltrim(aCposSE1[nI]) $ "E1_TXMOEDA", "",",18,IIf(nMx>0,aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nMx)) + "],NIL)")
					cBLinSE1:= cBLinSE1 + ", Transform(aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nI))+ "], PesqPict('SE1',aHeadSE1[" + alltrim(Str(nX3)) + "][2]" + cPesqPict + "))"
				ElseIf Substr(aCposSE1[nI],1,1) == 'n'
					cBLinSE1:= cBLinSE1 + ", Transform(aLinSE1[oLBSE1:nAT][" + Alltrim(Str(nI))+ "],'@R 999,999.99')"
				Else
					cBLinSE1:= cBLinSE1 + ", aLinSE1[oLBSE1:nAT][" + alltrim(Str(nI))+ "]"
				Endif
			Next nI
			oLBSE1:bLine:= { || &(cBLinSE1 + "}") }

			cOrdSE1 := aCabSE1[2]
			bSE1	:= {|u| If( PCount() == 0, cOrdSE1, cOrdSE1:= u ) }
			aoCB[3]	:= TComboBox():New(001,205,bSE1,aCabSE1,040,015,oPanBut, ,{||FA840Ord(3)} , , , ,.t.,,,,)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณMontagem do panel de pagto.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			oPPagto:=TPanel():New(84,100,,oMasterPanel,,,,,,232,150,.F.,.T.)

			nT1:=03
			@ nT1,002 GROUP oGrp1 TO 113+if(cPaisLoc == "COS", 14,0), 116 LABEL OemToAnsi(STR0030) OF oPPagto  PIXEL //"Valores da Baixa" //"Valores da Baixa"
			@ nT1,115 GROUP oGrp1 TO 113+if(cPaisLoc == "COS", 14,0), 230 LABEL " " OF oPPagto  PIXEL

		EndIF
		aMotBx := ReadMotBx()
		For NI := 1 to Len(aMotBx)
			If substr(aMotBx[nI],34,01) == "A" .or. substr(aMotBx[nI],34,01) =="R"
				AADD( aDescMotbx,substr(aMotBx[nI],07,10))				
				AADD (aMotbx1,aMotBx[nI])				
			EndIf
			If cPaisLoc=="ARG" .And. nI == Len(aMotBx)
				aMotBx:=aMotbx1
			EndIf
		Next
		If !lRotAuto
			bMotBx :={|u| If( PCount() == 0, cMotBx, cMotBx:= u ) }
			nT1+=09
			@ nT1,004 SAY OemToAnsi(STR0098) SIZE 53, 07 OF oPPagto PIXEL //"Motivo Baixa"
			oMotBx :=TComboBox():New(nT1,046,bMotBx,aDescMotbx,066,010,oPPagto, , ,{|| F840MotBx()}, , ,.T.,,,,)

			@ nT1,120 SAY OemToAnsi( STR0032 )  SIZE 53,07 OF oPPagto PIXEL //"= a Receber"
			@ nT1,162 MSGET oSaldo VAR nSaldo 	SIZE 66, 10 OF oPPagto PIXEL When .F. Picture cMasc3 //"@E 999,999,999,999.99"
			nT1+=14
			@ nT1,004 SAY OemToAnsi( STR0031 ) SIZE 53, 10 OF oPPagto PIXEL //"Valor Original"
			@ nT1,046 MSGET oValOrig VAR nValorig SIZE 66, 10 OF oPPagto PIXEL When .F. Picture cMasc3 //"@E 999,999,999,999.99"

			@ nT1,120 SAY OemToAnsi( STR0033 ) SIZE 53, 07 OF oPPagto PIXEL //"Moeda Original"
			@ nT1,162 MSGET oMoedOri Var cMoedOri SIZE 66, 10 OF oPPagto PIXEL When .F.
		EndIf 
		aCposBaixa	:={"cMoeda", "nBxMoed"}
		aCabBaixa	:={STR0034, STR0035} //"Moedas"###"Baixar"
		aTamBaixa	:={45,50}
		aLinBaixa	:=Array(nQtMoedas)

		nPosBx := Ascan(aCposSE1,"nBaixar")  
		nValRec:= IIf(!lRotAuto,aLinSE1[oLBSE1:nAt][nPosBx],0)  
		nI:=1
		aNomeMoed := {}
		For nI := 1 To nQtMoedas
			cTitMoed:= SuperGetMv("MV_MOEDA"+Alltrim(Str(nI)))
			AAdd(aNomeMoed,cTitMoed)
			anPosMoed[nI]:=AScan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
			aLinBaixa[nI]:={SuperGetMV("MV_MOEDA"+Alltrim(Str(nI))),iIf(!lRotAuto,aLinSE1[oLBSE1:nAt][anPosMoed[nI]], 0)}
		Next nI  
		IF !lRotAuto
			nT1+=14
			oLBBaixa:=TwBrowse():New(nT1,120,000,000,,aCabBaixa,aTamBaixa,oPPagto,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oLBBaixa:lHScroll:=.F.
			oLBBaixa:lVScroll:= .T. //nQtMoedas>5
			oLBBaixa:nHeight	:=112
			oLBBaixa:nWidth	:=209
			oLBBaixa:SetArray(aLinBaixa)
			oLBBaixa:bLine 	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
			Transform(aLinBaixa[oLBBaixa:nAT][2],PesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT))}}
			oLBBaixa:bLDblClick := {|| DCLBBaixa()}

			nT1+=02
			@ nT1,004 SAY OemToAnsi( STR0102 ) SIZE 53, 10 OF oPPagto PIXEL //"- Abatimentos"
			@ nT1,046 MSGET oValAbat VAR nTotAbat SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F. Picture cMasc3 //"@E 999,999,999,999.99"

			If cPaisLoc == "COS"
				nT1+=14
				@ nT1,004 SAY OemToAnsi( "- " + STR0173 ) SIZE 53, 07 OF oPPagto PIXEL  //"Reten็๕es"
				@ nT1,046 MSGET oRetCfg Var nRetCfg	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3
			EndIf

			nT1+=14
			@ nT1,004 SAY OemToAnsi( STR0036 ) SIZE 53, 07 OF oPPagto PIXEL  //"- Baixas Parciais"
			@ nT1,046 MSGET oParciais Var nParciais	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON When .F.  Picture cMasc3
			nT1+=14
			@ nT1,004 SAY OemToAnsi( STR0037 ) SIZE 53, 07 OF oPPagto PIXEL  //"- Descontos"
			
			If cPaisLoc<>"ARG"
				@ nT1,046 MSGET oDescont VAR nDescont	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1) Picture cMasc3
			Else
				@ nT1,046 MSGET oDescont VAR nDescont	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG ) Picture cMasc3
			EndIf
				
			nT1+=14
			@ nT1,004 SAY OemToAnsi( STR0070 ) 	SIZE 53, 07 OF oPPagto PIXEL //"+ Multa"
			If cPaisLoc<>"ARG"
				@ nT1,046 MSGET oMulta VAR nMulta  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1)Picture cMasc3
			Else
				@ nT1,046 MSGET oMulta VAR nMulta  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG )Picture cMasc3
			EndIf
			nT1+=14
			@ nT1,004 SAY OemToAnsi( STR0038 ) 	SIZE 53, 07 OF oPPagto PIXEL //"+ Juros"
			If cPaisLoc<>"ARG"
				@ nT1,046 MSGET oJuros VAR nJuros  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG .Or. oMotBx:nAt>1)Picture cMasc3
			Else
				@ nT1,046 MSGET oJuros VAR nJuros  		SIZE 66, 10 OF oPPagto PIXEL HASBUTTON ON CHANGE(FAPagtoAtu()) When !(aLinSE1[oLBSE1:nAt][AScan(aCposSE1,"E1_TIPO")]$MVRECANT+"/"+MV_CRNEG )Picture cMasc3
            EndIf
			@ nT1,120 SAY OemToAnsi( STR0039 )  SIZE 53,07 OF oPPagto PIXEL //"Valor a Baixar"
			@ nT1,162 MSGET oValRec VAR nValRec 	SIZE 66, 10 OF oPPagto PIXEL HASBUTTON  WHEN .F. Picture cMasc3

			oPPagto:NCLRPANE:= RGB(233,233,233) //13165800
			DEFINE SBUTTON FROM 128,170  TYPE 1  ACTION (Fa840BaixaOK(cNumFatAut)) OF oPPagto When .T.
			//Se reasigna Valores de los arreglos cuando se da clic en el bot๓n de anular
			DEFINE SBUTTON FROM 128,200  TYPE 2  ACTION (oPPagto:Hide(),oPanBut:lReadOnly:=.F.,oPanel[3]:lReadOnly:=.F.,a840Lock(oLBSE1:nAt,.F.),nValRec	:=	nValRec2,nSaldo	:=	nSaldo2, IIf(nAtoLBSE1 > 0, oLBSE1:nAt := nAtoLBSE1, .T.), aLinBaixa := aClone(aLinBaixa2) ) OF oPPagto When .T.
			oPPagto:Hide()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณ Montagem do PANEL de Descontosณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			oPDesc:=TPanel():New(84,00,,oMasterPanel,,,,,,127,117,.F.,.T.)

			@ 003,001 GROUP oGrp TO 103, 123 LABEL OemToAnsi(STR0027) OF oPDesc  PIXEL  //"Descontos"

			@ 015,005 SAY OemToAnsi( STR0045 ) SIZE 55, 07 OF oPDesc PIXEL  //"Valores expressos em "
			oCBMoed1:= TComboBox():New(015,065,bSEL,aNomeMoed,055,020,oPDesc, ,{|| nMoedDesc:=oCBMoed1:nAt, aInfGet[8]:=PesqPict("SE1","E1_VALOR",18,nMoedDesc), F840Get(aInfGet,@nDescTot)} , , , ,.T.,,,,)

			@ 030,005 SAY OemToAnsi(STR0071) SIZE 60,07	OF oPDesc PIXEL //"Percentual"
			@ 030,065 MSGET oPercDesc Var nPercDesc	SIZE 55,09 	OF oPDesc PIXEL When nDescTot==0 Picture "@R 99.99" HASBUTTON

			@ 045,005 SAY OemToAnsi(STR0072) SIZE 60,07	OF oPDesc PIXEL //"Valor do Desconto"

			// Valoriza array aInfGet com os dados necessarios para a montagem do GET.
			aInfGet[1] := 045
			aInfGet[2] := 065
			aInfGet[3] := 55
			aInfGet[4] := 09
			aInfGet[5] := "oPDesc"
			aInfGet[6] := ".T."
			aInfGet[7] := "nPercDesc == 0"
			aInfGet[8] := PesqPict("SE1","E1_VALOR",18,nMoedDesc)
			aInfGet[9] := nDescTot

			// Cria o get para o campo do desconto geral...
			F840Get(aInfGet,@nDescTot)

			oPDesc:NCLRPANE:= RGB(233,233,233) ///13165800
			DEFINE SBUTTON FROM 104,063  TYPE 1  ACTION (A840OKDesc(cNumFatAut)) OF oPDesc When .T.
			DEFINE SBUTTON FROM 104,093  TYPE 2  ACTION (oPDesc:Hide(),oPanBut:lReadOnly:=.F.,oPanel[nPainel]:lReadOnly:=.F.) OF oPDesc When .T.

			oPDesc:Hide()
		EndIF
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณ PANEL 4	- Resumo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	nPainel	:= If(lIncAdt,2,4)
	If !lRotAuto
		nT1		:= 003
		aSize := MSADVSIZE()
		nRight 	:= ((aSize[5]/2)-330)/2  

		@ nT1,001+nRight GROUP oGrp3 TO 085,168+nRight LABEL OemToAnsi(STR0040) OF OPANEL[nPainel]  PIXEL  //"Valores Recebidos"
		@ nT1,172+nRight GROUP oGrp4 TO 085,340+nRight LABEL OemToAnsi(STR0041) OF OPANEL[nPainel]  PIXEL  //"Titulos Baixados"
		@ 088,001+nRight GROUP oGrp5 TO 109,340+nRight 							OF OPANEL[nPainel]  PIXEL

		aCabRec	:={STR0042, STR0043 } //"Tipo"###"Valor"
		aTamRec	:={050,060}
		AAdd(aLinReceb,{"",0})

		oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT
		oLBReceb := TwBrowse():New(012,004+nRight,000,000,,aCabRec,aTamRec,OPANEL[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLBReceb:SetArray(aLinReceb)
		oLBReceb:bLine 	:= { ||{aLinReceb[oLBReceb:nAT][1], Transform(aLinReceb[oLBReceb:nAT][2],cMasc3) }}
		oLBReceb:lHScroll	:= .F.
		oLBReceb:nHeight	:= 140
		oLBReceb:nWidth		:= 320

		aCabBx	:={STR0042, STR0043 } //"Tipo"###"Valor"
		aTamBx	:={050,060}

		AAdd(aLinBX,{"",0})
		oLBBx := TwBrowse():New(012,175+nRight,000,000,,aCabBx,aTamBx,OPANEL[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLBBx:SetArray(aLinBx)
		oLBBx:bLine 	:= { ||{aLinBX[oLBBx:nAT][1], Transform(aLinBX[oLBBx:nAT][2],cMasc3) }}
		oLBBx:lHScroll	:= .F.
		oLBBx:nHeight	:= 140
		oLBBx:nWidth	:= 320
	EndIF
	nTotal:=0
	nTotalBx:=0

	If !lRotAuto
		@ 096,005+nRight SAY OemToAnsi( STR0044 )	SIZE 020,007 OF OPANEL[nPainel] PIXEL  //"Saldo Final"
		@ 093,035+nRight MSGET oTotal Var nTotal	SIZE 070,009 OF OPANEL[nPainel] PIXEL When .F.  Picture cMasc3
		@ 096,175+nRight SAY OemToAnsi( STR0045 ) 	SIZE 040,007 OF OPANEL[nPainel] PIXEL  //"Valores expressos em "
	EndIF

	FAMoedas(dDataRef,cNumFatAut)
	If !lRotAuto
		oCBMoed:= TComboBox():New(093,220+nRight,bSEL,aNomeMoed,070,020,oPanel[nPainel], ,{||RefData(If(lIncAdt,2,4),cNumFatAut,lIncAdt)} , , , ,.t.,,,,)
	EndIf	
	//ฺฤฤฤฤฤฤฤฤฤฤ
	//ณ PANEL 5 ณ
	//ภฤฤฤฤฤฤฤฤฤฤ

	//Cria o painel do resumo de reten็๕es
	If cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG|MEX|EUA|CHI|' .And. !lRotAuto
		nPainel	:= 5

		aSize 	:= MSADVSIZE()
		nRight	:=((aSize[5]/2)-330)/2

		@ 003,001+nRight GROUP oGrp7 TO 109,340+nRight Label STR0173	OF OPANEL[nPainel]  PIXEL		//"Reten็๕es"
		@ 115,001+nRight GROUP oGrp8 TO 182,340+nRight Label STR0174 	OF OPANEL[nPainel]  PIXEL		//"Resumo de reten็๕es"

		oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT

		//Cria aHeader e campos editaveis do quadro de reten็๕es
		aHeadReten	:= {}
		aAltReten	:= {}
		For nX := 1 To Len(aHeader)
			If (AllTrim(aHeader[nX,2]) $ "EL_TIPODOC|EL_PREFIXO|EL_NUMERO|EL_PARCELA|EL_VALOR|EL_EMISSAO|EL_DTVCTO|")
				AADD(aHeadReten,aHeader[nX])
				If (AllTrim(aHeader[nX,2]) == "EL_VALOR")
					AADD(aAltReten,aHeader[nX,2])		//Adiciona o campo VALOR no array de campos editแveis
					aHeadReten[Len(aHeadReten),6] := "Positivo() .And. NaoVazio()"		//Altera a valida็ใo do campo VALOR
					If cPaisLoc == "ARG" 
						aHeadReten[Len(aHeadReten),6] := "Positivo() .And. NaoVazio() .And. GetValRet()"	
					EndIf
				EndIf
			EndIf
		Next nX	

		//Cria coluna de moeda
		nPosHdMoed := ASCAN(aHeader,{|aCpo| AllTrim(aCpo[2]) == "EL_MOEDA" })
		AADD(aHeadReten,aHeader[nPosHdMoed])

		//Cria coluna de ordena็ใo das reten็๕es
		AADD(aHeadReten,{STR0204 ,"ORDEM","@E 9",1,0,"","","N","",""}) // "Ord. Ret."

		//Cria aCols do quadro de reten็๕es
		aColsReten := Array(1,Len(aHeadReten)+1)
		For nX := 1 To (Len(aHeadReten)-1)
			aColsReten[1,nX] := CriaVar(aHeadReten[nX,2])
		Next nX
		aColsReten[1,Len(aHeadReten)]	:= 9
		aColsReten[1,Len(aHeadReten)+1] := .F.

		//Browse das reten็๕es
		oRetTit := MsNewGetDados():New(012,005+nRight,106,337+nRight,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()", ,aAltReten,000,999,"FA840RetVld()","","AllwaysTrue()",oPanel[nPainel],aHeadReten,aColsReten)
		oRetTit:Refresh()

		//Cria aHeader do quadro de resumo das reten็๕es
		aCabRes := {STR0175,STR0176}		//"Descricao"##"Valor"

		//Cria aCols do quadro de resumo das reten็๕es
		aListRes := {}
		If cPaisLoc $ "URU|BOL"
			Aadd(aListRes,{STR0217   ,0})       //"IRIC"
			Aadd(aListRes,{STR0218	,0})       //"IR"
			Aadd(aListRes,{STR0181	,0})       //"TOTAL"	
		ElseIf cPaisLoc == "PTG"
			Aadd(aListRes,{STR0177	,0})       //"IVA"
			Aadd(aListRes,{STR0219   ,0})       //"IRC"
			Aadd(aListRes,{STR0181	,0})       //"TOTAL"
		ElseIf cPaisLoc == "ANG"
			Aadd(aListRes,{STR0220	,0})        //"RIE"	
			Aadd(aListRes,{STR0181	,0})	    //"TOTAL"
		ElseIf cPaisLoc == "PER"
			Aadd(aListRes,{STR0221	,0})       //"IGV"
			Aadd(aListRes,{STR0218	,0})       //"IR"
			Aadd(aListRes,{STR0181	,0})	    //"TOTAL"	
		ElseiF cPaisLoc == "ARG"
			AADD(aListRes,{STR0177	,0})		//"Reten็ใo de IVA"
			AADD(aListRes,{STR0178	,0})		//"Reten็ใo de Ganancias"
			AADD(aListRes,{STR0179	,0})		//"Reten็ใo de Ingressos Brutos"
			AADD(aListRes,{STR0180	,0})		//"Reten็ใo de SUSS"
			If SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0
				AADD(aListRes,{STR0231	,0})		//"Reten็ใo de Municipal"	
			Endif 
			AADD(aListRes,{STR0181	,0})		//"TOTAL"
		EndIf
		oRetRes := TwBrowse():New(124,005+nRight,000,000+nRight,,aCabRes,{200,100},oPanel[nPainel],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oRetRes:SetArray(aListRes)
		oRetRes:lHScroll:= .F.
		If Len(aListRes) > 0
			oRetRes:bLine	:= {|| { oRetRes:aArray[oRetRes:nAt][1], LTrim(Transform(oRetRes:aArray[oRetRes:nAt][2],PesqPict("SEL","EL_VALOR",TamSX3("EL_VALOR")[1]))) } }
		EndIf
		oRetRes:nHeight	:= 110
		oRetRes:nWidth	:= 525+nRight
		oRetRes:Refresh()
	EndIf	

	If !(cPaisLoc $ "COS|RUS") .And. !lRotAuto
		//ฺฤฤฤฤฤฤฤฤฤฤ
		//ณ PANEL 6 ณ
		//ภฤฤฤฤฤฤฤฤฤฤ
		//Cria o painel da simula็ใo da contabiliza็ใo
		nPainel := If( !cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG',5,6)
		aSize 	:= MSADVSIZE()
		nRight	:=((aSize[5]/2)-330)/2

		@ 003,001 GROUP oGrp9 TO ((aSize[6]/2)-80),((aSize[5]/2)) Label STR0188	OF OPANEL[nPainel]  PIXEL		//"Simula็ใo dos lan็amentos contแbeis"

		oPanel[nPainel]:Align := CONTROL_ALIGN_ALLCLIENT

		dDtCtb := ""
		cLtCtb := ""

		@ 017,005 SAY OemToAnsi(STR0183)	SIZE 020,015 OF OPANEL[nPainel] PIXEL  //"Data"
		@ 015,030 MSGET oDtCtb Var dDtCtb	SIZE 040,008 OF OPANEL[nPainel] PIXEL When .F.  Picture PesqPict("CT2","CT2_DATA",8,1)
		@ 017,090 SAY OemToAnsi(STR0184)	SIZE 020,015 OF OPANEL[nPainel] PIXEL  //"Lote"
		@ 015,115 MSGET oLtCtb Var cLtCtb	SIZE 040,008 OF OPANEL[nPainel] PIXEL When .F.

		oDtCtb:CtrlRefresh()
		oLtCtb:CtrlRefresh()

		//Cria aHeader da simula็ใo da contabiliza็ใo
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbGoTop()
		SX3->(dbSeek("CT2"))
		While !EoF() .And. AllTrim(SX3->X3_ARQUIVO) == "CT2"
			If (!(AllTrim(SX3->X3_CAMPO) $ "CT2_FILIAL|CT2_DATA|CT2_LOTE|CT2_SBLOTE|CT2_DOC|CT2_MOEDLC|") .And. X3USO(SX3->X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. (Upper(AllTrim(SX3->X3_CONTEXT)) != "V")) .Or. (AllTrim(SX3->X3_CAMPO) $ "CT2_LINHA|")
				AADD(aHeadCtb, {TRIM(X3TITULO()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
			EndIf
			dbSkip()
		EndDo

		//Cria aCols da simula็ใo da contabiliza็ใo
		aColsCtb := Array(1,Len(aHeadCtb)+1)
		aColsCtb[1,Len(aHeadCtb)+1] := .T.

		//MsNewGetDados da simula็ใo da contabiliza็ใo
		aAltCtb := {}	
		oSimCtb := MsNewGetDados():New(035,005,290,465+nRight,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()", , aAltCtb,000,999,"AllwaysTrue()","","AllwaysTrue()",oPanel[nPainel],aHeadCtb,aColsCtb)
		oSimCtb:Refresh()

		nCtbDeb := 0
		nCtbCre := 0

		@ 302,005 SAY OemToAnsi(STR0185)	SIZE 040,015 OF OPANEL[nPainel] PIXEL  //"Total D้bito"
		@ 300,050 MSGET oCtbDeb Var nCtbDeb	SIZE 100,008 OF OPANEL[nPainel] PIXEL When .F.  Picture PesqPict("CT2","CT2_VALOR",17,1)
		@ 302,200 SAY OemToAnsi(STR0186)	SIZE 040,015 OF OPANEL[nPainel] PIXEL  //"Total Cr้dito"
		@ 300,250 MSGET oCtbCre Var nCtbCre	SIZE 100,008 OF OPANEL[nPainel] PIXEL When .F.  Picture PesqPict("CT2","CT2_VALOR",17,1)

		oCtbDeb:CtrlRefresh()
		oCtbCre:CtrlRefresh()
	EndIf

	If !lRotAuto
		OPANEL[nPainel]:NCLRPANE:= RGB(233,233,233) //13165800

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณ INICIALIZA TELA	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

		ShowPanel(1,@oPanel,cNumFatAut,lIncAdt)

		// Botoes
		Aadd( aButtons, {"RPMDES",{ || A840CFG() }, STR0128,STR0145} ) // "Configurador de campos" ###"Config."
	EndIf

	If ! Empty(cNumFatAut)
		FA840AtuCli(cNumFatAut)
	Endif 
	If lTelaConModII
		nLastPan:=ExecBlock("TelaConModII",.F.,.F.,{nLastPan})
	EndIf 

	If !lRotAuto	
		If lPanelFin
			ACTIVATE DIALOG oDlgRecibo ON INIT (IIf(Type("bFunAuto") == "B", Eval(bFunAuto), ), FaMyBar(oDlgRecibo, {|| MsAguarde({|| lRet := lSalvou := FA840RetOk(nPanel,nLastPan) .And. Fa840Salvar(NIL,NIL,cNumFatAut,lIncAdt,aRecAdt)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| MsAguarde({|| Fa840Cancel(nPanel,nLastPan)}),oDlgRecibo:End()},aButtons))
		Else
			ACTIVATE DIALOG oDlgRecibo ON INIT (IIf(Type("bFunAuto") == "B", Eval(bFunAuto), ), EnchoiceBar(oDlgRecibo, {|| MsAguarde({|| lRet := lSalvou := FA840RetOk(nPanel,nLastPan) .And. Fa840Salvar(NIL,NIL,cNumFatAut,lIncAdt,aRecAdt)}),If(lSalvou,oDlgRecibo:End(),Nil) },{|| MsAguarde({|| Fa840Cancel(nPanel,nLastPan)}),oDlgRecibo:End()},,aButtons))
		Endif
	Else   
		cRecibo		:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_RECIBO"})][2]
		cSerie		:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_SERIE"})][2]
		cCliente	:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_CLIENT"})][2]
		cLoja		:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_LOJA"})][2]
		cNatureza	:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_NATURE"})][2]
		cCobrador	:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_COBRAD"})][2]
		cRecProv	:= xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "FJT_RECPRV"})][2]
		nPosDesc	:= AScan(aCposSE1,"nDescSE1")
		nPosJuros	:= AScan(aCposSE1,"nJurSE1")
		nPosMulta	:= AScan(aCposSE1,"nMultaSE1")
		nPosSaldo	:= AScan(aCposSE1,"E1_SALDO")
		nPosMotBx	:= AScan(aCposSE1,"cMotBxSE1")  
		Aadd(aCposSE1,"nImpRetSE1")
		nPosImpRet	:= ASCAN(aCposSE1,"nImpRetSE1") 
		nPosValBx	:= AScan(aCposSE1,"nBaixar")  
		nMoedSE1	:= AScan(aCposSE1,"E1_MOEDA")
		nTotSE1		:= 0
		nTotSEL		:= 0
		nTotRec		:= 0 
		MV_PAR05	:= IIF(Ascan(xCabRec,{|x| AllTrim(x[1]) == "TMP"}) > 0, xCabRec[Ascan(xCabRec,{|x| AllTrim(x[1]) == "TMP"})][2] ,)
		Aadd(aCols,Array(Len(aHeader)+1))

		For nZ := 1 to Len(xFormaRec)   
			If nZ > 1
				Aadd(aCols,Array(Len(aHeader)+1))   
			EndIf
			nValSEL := AScan(xFormaRec[nZ],{|x| AllTrim(x[1]) == "EL_VALOR"})
			nMoedSEL := AScan(xFormaRec[nZ],{|x| AllTrim(x[1]) == "EL_MOEDA"})
			nPosNum := AScan(xFormaRec[nZ],{|x| AllTrim(x[1]) == "EL_NUMERO"})
			nPosRet := Ascan(xFormaRec[nZ],{|formarec| formarec[1] == "RET"})
			For nY:=1 to Len(aHeader)	
				For nX:=1 to Len(xFormaRec[nZ])
					If Alltrim(xFormaRec[nZ][nX][1]) == Alltrim(aHeader[nY][2]) 	  		
						If Alltrim(aHeader[nY][8]) == "C"
							aCols[nZ][nY] :=  Padr(xFormaRec[nZ][nX][2],aHeader[nY][4] )  
						Else 
							aCols[nZ][nY] :=  xFormaRec[nZ][nX][2]
						EndIf	
						If Alltrim(aHeader[nY][2])  $  "EL_TIPO/EL_TIPODOC/EL_NUMERO/EL_VALOR/EL_MOEDA/EL_EMISSAO"  
							If 	Empty(aCols[nZ][nY])
								cTxtRotAuto += aHeader[nY][2] + "  :=  " + STR0230 // "    ----> Campo obrigat๓rio. "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
								lMsErroAuto := .T.
								lRet:= .F.  
								Exit      
							Else
								If Alltrim(aHeader[nY][2]) == "EL_TIPODOC"			/* agrupo os documentos de retencao */
									If Upper(Alltrim(aCols[nZ,nY])) $ "RS|RL|RB|RI|RG"
										Aadd(aTmpLinRet,{Upper(Alltrim(aCols[nZ,nY])),xFormaRec[nZ,nPosNum,2],xFormaRec[nZ,nValSel,2],xFormaRec[nZ,nMoedSel,2],{}})
										If cPaisLoc == "ARG"
											If !lRatImp
												If nPosRet > 0
													nPosEstEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "FE_EST"}) 
													nPosCFOEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "FE_CFO"})
													nPosBasEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "FE_VALBASE"})
													nPosAlqEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "FE_ALIQ"})
													nPosRetEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "FE_RETENC"})
													If Upper(Alltrim(aCols[nZ,nY])) == "RS"
														nPosConEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "A2_CONCSUS"})
													ElseIF  Upper(Alltrim(aCols[nZ,nY])) == "RG"
														nPosConEF := Ascan(xFormaRec[nZ,nPosRet,2],{|x| Upper(AllTrim(x[1])) == "A2_AGREGAN"})
													Else
														nPosConEF := 0
													Endif
													nPosImp:= Len(aTmpLinRet)
													Aadd(aTmpLinRet[nPosImp,5],{})
													nZ := Len(aTmpLinRet[nPosImp,5])
													Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosEstEF,2])
													Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosCFOEF,2])
													If nPosConEF > 0
														Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosConEF,2])
													Endif
													Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosBasEF,2])
													Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosAlqEF,2])
													Aadd(aTmpLinRet[nPosImp,5,nZ],xFormaRec[nZ,nPosRet,2,nPosRetEF,2])
												Endif
											Endif
										Endif
									Endif
								Endif    
							EndIf
						EndIf
						Exit
					EndIf
				Next nX   

				If !lRet
					Exit
				EndIf

				nValSEL := AScan(aHeader,{|x| AllTrim(x[2]) == "EL_VALOR"})
				nMoedSEL := AScan(aHeader,{|x| AllTrim(x[2]) == "EL_MOEDA"})

				If Valtype(aCols[nZ][nY]) <> "U"
					Loop 
				ElseIf Alltrim(aHeader[nY][8]) == "C"
					aCols[nZ][nY] := ""	 
				ElseIf Alltrim(aHeader[nY][8]) == "N"
					aCols[nZ][nY] := 0
				ElseIf Alltrim(aHeader[nY][8]) == "D"
					aCols[nZ][nY] := CTOD("  /  /    ")                                                                                                                    
				ElseIf Alltrim(aHeader[nY][8]) == "L"
					aCols[nZ][nY] := .T.
				EndiF
			Next nY  

			If AllTrim(aCols[nZ][nMoedSEL]) <> '1'
				DbSelectArea("SM2")
				SM2->(DbSetOrder(1))
				If !(SM2->(DbSeek(dDatabase)))
					cTxtRotAuto += STR0049 //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
					lMsErroAuto := .T.
					lRet:= .F.
					Exit  
				Else 
					If &("SM2->M2_MOEDA"+AllTrim(aCols[nZ][nMoedSEL])) > 0
						nTotSEL += aCols[nZ][nValSEL] * &("SM2->M2_MOEDA"+AllTrim(aCols[nZ][nMoedSEL]))
					Else
						cTxtRotAuto += STR0049 //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
						lMsErroAuto := .T.
						lRet:= .F. 
						Exit
					EndIf
				EndIf
			Else
				nTotSEL += aCols[nZ][nValSEL] 
			EndIf
			aCols[nZ][Len(aHeader) + 1] := .F.      
		Next nZ                        

		If lRet.And. !Fa840TudoOk()
			lMsErroAuto := .T.
			lRet:= .F.
		EndIF

		If lRet 
			Aadd(aLinSE1,Array(Len(aCposSE1)+2))
			For nZ := 1 to Len(xDocRec)
				If nZ > 1
					Aadd(aLinSE1,Array(Len(aCposSE1)+2))   
				EndIf
				nPosPref := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_PREFIXO"})
				nPosParc := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_PARCELA"})
				nPosTipE1 := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_TIPO"})
				nTitSE1 := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_NUM"})
				nValaPg := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_SALDO"})
				nValDes := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_DESCONT"})
				nValMul := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_MULTA"})
				nValJur := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_JUROS"})
				nMot 	:= Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "cMotBxSE1"})
				nValImP := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "nImpRetSE1"})
				nPosMoeda := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "E1_MOEDA"}) 
				nRecnSE1 := Ascan(xDocRec[nZ],{|x| AllTrim(x[1]) == "R_E_C_N_O_"})
				If nRecnSE1 == 0
					lMsErroAuto := .T.
					lRet:= .F.
					cTxtRotAuto += STR0225 + xDocRec[nZ][nTitSE1][2]  +  STR0226  +" "+ CRLF // 	"R_E_C_N_O_ do tํtulo "    + +" nใo foi informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                   
					Exit
				Else 
					aLinSE1[nZ][Len(aCposSE1) + 1] := xDocRec[nZ][nRecnSE1][2] 
				EndIf

				If lRet 
					SE1->(MsGoto(aLinSE1[nZ][Len(aCposSE1) + 1]))
					If !(SE1->(RECNO()) == aLinSE1[nZ][Len(aCposSE1) + 1])
						lRet := .F.
					EndIf
					If lRet
						For nY:=1 to Len(aCposSE1)
							If SE1->(FieldPos(Alltrim(aCposSE1[nY]))) > 0 
								aLinSE1[nZ][nY] := &("SE1->"+(Alltrim(aCposSE1[nY])))
							ElseIf nY > 1 
								aLinSE1[nZ][nY] := &(Alltrim(aCposSE1[nY]))
							EndIF
						Next nY	

						aLinSE1[nZ][1] := -1                  
						aLinSE1[nZ][Len(aCposSE1) + 2] := .F.  
						aLinSE1[nZ][nPosValBx] := xDocRec[nZ][nValaPg][2]-xDocRec[nZ][nValDes][2]+xDocRec[nZ][nValMul][2]+xDocRec[nZ][nValJur][2] 
						aLinSE1[nZ][nPosDesc]  := xDocRec[nZ][nValDes][2]
						aLinSE1[nZ][nPosMulta] := xDocRec[nZ][nValMul][2]
						aLinSE1[nZ][nPosJuros] := xDocRec[nZ][nValJur][2]
						aLinSE1[nZ][nPosMotBx] := xDocRec[nZ][nMot][2]
						aLinSE1[nZ][nPosImpRet] := xDocRec[nZ][nValImP][2]
						aLinSE1[nZ][anPosMoed[Val(xDocRec[nZ][nPosMoeda][2])]] := aLinSE1[nZ][nPosValBx]

						If !A840Pagtos(nZ,,.F.)
							lMsErroAuto := .T.
							lRet:= .F.
						Else
							If !Fa840BaixaOK(cNumFatAut,nZ)
								lMsErroAuto := .T.
								lRet:= .F.
							Endif
						EndIF 
						aLinSE1[nZ][1] := 1
						If Len(aTmpLinRet) > 0
							If cPaisLoc == "ARG"
								If lRatImp
									For nY := 1 To Len(aTmpLinRet)
										nPosImp := Ascan(xDocrec[nZ],{|x| Upper(AllTrim(x[1])) == aTmpLinRet[nY,1]})
										If nPosImp > 0
											nI := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(Alltrim(x[1])) == "FE_NROCERT"})
											If nI > 0
												If xDocRec[nZ,nPosImp,2,nI,2] == aTmpLinRet[nY,2]
													nPosEstEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "FE_EST"}) 
													nPosCFOEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "FE_CFO"})
													nPosBasEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "FE_VALBASE"})
													nPosAlqEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "FE_ALIQ"})
													nPosRetEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "FE_RETENC"})
													If  aTmpLinRet[nY,1] == "RS"
														nPosConEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "A2_CONCSUS"})
													ElseIF aTmpLinRet[nY,1] == "RG"
														nPosConEF := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(AllTrim(x[1])) == "A2_AGREGAN"})
													Else
														nPosConEF := 0
													Endif
													Aadd(aTmpLinRet[nY,5],{})
													nX := Len(aTmpLinRet[nY,5])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosPref,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nTitSE1,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosParc,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosTipE1,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosEstEF,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosCFOEF,2])
													If nPosConEF > 0
														Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosConEF,2])
													Endif
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosBasEF,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosAlqEF,2])
													Aadd(aTmpLinRet[nY,5,nX],xDocRec[nZ,nPosImp,2,nPosRetEF,2])
												Endif
											Endif
										Endif
									Next
								Endif
							Else
								If cPaisLoc == "PER"
									For nY := 1 To Len(aTmpLinRet)
										nPosImp := Ascan(xDocrec[nZ],{|x| Upper(AllTrim(x[1])) == aTmpLinRet[nY,1]})
										If nPosImp > 0
											nI := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(Alltrim(x[1])) == "FE_NROCERT"})
											If nI > 0
												If xDocRec[nZ,nPosImp,2,nI,2] == aTmpLinRet[nY,2]
													Aadd(aTmpLinRet[nPosImp,5],{})
													nX := Len(aTmpLinRet[nPosImp,5])
													Aadd(aTmpLinRet[nPosImp,5,nX],xDocRec[nZ,nPosPref,2])
													Aadd(aTmpLinRet[nPosImp,5,nX],xDocRec[nZ,nTitSE1,2])
													Aadd(aTmpLinRet[nPosImp,5,nX],xDocRec[nZ,nPosParc,2])
													Aadd(aTmpLinRet[nPosImp,5,nX],xDocRec[nZ,nPosTipE1,2])
													nI := Ascan(xDocRec[nZ,nPosImp,2],{|x| Upper(Alltrim(x[1])) == "E1_SALDO"})
													Aadd(aTmpLinRet[nPosImp,5,nX],xDocRec[nZ,nPosImp,2,nI,2])
												Endif
											Endif
										Endif
									Next
								Endif
							Endif
						Endif
					Else
						lMsErroAuto := .T.
						lRet:= .F.
						cTxtRotAuto += STR0120+" "+ xDocRec[nZ][nTitSE1][2] + STR0227 +" "+ CRLF  // "Titulo" ++ " nใo foi encontrado. "
						Exit
					EndIf
				EndIf

				If cValtoChar(aLinSE1[nZ][nMoedSE1]) <> '1' 
					DbSelectArea("SM2")
					SM2->(DbSetOrder(1))
					If !(SM2->(DbSeek(dDatabase)))
						cTxtRotAuto += STR0049 //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
						lMsErroAuto := .T.
						lRet:= .F.  
					Else 
						If &("SM2->M2_MOEDA"+Alltrim(cValtoChar(aLinSE1[nZ][nMoedSE1]))) > 0
							nTotSE1 += (xDocRec[nZ][nValaPg][2]-xDocRec[nZ][nValDes][2]+xDocRec[nZ][nValMul][2]+xDocRec[nZ][nValJur][2]  )* &("SM2->M2_MOEDA"+Alltrim(cValtoChar(aLinSE1[nZ][nMoedSE1])))   
						Else
							cTxtRotAuto += STR0049 //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
							lMsErroAuto := .T.
							lRet:= .F.  
						EndIf
					EndIf
				Else
					nTotSE1 += xDocRec[nZ][nValaPg][2]-xDocRec[nZ][nValDes][2]+xDocRec[nZ][nValMul][2]+xDocRec[nZ][nValJur][2]                
				EndIf
				If !lRet
					Exit
				EndIf
			Next nZ
		EndIf

		If lRet 
			FAMoedas(dDataRef,cNumFatAut)
			If !Fa840TudoOk()
				lMsErroAuto := .T.
				lRet:= .F.
			EndIF
		Endif
		If lRet
			/*
			verifica o valor das retencoes */  
			aLinRet := {}
			If Len(aTmpLinRet) > 0
				nZ := 0
				While lRet .And. nZ < (Len(aTmpLinRet))
					nZ++
					nI := 0
					If lRatImp
						If aTmpLinRet[nZ,1] $ "RG|RS"
							aCabRet := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","FE_EST","FE_CFO","A2_AGREGAN","FE_VALBASE","FE_ALIQ","FE_RETENC"}
						Else
							aCabRet := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
						Endif
					Else
						If aTmpLinRet[nZ,1] $ "RG|RS"
							aCabRet := {"FE_EST","FE_CFO","A2_AGREGAN","FE_VALBASE","FE_ALIQ","FE_RETENC"}
						Else
							aCabRet := {"FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
						Endif
					Endif
					aCertRet := {}
					For nI := 1 To Len(aTmpLinRet[nZ,5])
						Aadd(aCertRet,Aclone(aTmpLinRet[nZ,5,nI]))
						Aadd(aCertRet[Len(aCertRet)],.F.)
					Next
					If A87VldRet(aCertRet,aTmpLinRet[nZ,3],If(cPaisLoc == "PER",1,2),,aCabRet,aTmpLinRet[nZ,4],aTmpLinRet[nZ,1])
						Aadd(aLinRet,Aclone(aCertRet))
					Else
						lRet := .F.
						lMsErroAuto := .T.
					Endif
				Enddo
			Endif
			nTotal := nTotSEL -  nTotSE1
			If nTotal < 0
				lMsErroAuto := .T.
				lRet:= .F.   
				cTxtRotAuto += STR0228//"Saldo insuficiente para efetuar a baixa.  "
			EndIf
		Endif

		If lRet
			nPanel := 6
			If !Fa840Salvar(.F.,.T.) 
				lMsErroAuto := .T.
				lRet:= .F.   
			Else
				MsgAlert(STR0229 + cRecibo + "  .") //" Foi gerado o recibo n๚mero : "
				
			EndIf
		EndIF	
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณShowPanel บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra o panel referente ao passo em questao.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ShowPanel( nPan, oPanel,cNumFatAut,lIncAdt)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parametros utilizados na funcao                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ nPan 	- Numero do panel a ser mostrado.             ณ
	//ณ oPanel 	- Objeto recebido como referencia.            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nX := 1
	Local nLastPan := 4

	DEFAULT lIncAdt := .F.

	//Caso o objeto oPanel esteja sem valor, recupero atrav้s do
	//objeto de backup
	If oPanel == Nil
		oPanel := oObjBkp
	EndIf

	If lIncAdt
		nLastPan := 2 //ANGOLA tem menos paineis na inclusao de adiantamento
	Endif

	nLastPan := 6

	If nPan != nLastPan
		//Atualiza taxas das moedas
		FaMoedas()
	EndIf

	If nPan > 0 .And. nPan <= nLastPan
		For nX:=1 To Len(oPanel)
			If ( nX!=nPan )
				IF nX <= Len(aoCB)
					aoCB[nX]:Hide()
					aoCB[nX]:Refresh()
				Endif
				oPanel[nX]:Hide()
				oPanel[nX]:Refresh()
			Else
				IF nX <= Len(aoCB)
					aoCB[nX]:Show()
					OBJRefresh(nPan)
				Endif
				oPanel[nX]:Show()
				oPanel[nX]:Refresh()
				oDlgRecibo:cCaption:=aTitulo[nX]
				If (nPan == nLastPan) .Or. (nPan > 4) .Or. (nPan == 4 .And. Ascan(aLinSE1, {|x| x[1] == 1 }) == 0 )
					RefData(nPan,cNumFatAut,lIncAdt)
				EndIf
			EndIf

		Next nX
		Do Case
			Case nPan == 2 .and. !lIncAdt
			oLBCli:SetFocus()
			Case nPan == 3 .and. !lIncAdt
			oLBSE1:SetFocus()
		End Case
		nPan:=nPanel	
	Else
		If nPanel <  1
			nPanel:=1
			nPan:=nPanel
		Else
			nPanel:= nLastPan
			nPan:= nPanel
		EndIf	
	EndIf

	//Efetuo uma copia do objeto oPanel caso na pr๓xima chamada da fun็ใo
	//o mesmo seja passado com valor NIL, preservando a integridade da rotina
	oObjBkp := oPanel

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840Vld  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a validacao de campos que nao estao no Browse.		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ cVar 	- Variavel a ser validada.			          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna aRet, se .T. ้ que o conteudo e valido.		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Function FA840Vld(cVar , cNumFatAut , lIncAdt )

	Local lRet 	:= .T.                      

	DEFAULT cNumFatAut := ""
	DEFAULT lIncAdt	   := .F.   

	Do Case 
		Case cVar=="cRecibo"
		If Empty(cRecibo)
			MsgStop(STR0116)   //"Por favor, primero indique o campo de nr do recibo"
			Return (.F.)
		EndIf
		DbSelectArea("SEL")
		DbSetorder(8)
		If dbSeek(xFilial("SEL")+cSerie+cRecibo)
			Help(" ",1,"EXISTNUM")
			Return(.F.)
		EndIf

		//Ponto de Entrada F840COB
		//Usado no preenchimento automatico do cobrador, quando informado o n. do recibo 
		If ExistBlock("F087ACOB")
			cCobrador:= ExecBlock("F087ACOB",.F.,.F.)
		Endif

		dDataRef	:= dDataBase
		OtherWise
		dDataRef	:= dDataBase
		cCliente	:=	Space(Len(SEL->EL_CLIENTE))
		cLoja		:=	Space(Len(SEL->EL_LOJA))
		cNome		:=	Space(TamSX3("A1_NOME")[1])
		cCGC		:=	Space(TamSX3("A1_CGC")[1])
		cContato	:=	Space(TamSX3("A1_CONTATO")[1])
		cTel		:=	Space(TamSX3("A1_TEL")[1])
		RefData(1,cNumFatAut,lIncAdt)
		OBJRefresh(1)
	EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840Ord  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ordena linhas do Grid de acordo com Combo.        		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ nCombo	- Qual combo deve ser considerado             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FA840Ord(nCombo)
	Local nPos

	If nCombo==1
		nPos := Ascan(aCabSEL,cOrdSEL)
		If lDecr
			ASort(aCols,,,{|x,y| x[nPos]> y[nPos]})
		Else
			ASort(aCols,,,{|x,y| x[nPos]< y[nPos]})
		Endif
		oGetSEL:ForceRefresh()
	Endif
	If nCombo==2
		nPos := Ascan(aCabSA1,cOrdSA1)
		If lDecr
			ASort(aLinSA1,,,{|x,y| x[nPos]> y[nPos]})
		Else
			ASort(aLinSA1,,,{|x,y| x[nPos]< y[nPos]})
		Endif
		oLBCli:SetArray(aLinSA1)
		oLBCli:bLine:= { || &(cBLinSA1 + "}") }
		oLBCli:Refresh()
	Endif
	If nCombo==3
		nPos := Ascan(aCabSE1,cOrdSE1)
		If lDecr
			ASort(aLinSE1,,,{|x,y| x[nPos]> y[nPos]})
		Else
			ASort(aLinSE1,,,{|x,y| x[nPos]< y[nPos]})
		Endif
		oLBSE1:SetArray(aLinSE1)
		oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
		oLBSE1:Refresh()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840Buscar  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca valor do campo cPesq de acordo com o combo. 			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840Buscar(lIncAdt)

	Local nX
	Local nPos
	Local nLin:=1
	Local cTipo
	Local aLin

	//ANGOLA
	DEFAULT lIncAdt := .F.

	If nPanel==1
		oGetSEL:oBrowse:SetFocus()
		nPos	:= Ascan(aCabSEL,cOrdSEL)
		nPos	:= iif(nPos>0,nPos,1)
		aLin 	:= aClone(aCols)
		cTipo	:= SEL->(Type(aCposSEL[nPos]))
	Endif
	If nPanel==2
		oLBCli:SetFocus()
		nPos	:= Ascan(aCabSA1,cOrdSA1)
		nPos	:= iif(nPos>0,nPos,1)
		aLin	:= aClone(aLinSA1)
		cTipo	:= SA1->(Type(aCposSA1[nPos]))
	Endif
	If nPanel==3 .and. !lIncAdt
		oLBSE1:SetFocus()
		nPos	:= Ascan(aCabSE1,cOrdSE1)
		nPos	:= iif(nPos>0,nPos,1)
		aLin	:= aClone(aLinSE1)
		cTipo	:= SE1->(Type(aCposSE1[nPos]))
	Endif

	cText	:=cPesq
	nX 		:= 1

	If nPos > 0
		For nX:= 1 to Len(aLin)
			Do Case
				Case cTipo=="D"
				If CtoD(cText)=aLin[nX][nPos]
					nLin:=nX
					Exit
				Endif
				Case cTipo=="N"
				If Val(cText)=aLin[nX][nPos]
					nLin:=nX
					Exit
				Endif
				Case cTipo$"C|U"
				If Upper(Alltrim(cText)) $ Upper(Alltrim(aLin[nX][nPos]))
					nLin:=nX
					Exit
				Endif
			EndCase
		Next nX

		If nPanel==1
			aCols	:=	aClone(aLin)
			n:=nlin
			oGetSEL:oBrowse:nAt:=nLin
			oGetSEL:oBrowse:Refresh()
			oGetSEL:oBrowse:SetFocus()
		Endif
		If nPanel==2
			aLinSA1		:= aClone(aLin)
			oLBCli:nAt := nLin
			oLBCli:SetArray(aLinSA1)
			oLBCli:bLine:= { || &(cBLinSA1 + "}") }
			oLBCli:SetFocus()
		Endif
		If nPanel==3 .and. !lIncAdt
			aLinSE1 		:= aClone(aLin)
			oLBSE1:nAt := nLin
			oLBSE1:SetArray(aLinSE1)
			oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
			oLBSE1:SetFocus()
		Endif
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRefData   บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remonta dados do Grid, de acordo com Panel.                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RefData(nPan,cNumFatAut,lIncAdt)

	Local aRecs			:={}
	Local nValDac := 0
	Local lQuery  	:= .F.
	Local cQuery  	:= ""
	Local nI      	:= 0  
	Local nCAsc   	:= 0
	Local cStrTipos := "'"
	Local cCposSE1	:= ""
	Local cCposSA1	:= ""
	Local cFilClie	:= ""
	Local nQtdCli 	:= 0
	Local nContCli 	:= 0
	Local lFiltSE1  := ExistBlock("F087ASE1")
	Local aCli		:= {}
	Local nX			:= 0
	Local nY 			:= 0
	Local nCont 		:= 0
	Local nPosHead 		:= 0
	Local nPosTmp		:= 0
	Local nPosTmp2		:= 0
	Local nPosTmp3		:= 0
	Local aColsReten	:= {}
	Local aColsCtb		:= {}
	Local nPosCT2		:= 0
	Local cTabCT2		:= ""
	Local nSkip			:= 0
	Local nPosValCtb	:= 0
	Local nPosDebCtb	:= 0
	Local nPosCreCtb	:= 0
	Local nPosDC		:= 0
	LOCAL nTamPre
	LOCAL nTamNum
	LOCAL nTamParcel
	LOCAL nTamTipTit
	LOCAL nLastPanel := 4 
	Local nImpRet := 0
	Local aFilAcc := {}
	Local cAllAcc := "@@@@"
	Local cFilAcc := ""
	Local nI := 0
	Local cFilAux := ""

	DEFAULT cNumFatAut	:= ""
	DEFAULT lIncAdt		:= .F.		
	// Se obtienen Filiales a las que tiene acceso el usuario
	// Si considerar filial = No
	If !lConsFilial .and. nPan == 3
		If PswSeek(__cUserId,.t.) 
			aFilAcc := PswRet(2)
			If Valtype((aFilAcc[1,5])) =="A"
				For nI:= 1 to len(aFilAcc[1,5])
					If !("@@@@" $ aFilAcc[1,5,nI]) // Si NO tiene Acceso a Todas las filiales
						cFilAux := Substr(aFilAcc[1,5,nI],len(cEmpant)+1,len(cFilAnt))
						cFilAcc += "'" + cFilAux + "'"
						If !(nI == len(aFilAcc[1,5]))
							cFilAcc += ","
						EndIf  
					EndIF
				Next
			ElseIf Valtype((aFilAcc[1,6])) =="A"	
				For nI:= 1 to len(aFilAcc[1,6])
					If !("@@@@" $ aFilAcc[1,6,nI]) // Si NO tiene Acceso a Todas las filiales
						cFilAux := Substr(aFilAcc[1,6,nI],len(cEmpant)+1,len(cFilAnt))
						cFilAcc += "'" + cFilAux + "'"
						If !(nI == len(aFilAcc[1,6]))
							cFilAcc += ","
						EndIf  
					EndIF
				Next
			EndIf
		EndIf
	EndIf

	nPosDesc  := AScan(aCposSE1,"nDescSE1")
	nPosJuros := AScan(aCposSE1,"nJurSE1")
	nPosMulta := AScan(aCposSE1,"nMultaSE1")
	nPosSaldo := AScan(aCposSE1,"E1_SALDO")
	nPosMotBx := AScan(aCposSE1,"cMotBxSE1")
	nPosImpRet:= ASCAN(aCposSE1,"nImpRetSE1")

	#IFDEF TOP
	If TCSrvType() != "AS/400"
		lQuery := .T.
	EndIf
	#ENDIF	

	//Inclusao de adiantamentos tem menos paineis
	If lIncAdt
		nLastPanel := 2
	Endif
	If cPaisLoc $ "ARG|"
		nLastPanel := 6
		If nPan == 2 .And. ReadVar() == "CLOJA"
			cLojCli := cLoja
		EndIf
	EndIf


	If nPan == 1
		c_Alias 	:= "SEL"
		nIndice := 8
		cSeek	:= xFilial("SEL")+cSerie+cRecibo
		cSelec	:= ".T."
		cWhi  	:= "(!EOF() .And. EL_FILIAL == '" + xFilial("SEL") +"' .And. SEL->EL_SERIE == '" + cSerie +"' .And. SEL->EL_RECIBO == '" + cRecibo + "')"
		aCols 	:= MontaGrid(c_Alias,cWhi,cSelec,.F.,".F.",cSeek,nIndice,aCposSEL)
	Endif

	//ANGOLA - Esta painel nao e habilitado na incusao de adiantamentos
	//Painel de clientes
	If nPan == 2 .and. !lIncAdt
		nIndice := 1
		c_Alias 	:= "SA1"
		cSeek	:=""

		If nFiltro==4
			aUserFilter := ExecBlock("F087AFIL",.F.,.F.)
			nIndice := aUserFilter[1]
			cSeek	:= aUserFilter[2]
			cSelec	:= aUserFilter[3]
			cWhi  	:= aUserFilter[4]
			If Len(aUserFilter) > 4
				cQuery  := aUserFilter[5]
			EndIf
		Endif
		If nFiltro==3  // melhorar performance para Query caso nao haja filtro de cliente
			If !lQuery
				cSeek	:= xFilial("SA1")
				cSelec	:= ".T."
				cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "')"
			Else         
				//Determina os campos que serao selecionado na query...				
				aEval(aCposSA1,{|x,y| cCposSA1 += Iif(Left(x,2)=="A1",AllTrim(x)+", ","")})
				cCposSA1 += "SA1.D_E_L_E_T_,SA1.R_E_C_N_O_"

				cQuery := "SELECT DISTINCT A1_FILIAL,"+cCposSA1
				cQuery += " FROM "+RetSQLName("SA1")+" SA1,"+RetSQLName("SE1")+" SE1"
				cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND"
				cQuery += " A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_SALDO > 0 AND"
				cQuery += " SA1.D_E_L_E_T_ <> '*'"
				cQuery += " ORDER BY "+SqlOrder(SA1->(IndexKey(nIndice)))
				cQuery := ChangeQuery(cQuery)	

				cSeek  := ""
				cWhi   := "!EOF()"
				cSelec := ".T."
			EndIf
		Endif
		If nFiltro==2
			cSeek	:= xFilial("SA1")+cCliente
			cSelec	:= "'" + xFilial("SA1")+cCliente+ "' == A1_FILIAL+A1_COD"
			cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "') .And. ('" + cCliente + "' == A1_COD)"
		Endif
		If nFiltro==1
			cSeek	:= xFilial("SA1")+cCliente+cLoja
			cSelec	:= "'" + xFilial("SA1")+cCliente+cLoja + "' == SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA"
			cWhi  	:= "(!EOF() .And. SA1->A1_FILIAL == '" + xFilial("SA1") + "') .And. ('" + cCliente + cLoja + "' == A1_COD+A1_LOJA)"
		Endif
		cCondMca:= "(A1_COD == '" + cCliente + "' .And. A1_LOJA =='" + cLoja + "')"
		cSelec	+= IIf(!Empty(aFiltros[2])," .And. ("+aFiltros[2]+")","")
		aLinSA1	:= MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSA1,,cQuery)

		oLBCli:SetArray(aLinSA1)
		oLBCli:bLine:= { || &(cBLinSA1 + "}") }
		FaMoedas(NIL,cNumFatAut)
	Endif

	//ANGOLA - Esta painel nao e habilitado na incusao de adiantamentos
	//Painel de titulos a baixar
If (nPan == 3 .and. !lIncAdt) .AND. !lLinArr 
		ValAltArray(aLinSE1,@aLinSE1_Ori,aLinSA1,@aLinSA1_Ori,@cCliLoj_Ori)
		c_Alias	:= "SE1"
		nIndice := 2
		cCondMca:= ".F."
		cSelec  := ""
		aCli	:={}

		nPosCli	:= AScan(aCposSA1,"A1_COD")
		nPosLoja:= AScan(aCposSA1,"A1_LOJA")

		AEval(oLBCli:aARRAY, {|x,y| If(oLBCli:aARRAY[y][1] == 1, nQtdCli++,.T.)})//Qtd de Clientes selecionados

		If nQtdCli >= 300
			// limite de selecao de clientes para que nao estoure a string a ser montada a seguir.
			// a cQuery tem um limite de 15980 bytes, e o limite de 300 clientes garante que a string cQuery
			// nao estoure, considerando os tamanhos "default" para os campos codigos e loja de cliente (6 e 2)
			Alert(STR0112) //"Limite de 300 clientes selecionados foi atingido. Por favor, verifique a selecao feita."
		Else
			nX:=1
			For nX:= 1 to Len(oLBCli:aARRAY) //ListBox de clientes
				If oLBCli:aARRAY[nX][1] == 1 // Cliente esta selecionado
					AAdd(aCli,{oLBCli:aARRAY[nX][nPosCli],oLBCli:aARRAY[nX][nPosLoja]})
					If !lQuery //Prepara a condicao de filtro para DBF 
						cFilClie += oLBCli:aARRAY[nX][nPosCli] +  oLBCli:aARRAY[nX][nPosLoja] + "|"
					Else //Prepara a condicao de filtro para Bco de Dados
						cFilClie += "(E1_CLIENTE = '" + oLBCli:aARRAY[nX][nPosCli] + "' AND E1_LOJA = '" + oLBCli:aARRAY[nX][nPosLoja] + "')" 
						nContCli++ 
						If nContCli != nQtdCli //Verifica se existem mais clientes para se adicionar a Query
							cFilClie  += " OR "
						Else
							cFilClie  += ") AND "
						EndIf
					EndIf
				Endif
			Next nX
			aSort(aCli ,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			cFilClie := Iif(lQuery,"("+cFilClie,cFilClie)
		EndIf

		If Len(aCli) > 0

			aLinSE1 := {}
			nValREc := 0
			If lFiltSE1
				aUserFilSE1 := ExecBlock("F087ASE1",.F.,.F.)
				nIndice := aUserFilSE1[1]
				cSeek	:= aUserFilSE1[2]
				cSelec	:= aUserFilSE1[3]
				cWhi  	:= aUserFilSE1[4]
				If Len(aUserFilSE1) > 4
					cQuery  := aUserFilSE1[5]
				EndIf
			Else
				If !lQuery
					If lConsFilial
						ASort(aCli,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
						cSeek := xFilial(c_Alias)+ aCli[1][1] + aCli[1][2]
						cWhi  := "(!EOF() .And. SE1->E1_FILIAL == '" + xFilial("SE1") + "') .AND."
						If Len(aCli) > 1
							cWhi  += " (E1_CLIENTE+E1_LOJA  <= '" + aCli[Len(aCli)][1] +aCli[Len(aCli)][2] + "')" 
						Else
							cWhi  += " (E1_CLIENTE+ E1_LOJA) $ '" + cFilClie + "'"
						EndIf	   
					Else
						cSeek := ""
						cWhi  := "!EOF()"
					EndIf
					cSelec:= IIf(!Empty(cSelec) .And. !Empty(aFiltros[3])," .And. ","") + IIf(!Empty(aFiltros[3]),Alltrim(aFiltros[3]),"")
					cSelec+= IIf(!Empty(cSelec)," .And. ","") + "E1_TIPO$'"+cTipos+"' .And. SE1->E1_EMISSAO <= dDataRef"

					If lConsFilial
						cSelec += IIf(!Empty(cSelec)," .And. ","")+"(E1_CLIENTE+E1_LOJA $ '" + cFilClie + "')"
					EndIf
					If lConsSaldo
						cSelec+= " .And. SE1->E1_SALDO > 0"
					EndIf
				Else
					IF cPaisLoc ="ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0
						cTipos := StrTran(cTipos,"/RA","")
				 	EndIf
					For nI := 1 To Len(cTipos) 
						nCAsc := Asc(SubStr(cTipos,nI,1))
						If (nCAsc == 32) .Or. (nCAsc == 45) .Or.;
						(nCAsc >= 48 .And. nCAsc <= 57 ) .Or.;
						(nCAsc >= 65 .And. nCAsc <= 90 ) .Or.;
						(nCAsc >= 97 .And. nCAsc <= 122) 

							cStrTipos += (SubStr(cTipos,nI,1)+Iif(nI==Len(cTipos),	"'",""))
						Else
							cStrTipos += "','"
						EndIf
					Next nI         

					cStrTipos	:=	IIf(Right(cStrTipos,2)==",'",Substr(cStrTipos,1,Len(cStrTipos)-2),cStrTipos)
					//Determina os campos que serao selecionado na query...				
					aEval(aCposSE1,{|x,y| cCposSE1 += Iif(Left(x,2)=="E1",AllTrim(x)+", ","")})
					cCposSE1 += "D_E_L_E_T_, R_E_C_N_O_"
					
					IF cPaisLoc ="ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0
						cQuery := "SELECT "+IIf(lConsFilial," E1_FILIAL, "," ") +cCposSE1
					Else
						cQuery := "SELECT "+cCposSE1
				 	EndIf
					cQuery += " FROM "+RetSQLName("SE1")
					If lConsFilial              
						cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND"
						cQuery += cFilClie
					Else
						cQuery += " WHERE "+cFilClie+" "
						If !Empty(cFilAcc)
							cQuery += " E1_FILIAL IN (" + cFilAcc + ") AND " 
						EndIf
					EndIf
					cQuery += " E1_EMISSAO <= '"+Dtos(dDataRef)+"' AND" 
					cQuery += " E1_TIPO IN ("+cStrTipos+") AND"	
					If lConsSaldo
						cQuery += " E1_SALDO > 0 AND"
					EndIf
					cQuery += " E1_NUM <> ' ' AND"

					If ! Empty(cNumFatAut)
						nTamPre    := TamSX3("E1_PREFIXO")[1]
						nTamNum    := TamSX3("E1_NUM")[1]
						nTamParcel := TamSX3("E1_PARCELA")[1]
						nTamTipTit := TamSX3("E1_TIPO")[1]

						cQuery += "( E1_PREFIXO = '"+Subs(cNumFatAut,1,nTamPre)+"' AND E1_NUM = '"+Subs(cNumFatAut,nTamPre+1,nTamNum)+"' AND E1_PARCELA = '"+Subs(cNumFatAut,nTamPre+nTamNum+1,nTamParcel)+"' AND E1_TIPO = '"+Subs(cNumFatAut,nTamPre+nTamNum+nTamParcel+1,nTamTipTit)+"' ) AND "
					Endif

					cQuery += " D_E_L_E_T_ = ' '"

					// Adicionado para atender a Shark 12/01/2010
					If ExistBlock("F087AQRY") 
						cQuery += ExecBlock("F087AQRY",.F.,.F.)  
					EndIf
					IF cPaisLoc ="ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0
						cQuery += " UNION " + StrTran(cQuery," E1_TIPO IN ("+cStrTipos+")"," E1_TIPO='RA' AND E1_TIPOGR "+ If(ALLTRIM(aCols[1][1])=="GR","='1'","!='1' "))
					EndIf  
					cQuery += " ORDER BY "+SqlOrder(SE1->(IndexKey(nIndice)))
					cQuery := ChangeQuery(cQuery)	

					cSeek  := ""
					cWhi   := "!EOF()"
					cSelec := ".T."
					cSelec += IIf(!Empty(cSelec) .And. !Empty(aFiltros[3])," .And. ","") + IIf(!Empty(aFiltros[3]),Alltrim(aFiltros[3]),"")
				EndIf
			EndIf
			aLinSE1     := AClone(MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.,cQuery))
		Else
			cWhi	:=	'.F.'	// Se nenhum cliente estiver selecionado, cria o aLinhas em branco
			cSelec	:=	'.F.'	// Se nenhum cliente estiver selecionado, cria o aLinhas em branco
			cSeek	:= "ZZZZZZZZ"
			aLinSE1 := AClone(MontaGrid(c_Alias,cWhi,cSelec,.T.,cCondMca,cSeek,nIndice,aCposSE1,.T.))
		Endif

		oLBSE1:SetArray(aLinSE1)
		oLBSE1:nAt 	:= 1
		oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
	lLinArr := .F.
	Endif

	If	((nPan == nLastPanel) .And. lIncAdt) .Or. (nPan == 4)
		nPosTipo	:= AScan(aCposSEL,"EL_TIPODOC")
		nPosVal		:= AScan(aCposSEL,"EL_VALOR")
		nPosMoedTit	:= AScan(aCposSEL,"EL_MOEDA")
		aLinReceb	:= {}

		aRecs:=AClone(aCols)
		ASort(aRecs,,,{|x,y| x[nPosTipo] < y[nPosTipo]})
		cTipo:=NIL
		nX:=1
		For nX:= 1 To Len(aRecs)
			If cTipo!=aRecs[nX][nPosTipo] .and. !aRecs[nX][Len(aRecs[nX])]
				AAdd(aLinReceb,{aRecs[nX][nPosTipo],0})
				cTipo:=aRecs[nX][nPosTipo]
			Endif
			If aRecs[nX][nPosVal]!=Nil .and. !aRecs[nX][Len(aRecs[nX])]
				nM:=IIf(Empty(aRecs[nX][nPosMoedTit]).Or. Val(aRecs[nX][nPosMoedTit])<=1,1,Val(aRecs[nX][nPosMoedTit]))
				aLinReceb[Len(aLinReceb)][2]+=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
			Endif
		Next nX
		oLBReceb:SetArray(aLinReceb)
		oLBReceb:bLine := { ||{aLinReceb[oLBReceb:nAT][1],Transform(aLinReceb[oLBReceb:nAT][2],PesqPict("SEL","EL_VALOR",18,oCBMOed:nAt)) }}
		oLBReceb:Refresh()

		// Monta Resumo das baixas
		aLinBx := {}

		//Inclusao de adiantamento nao tem valor baixado
		If !lIncAdt
			nPosTipo		:= AScan(aCposSE1,"E1_TIPO")
			nPosVal		:= AScan(aCposSE1,"nBaixar")
			nPosMoedTit	:= AScan(aCposSE1,"E1_MOEDA")
			nPosDesc 	:= AScan(aCposSE1,"nDescSE1")
			nPosJuros	:= AScan(aCposSE1,"nJurSE1")
			nPosMulta	:= AScan(aCposSE1,"nMultaSE1")
			nPosImpRet	:= AScan(aCposSE1,"nImpRetSE1")

			aRecs:=AClone(aLinSE1)
			ASort(aRecs,,,{|x,y|  Str(x[1]) + x[nPosTipo] <  Str(y[1]) + y[nPosTipo]})
			cTipo:=Nil
			nX:=1
			For nX:= 1 To Len(aRecs)
				If aRecs[nX][1]<1
					Exit
				Endif
				If cTipo!=aRecs[nX][nPosTipo]
					AAdd(aLinBx,{aRecs[nX][nPosTipo],0})
					cTipo:=aRecs[nX][nPosTipo]
				Endif
				nM:=IIf(Empty(aRecs[nX][nPosMoedTit]).Or. aRecs[nX][nPosMoedTit]<=1,1,aRecs[nX][nPosMoedTit])
				If aRecs[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG
					aLinBx[Len(aLinBx)][2]-=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
					If aRecs[nX][nPosMotBx]=="DAC"
						nValDac-=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
					EndIf
				Else
					aLinBx[Len(aLinBx)][2]+=(aRecs[nX][nPosVal]-aRecs[nX][nPosDesc]+aRecs[nX][nPosJuros]+aRecs[nX][nPosMulta])*aTaxa[nM]/aTaxa[oCBMOed:nAt]
					If aRecs[nX][nPosMotBx]=="DAC"
						nValDac+=aRecs[nX][nPosVal]*(aTaxa[nM]/aTaxa[oCBMOed:nAt])
					EndIf
				Endif
				// Soma Reten็ใo de Impostos como Baixa  
				if nPosImpRet > 0 .and. aRecs[nX, nPosImpRet] > 0
					nImpRet += aRecs[nX, nPosImpRet] 
				endif			
			Next nX

			If nValDac<>0 
				Aadd(aLinBx,{"DAC",nValDac*(-1)})
			Endif
			If nDescGer>0 
				Aadd(aLinBx,{"DC",nDescGer*(aTaxa[nMoedDesc]/aTaxa[oCBMOed:nAt])*(-1)})
			Endif
			If nPercGer>0
				nTotBx:=0
				AEval(aLinBx,{|x| If(!(x[1]$MVRECANT+"/"+MV_CRNEG+"/DAC"),nTotBx +=x[2],0)})
				AAdd(aLinBx,{"DC",nPercGer*nTotBx*0.01*(-1)})   // Aplica percentual de desconto
			Endif  

			// Percep็ใo de IGV - Peru
			If cPaisLoc $ "EQU|PER" .And. nValPerc > 0 .And. aPerc[1][8] // 
				Aadd(aLinBx,{"P",nValPerc*(aTaxa[nMoedDesc]/aTaxa[oCBMOed:nAt])*(1)})
				cTipo:="P"
			EndIf	

		Endif

		nTotBx:=0
		AEval(aLinBx,	{|x| nTotBx +=x[2]})
		nTotRec:=0
		AEval(aLinReceb,{|x| nTotRec += x[2]})

		oLBBx:SetArray(aLinBx)
		oLBBx:bLine := { ||{aLinBx[oLBBx:nAT][1],Transform(aLinBx[oLBBx:nAT][2],PesqPict("SE1","E1_VALOR",18,oCBMOed:nAt)) }}
		oLBBx:Refresh()

		nTotalBx := nTotBx
		nTotal:= Round(nTotRec-nTotBx,MsDecimais(IIf(!lRotAuto,oCBMOed:nAt,1)))

		oTotal:Picture:=PesqPict("SE1","E1_VALOR",TamSX3("E1_VALOR")[1],oCBMOed:nAt)
		oTotal:Refresh()

	EndIf

	//Painel 5
	aColsSEL	:= ACLONE(aCols)
	aHeaderSEL	:= ACLONE(aHeader)
	If nPan == 5 .and. cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG'
		nCont 		:= 0
		aColsReten 	:= Array(1,Len(oRetTit:aHeader)+1)
		nPosTmp		:= ASCAN(oRetTit:aHeader,{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" })
		nPosTmp2 	:= ASCAN(oRetTit:aHeader,{|aCpo| AllTrim(aCpo[2]) == "EL_MOEDA" })
		nPosTmp3 	:= ASCAN(oRetTit:aHeader,{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR" })

		For nX := 1 To Len(aCols)
			//Verifica tipo interno em caso do uso da tabela FJS

			If !(aCols[nX,Len(aHeader)+1]) .And. (aCols[nX,nPosTmp] $ "RI|RG|RB|RS|RM|")
				nCont++
				//Se nใo for a primeira linha, adiciona nova linha no quadro de reten็๕es
				If !(nCont == 1)
					AADD(aColsReten,Array(Len(oRetTit:aHeader)+1))
				EndIf

				aColsReten[nCont,nPosTmp] := aCols[nCont,nPosTmp]

				For nY := 1 To (Len(oRetTit:aHeader)-1)
					nPosHead := ASCAN(aHeader,{|aCab| AllTrim(aCab[2]) == AllTrim(oRetTit:aHeader[nY,2]) })
					aColsReten[nCont,nY] := aCols[nX,nPosHead]
					//Preenche a coluna de ordena็ใo	
					Do Case
						Case (aColsReten[nCont,nPosTmp] $ "RI|")
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 1
						Case (aColsReten[nCont,nPosTmp] $ "RG|")
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 2
						Case (aColsReten[nCont,nPosTmp] $ "RB|")
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 3
						Case (aColsReten[nCont,nPosTmp] $ "RS|")
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 4
						Case (aColsReten[nCont,nPosTmp] $ "RM|") .and.  SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 5
						Otherwise
						aColsReten[nCont,Len(oRetTit:aHeader)]	:= 9
					EndCase

					aColsReten[nCont,Len(oRetTit:aHeader)+1] := .F.
				Next nY
			EndIf
		Next nX

		//Verifica se hแ reten็๕es ou nใo, para preencher a aColsReten com conte๚dos em branco
		If nCont <= 0
			For nX := 1 To Len(oRetTit:aHeader)
				If oRetTit:aHeader[nX,8] == "N"
					aColsReten[1,nX] := 0
				Else
					aColsReten[1,nX] := ""
				EndIf
			Next nX
			aColsReten[1,Len(oRetTit:aHeader)+1] := .T.
		Else
			//Reordena as linhas do quadro de reten็๕es, por tipo, de acordo com a ordem RI,RG,RB,RS
			ASORT(aColsReten, , , {|aLin1,aLin2| (aLin1[nPosTmp] < aLin2[nPosTmp]) })
		EndIf
		oRetTit:SetArray(aColsReten)
		oRetTit:Refresh()

		//Atualiza o quadro do resumo de reten็๕es
		For nX := 1 To Len(oRetRes:aArray)
			oRetRes:aArray[nX,2] := 0

		Next nX

		For nX := 1 To Len(oRetTit:aCols)
			//Soma as reten็๕es e atualiza os valores do quadro de resumo de reten็๕es
			If cPaisLoc $ "URU|BOL"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IRIC
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IR
					oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]	
			ElseIf cPaisLoc == "PTG"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IVA
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IRC
					oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]	
			ElseIf cPaisLoc == "ANG"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//RIE
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]
				EndCase
				oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]	
			ElseIf cPaisLoc == "PER"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IGV
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IR
					oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]	
			ElseIf cPaisLoc == "ARG" 
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IVA
					oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//Ganancias
					oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 3		//Ingressos Brutos
					oRetRes:aArray[3,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 4		//SUSS
					oRetRes:aArray[4,2] += oRetTit:aCols[nX,nPosTmp3]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 5 .and.  SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0	//Retencion Municipal
					oRetRes:aArray[5,2] += oRetTit:aCols[nX,nPosTmp3]
				EndCase
				If SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0
					oRetRes:aArray[6,2] += oRetTit:aCols[nX,nPosTmp3]
				Else			
					oRetRes:aArray[5,2] += oRetTit:aCols[nX,nPosTmp3]
				EndIf
			EndIf
		Next nX	
		oRetRes:bLine := {|| { oRetRes:aArray[oRetRes:nAT][1], RTrim(Transform(oRetRes:aArray[oRetRes:nAT][2],PesqPict("SEL","EL_VALOR",TamSX3("EL_VALOR")[1],oCBMOed:nAt))) } }
		oRetRes:Refresh()
	ElseIf nPan == 5 .and.  !cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG|RUS'
		nPan++
	EndIf

	//Painel 6
	If nPan == 6 
		//Processa a simula็ใo da contabiliza็ใo
		MsAguarde({|| FA840aCtbA(1) } , STR0189) // "Simula็ใo da contabiliza็ใo"

		//Monta o browse da simula็ใo da contabiliza็ใo
		nPosCT2 := ASCAN(aCtbTmp, {|aX| aX[1] == "CT2"})   

		aColsCtb := Array(1,Len(oSimCtb:aHeader)+1)
		aColsCtb[1,Len(oSimCtb:aHeader)+1] := .T.
		nSkip := 1
		If nPosCT2 > 0
			cTabCT2 := aCtbTmp[nPosCT2,4]
			dbSelectArea("CT2")
			dbGoTop()
			dDtCtb := CT2->CT2_DATA
			cLtCtb := CT2->CT2_LOTE

			oDtCtb:CtrlRefresh()
			oLtCtb:CtrlRefresh()
			While !EoF()
				If nSkip > 1
					AADD(aColsCtb,Array(Len(oSimCtb:aHeader)+1))
				EndIf
				For nX := 1 To Len(oSimCtb:aHeader)
					aColsCtb[nSkip,nX] := CT2->&(oSimCtb:aHeader[nX,2])
				Next nX
				aColsCtb[nSkip,Len(oSimCtb:aHeader)+1] := .F.
				dbSkip()
				nSkip++
			EndDo

			oSimCtb:SetArray(aColsCtb)
			oSimCtb:ForceRefresh()

			nPosValCtb 	:= ASCAN(oSimCtb:aHeader, {|aX| AllTrim(aX[2]) == "CT2_VALOR"})
			nPosDebCtb 	:= ASCAN(oSimCtb:aHeader, {|aX| AllTrim(aX[2]) == "CT2_DEBITO"})
			nPosCreCtb 	:= ASCAN(oSimCtb:aHeader, {|aX| AllTrim(aX[2]) == "CT2_CREDIT"})
			nPosDC		:= ASCAN(oSimCtb:aHeader, {|aX| AllTrim(aX[2]) == "CT2_DC"})
			nCtbDeb := 0
			nCtbCre := 0

			If (nPosValCtb > 0) .And. (nPosDebCtb > 0) .And. (nPosCreCtb > 0) .And. (nPosDC > 0)
				For nX := 1 To Len(aColsCtb)
					Do Case
						Case AllTrim(aColsCtb[nX,nPosDC]) == "1"
						nCtbDeb += aColsCtb[nX,nPosValCtb]
						Case AllTrim(aColsCtb[nX,nPosDC]) == "2"
						nCtbCre += aColsCtb[nX,nPosValCtb]
						Case AllTrim(aColsCtb[nX,nPosDC]) == "3"
						nCtbDeb += aColsCtb[nX,nPosValCtb]
						nCtbCre += aColsCtb[nX,nPosValCtb]
					EndCase
				Next nX
			EndIf						

			oCtbDeb:CtrlRefresh()
			oCtbCre:CtrlRefresh()						
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840Vld  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz refresh dos objetos do Panel informado.        		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OBJRefresh(nPan)

	If nPan==1
		oGetSEL:ForceRefresh()
		oGetSEL:oBrowse:Refresh()
		aDadosAdm:={}
	Endif
	If nPan==2
		oLBCli:Refresh()
	Endif
	If nPan==3
		oLBSE1:Refresh()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAMoedas  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListBox que contem as taxas das moedas.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ dData	- Data para buscar no SM2, caso nao informada,ณ
//ณ nao monta taxas, somente Saldos.                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Static Function FAMoedas(dData,cNumFatAut)

	Local nI 		:= 1
	Local aCabMoed	:=	{}
	Local aTamMoed	:=	{}
	Local aCpsMoed	:=	{}
	Local anTotRec	:= {}
	Local anTotBax	:= {}
	Local nRec		:= 0
	Local nBax		:= 0
	Local lNovo		:= .F.                  
	DEFAULT cNumFatAut := ""


	aCpsMoed:={"cMoeda","nTaxa","nRecebido","nBxTotMoed"}

	Posicione("SX3",2,"EL_MOEDA","X3_TITULO")
	Aadd(aCabMoed,X3Titulo())
	Posicione("SX3",2,"EL_TXMOEDA","X3_TITULO")
	Aadd(aCabMoed,X3Titulo())
	Aadd(aCabMoed,STR0047) // "Recebido"
	Aadd(aCabMoed,STR0048) //  "Saldo"

	aTamMoed:={23,35,48,30}

	If dData!=NIL						// Se a data for informada, remonta taxas das moedas
		For nI:= 1 to Len(aTaxa)
			aTaxa[nI]	:= xMoeda(1,nI,1,dData,TamSx3("M2_MOEDA"+Alltrim(Str(nI)))[2])
		Next nI
	Else
		For nI:= 1 to Len(aTaxa)
			aTaxa[nI]	:= aLinMoed[nI][2]
		Next nI
	Endif

	anTotRec:=SomaReceb()
	anTotBax:=SomaBaixa()

	nI:=1
	If lBax
		For nI := 1 To nQtMoedas
			nRec	:= anTotRec[nI]
			nBax 	:= anTotRec[nI] - anTotBax[nI]
			aLinMoed[nI]:={aNomeMoed[nI],aTaxa[nI],nRec,nBax}
		Next nI
	EndIf
	If !lRotAuto .And. oLBMoed==NIL 
		aSize := MSADVSIZE()
		oLBMoed	:=TwBrowse():New(001,(aSize[5]/2)-200,000,000,,aCabMoed,aTamMoed,oPanelTop,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		lNovo	:=.T.
	Endif

	If !lRotAuto
		IF lNovo
			oLBMoed:SetArray(aLinMoed)
			oLBMoed:bLine 	:= { ||{aLinMoed[oLBMoed:nAT][1],;
			Transform(aLinMoed[oLBMoed:nAT][2],PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)),TamSx3("M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)))[1])),;
			Transform(aLinMoed[oLBMoed:nAT][3],PesqPict("SEL","EL_VALOR",TamSx3("EL_VALOR")[1],oLBMoed:nAT)),;
			Transform(aLinMoed[oLBMoed:nAT][4],PesqPict("SEL","EL_VALOR",TamSx3("EL_VALOR")[1],oLBMoed:nAT)) }}

			oLBMoed:bLDblClick := {|| DCLBMoed(cNumFatAut)} //CBF
			oLBMoed:lHScroll:=.F.
			oLBMoed:lVScroll:=.T.
			oLBMoed:nHeight:=112
			oLBMoed:nWidth	:=400
		Else
			oLBMoed:Refresh()
		Endif
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomaReceb บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma todos os recebimentos.                       		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaReceb()

	Local nX:=1
	Local nPosMoed
	Local nPosVal
	Local anRec := Array(nQtMoedas)
	Local anR 	:= Array(nQtMoedas)

	aFill(anRec,0)
	aFill(anR,0)

	nPosMoed	:= AScan(aCposSEL,"EL_MOEDA")
	nPosVal	:= AScan(aCposSEL,"EL_VALOR")

	For nX:=1 to LEN(aCols)
		if !aCols[nX][Len(aCols[nX])] 		// Se o registro nao estiver deletado
			IF Empty(aCols[nX][nPosMoed]) .Or. aCols[nX][nPosMoed] <= "1"
				anRec[1] += aCols[nX][nPosVal]
			Else
				anRec[Val(aCols[nX][nPosMoed])]+=aCols[nX][nPosVal]
			Endif
		Endif
	Next nX

Return(anRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomaBaixa บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma valores a serem baixados.                    		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaBaixa()

	Local nX:=1
	Local nPosMoed
	Local nPosVal
	Local anBaixa 	:= Array(nQtMoedas)
	Local anB		:= Array(nQtMoedas)
	Local nMoed

	AFill(anBaixa,0)
	AFill(anB,0)

	nPosMoed:= AScan(aCposSE1,"E1_MOEDA")
	nPosTipo:= AScan(aCposSE1,"E1_TIPO")
	nPosVal	:= AScan(aCposSE1,"nBaixar")

	//ANGOLA - Inclusao de Adiantamento nao tem tela de titulos a baixar
	//Logo aLinSE1 nao vai existir para a soma de valores a baixar
	aLinSE1 := If(Type("aLinSE1") != "A",{},aLinSE1)

	For nX:=1 to LEN(aLinSE1)
		If aLinSE1[nX][1]== 1 // Esta Marcado
			For nMoed:=1 To nQtMoedas
				If aLinSE1[nX][nPosMotBx]=="DAC"
					// Nao deve fazer nada com os valores
				ElseIf aLinSE1[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG
					anBaixa[nMoed] -= aLinSE1[nX][anPosMoed[nMoed]]
				Else
					anBaixa[nMoed] 	+= aLinSE1[nX][anPosMoed[nMoed]]
					anB[nMoed]		+= aLinSE1[nX][anPosMoed[nMoed]]
				Endif
			Next nMoed
		Endif
	Next nX

	nTot:=0

	If nDescGer>0 
		anBaixa[nMoedDesc] -= nDescGer
	Endif

	If nPercGer>0
		nTot:=0
		nX:=0
		AEval(anB,{|x,y| nTot += x*aTaxa[y]})

		nTot:=nTot/aTaxa[nMoedDesc]
		anBaixa[nMoedDesc] -= Round(nPercGer*nTot*0.01, MsDecimais(nMoedDesc))
	Endif

Return(anBaixa)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomatitBaixa บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma valores a serem baixados sem considerar NEGATIVOS.       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaTitBaixa()

	Local nX:=1
	Local nPosMoed
	Local nPosVal
	Local anB		:= Array(nQtMoedas)
	Local nMoed

	AFill(anB,0)

	nPosMoed:= AScan(aCposSE1,"E1_MOEDA")
	nPosTipo:= AScan(aCposSE1,"E1_TIPO")
	nPosVal	:= AScan(aCposSE1,"nBaixar")

	For nX:=1 to LEN(aLinSE1)
		If aLinSE1[nX][1]== 1 // Esta Marcado
			For nMoed:=1 To nQtMoedas
				If aLinSE1[nX][nPosTipo]$MVRECANT+"/"+MV_CRNEG .Or. aLinSE1[nX][nPosMotBx]=="DAC"
				Else
					anB[nMoed]		+= aLinSE1[nX][anPosMoed[nMoed]]
				Endif
			Next nMoed
		Endif
	Next nX

Return(anB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840Head บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListBox que contem as taxas das moedas.     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA840Head(c_Alias,aCpos,lMark,aCposNo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parametros utilizados na funcao                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ c_Alias 	- Arquivo onde buscar as informacoes.     ณ
	//ณ aCpos 	- Campos a serem utilizados no cabecalho,     ณ
	//ณ caso nao seja informado, cria com base no SX3.        ณ
	//ณ aCposNo	- Campos que NAO devem aparecer na Get Dados. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retornos											  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ aRet[1]	- aHeader a ser utilizado na GetDados.		    ณ
	//ณ aRet[2]	- Array contendo campos validos.				ณ
	//ณ aRet[3]	- Array contendo cabecalho dos campos validos.	ณ
	//ณ aRet[4]	- Array contendo Tamanho dos campos validos.	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local aRet:= Array(4)
	Local aH  := {}
	Local aTam:= {}
	Local aCab:= {}
	Local aSeq:= {}
	Local nX
	Local nS
	Local cCboBox := ""

	If aCpos=NIL .Or. Len(aCpos)=0
		aCpos:={}
		If lMark
			Aadd(aCpos  ,"nSel")
			AAdd(aSeq	,"nSel")
			AADD(aCab	,"")
			AADD(aTam	,5)
		Endif
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(c_Alias,.F.)
		Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
			If x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. AScan(aCposNo,{|cpo| AllTrim(cpo) == AllTrim(X3_CAMPO)})==0  .And. ( X3_TIPO <> "M" )
				If c_Alias<>"SA1" .or. nFiltro<>3 .or. ;
				Alltrim(X3_CAMPO)$"A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC" .or. ;
				(X3_PROPRI=="U" .And. X3_VISUAL!="V" .And. X3_TIPO<>'M')
					// caso a selecao de clientes seja sem filtro, restringe a exibicao para aumentar a performance
					AAdd(aCpos,X3_CAMPO)
					If Alltrim(X3_CAMPO) == "EL_VALOR" .And. cPaisLoc == "ARG"
						AAdd(aCpos,"FE_VALBASE")
						AAdd(aCpos,"FE_ALIQ")
					EndIf
				EndIf
			Endif
			DbSkip()
		Enddo
	Else
		If lMark
			Aadd(aCpos  ,"")
			AAdd(aSeq	,"")
			AADD(aCab	,"")
			AADD(aTam	,0)
			For nX:= Len(aCpos) To 2 Step -1
				aCpos[nX]	:= aCpos[nX-1]
			Next nX
			aCpos[1]	:= "nSel"
			aSeq[1]		:= "nSel"
			aCab[1]		:= ""
			aTam[1]		:= 5
		Endif
	Endif

	//No caso de usar marca no list, o primeiro campo nใo deve ser consistido.
	If lMark
		nS:=2
	Else
		nS:=1
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX:=nS to Len(aCpos)
		If DbSeek(aCpos[nX],.F.) .And. x3uso(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CONTEXT!="V"
			If AllTrim(X3_CAMPO) == "EL_TIPODOC"

				cCboBox := AllTrim(X3CBOX())

				Aadd(aH,{Alltrim(X3_TITULO),X3_CAMPO,"",X3_TAMANHO,X3_DECIMAL,"",X3_USADO,X3_TIPO,"",X3_ARQUIVO,cCboBox,"","","","","",.F.})

			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				//ณSe o campo foi encontrado no X3 e esta disponivel, adiciona no aH     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
				AAdd(aH,{ TRIM(X3TITULO()), 	X3_CAMPO, 	X3_PICTURE,	X3_TAMANHO,	;
				X3_DECIMAL, X3_VALID,	X3_USADO,	;
				X3_TIPO, 	X3_ARQUIVO,	X3_CONTEXT } )
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//ณArmazena em um array separado as sequencias do aCpos que realmente serao utilizadas,ณ
			//ณpara depois poder se referenciar aos campos.                                        ณ
			//ณNao foi utilizado diretamente o aH pois esta rotina monta aHeader                   ณ
			//ณe Cabecalho do ListBox, e seriam posicoes distintas do Array.                       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			AADD(aCab,TRIM(X3Titulo()))
			AADD(aTam,iif(X3_TAMANHO > len(TRIM(X3Titulo())),X3_TAMANHO*4.1,len(TRIM(X3Titulo()))*4.1))

			AAdd(aSeq,X3_CAMPO)
		ElseIf Alltrim(X3_CAMPO) $ ("FE_VALBASE|FE_ALIQ") .And. cPaisLoc == "ARG"

			AAdd(aH,{ TRIM(X3TITULO()), 	X3_CAMPO, 	X3_PICTURE,	X3_TAMANHO,	;
			X3_DECIMAL, Iif( !Empty(AllTrim(X3_VALID)), AllTrim(X3_VALID) + " .And. GetValRet()", "GetValRet()" ),	X3_USADO,	;
			X3_TIPO, 	X3_ARQUIVO,	X3_CONTEXT } )	

			AADD(aCab,TRIM(X3Titulo()))
			AADD(aTam,iif(X3_TAMANHO > len(TRIM(X3Titulo())),X3_TAMANHO*4.1,len(TRIM(X3Titulo()))*4.1))

			AAdd(aSeq,X3_CAMPO)	
		EndIf
		DbSkip()
	Next nX

	aRet[1]:=aH		// aHeader
	aRet[2]:=aSeq		// Array contendo somente campos validos dos que foram passados.
	aRet[3]:=aCab		// Array contendo Titulo dos campos validos.
	aRet[4]:=aTam		// Array contendo Tamanho dos campos validos.

	SX3->(DbSetOrder(1))

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaGrid บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta linhas dos Grids                           		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaGrid(c_Alias,cWhile,cCond,lMark,cCMarca,cSeek,nInd,aCpos,lRecno,cQuery,lIncAdt,nPanel)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parametros utilizados na funcao                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ c_Alias 	- Arquivo onde buscar as informacoes.     ณ
	//ณ cWhile 	- Condicao inicial para o While.              ณ
	//ณ cCond 	- Se .T. o registro sera inserido no aC.      ณ
	//ณ lMark 	- Se usa Marca (somente para ListBox).        ณ
	//ณ cCMarca - Se .T. o registro vem marcado.              ณ
	//ณ cSeek 	- Registro inicial do while (performance).    ณ
	//ณ nInd 	- Indice da Busca.                            ณ
	//ณ aCpos 	- Campos utilizados (somente os validos).     ณ
	//ณ lRecno	- Se TRUE, carregara o RECNO na penultima pos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retorna aC, que sera utilizado como aCols ou Linhas   ณ
	//ณ do ListBox.											  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local lAchou:=.F.
	Local aC	:= {}
	Local nRecs
	Local nS	:=1
	Local nA	:=1
	Local aStru := {}
	Local aAreaAtu := GetArea()
	Local nLin     := 0
	Local nCol     := 0

	DEFAULT lRecno	:=	.F.
	DEFAULT cQuery  := ""

	//ANGOLA
	DEFAULT lIncAdt := .F.
	DEFAULT nPanel	 := 0 

	Private nSel  :=0

	nRecs	:=	If(lRecno,2,1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณDe acordo com todos os parametros passados, monto o aC. 	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	aC:={}
	If Empty(cQuery)
		DbSelectArea(c_Alias)
		DbSetOrder(nInd)
		DbGotop()
		DbSeek(cSeek,.F.)
	Else       
		//Acerta os campos conforme o seu tipo...           
		aStru  := (c_Alias)->(dbStruct()) 
		c_Alias:= c_Alias+"TMP"
		//Abre a area criada na query...
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), c_Alias, .F., .T.)

		For nA := 1 To Len(aStru)
			If aStru[nA][2] != "C" .And. aStru[nA][2] != "M" .And. FieldPos(aStru[nA][1]) != 0
				TCSetField(c_Alias, aStru[nA][1], aStru[nA][2], aStru[nA][3], aStru[nA][4])
			EndIf
		Next nA

		dbSelectArea(c_Alias)
		dbGoTop()		
	EndIf

	If !Empty(cQuery)
		DbEval({|| A840Load(@aC, nRecs, cCond, @lAchou, lRecno, aCpos, c_Alias)})

		//ANGOLA - Inclusao de adiantamento nao tera painel Clientes e Titulos para baixa
	ElseIf lIncAdt .and. c_Aliasn $ "SA1#SE1" 
		lAchou:=.F.

	Else
		While &(cWhile)
			If &(cCond)
				If lMark .And. &cCMarca
					nSel:= 1
				Else
					nSel := -1
				Endif
				lAchou:=.T.
				AAdd(aC,Array(Len(aCpos)+nRecs))
				For nA:=1 to Len(aCpos)
					aC[Len(aC)][nA]   := &(aCpos[nA])
				Next
				If lRecno
					If Empty(cQuery)
						aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->(Recno())
					Else
						aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->R_E_C_N_O_
					EndIf
				Endif	
				aC[Len(aC)][Len(aC[1])]:=.F.

				If c_Alias == "SE1"
					nLin := Len(aC)
					nCol := Len(aC[nLin])-1             

					If !Empty(aC[nLin][nCol])
						aC[nLin][nPosDesc]  := FaDescFin(c_Alias,dDataRef,(c_Alias)->E1_SALDO,(c_Alias)->E1_MOEDA)
						aC[nLin][nPosJuros] := fa070Juros(Max((c_Alias)->E1_MOEDA,1))
					EndIf

					//Monta arrays de controle de alteracoes...           
					AAdd(aLinSE1_Ori,{aC[nLin][1],aC[nLin][2],aC[nLin][3]})
				EndIf
			Endif

			DbSelectArea(c_Alias)
			DbSkip()
		Enddo
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณSe nao encontrar nenhum registro, cria novamente em branco.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	If !lAchou
		aC := Array(1,Len(aCpos)+nRecs)
		If lMark
			aC[1][1] := 0
			nS:=2
		Else
			nS:=1
		Endif
		SX3->(DBSetOrder(2))
		For nA:=nS to Len(aCpos)
			If SX3->(DbSeek(aCpos[nA]))
				aC[Len(aC)][nA]   := CriaVar(aCpos[nA],.F.)
			Else
				aC[Len(aC)][nA]   := &(aCpos[nA])
			Endif
		Next
		aC[Len(aC)][Len(aC[1])]:=.F.
	Endif

	If !Empty(cQuery)
		(c_Alias)->(dbCloseArea())
		RestArea(aAreaAtu)
	EndIf

	SX3->(DbSetOrder(1))

Return(aC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa840FldOk   บAutor  ณGuilherme C. Leal   บ Data ณ  20010730   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a valida็ใo por campo,  utilizada para atualizar moedas. บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a840FldOk()

	Local cCampo		:= Alltrim(ReadVar())
	Local cModoPago		:= ""
	Local dDtEmiss		:= dDataBase
	Local nPosCpo		:= 0
	Local nPosTipo		:= AScan(aCposSEL,"EL_TIPO")
	Local nPosBanco		:= AScan(aCposSEL,"EL_BANCO")
	Local nPosAgenc		:= AScan(aCposSEL,"EL_AGENCIA")
	Local nPosConta		:= AScan(aCposSEL,"EL_CONTA")
	Local lRet			:=.T.
	Local lBlockBco		:= SA6->A6_BLOCKED == "1"

	Do Case 
		Case cCampo=="M->EL_MOEDA" 
		nPosCpo := AScan(aCposSEL,"EL_MOEDA")        
		aCols[n][nPosCpo]:=&(cCampo)
		lRet:=Val(M->EL_MOEDA)<=nQtMoedas
		Case cCampo=="M->EL_VALOR"
		nPosCpo	:= AScan(aCposSEL,"EL_VALOR")
		aCols[n][nPosCpo]:=&(cCampo)
		Case cCampo=="M->EL_BANCO"
		aCols[n][nPosBanco] := &(cCampo)

		If lBlockBco
			Help(" ",1,"CCBLOCKED")
			lRet := .F.
		Endif

		Case cCampo == "M->EL_ENDOSSA"
		nPosCpo	:= AScan(aCposSEL,"EL_ENDOSSA")
		aCols[n][nPosCpo]:=&(cCampo)
		Case cCampo == "M->EL_DTVCTO"
		nPosCpo	:= AScan(aCposSEL,"EL_EMISSAO")
		dDtEmiss 	:= Iif(nPosCpo > 0, aCols[n][nPosCpo], dDataBase)

		nPosCpo	:= AScan(aCposSEL,"EL_TIPO")
		cModoPago	:= Iif(nPosCpo > 0, aCols[n][nPosCpo], "")

		lRet := F840VldVct(&(cCampo),dDtEmiss,cModoPago)		
		Case cPaisLoc=="ARG" .and. cCampo == "M->EL_PARCELA"
		nPosCpo	:= AScan(aCposSEL,"EL_TIPO")
		If Alltrim(aCols[n][nPosCpo])=="CH" .AND. !Empty(M->EL_PARCELA)
			MSGStop(STR0242) // "No debe existir cuota para documento del tipo cheque"
			M->EL_PARCELA:=space(TamSx3("EL_PARCELA")[1])	
		EndIf		
		Case cPaisLoc=="ARG" .and. cCampo == "M->EL_TIPO" .AND. Alltrim(M->EL_TIPO)=="CH" 
		nPosCpo	:= AScan(aCposSEL,"EL_PARCELA")
		aCols[n][nPosCpo]:=space(TamSx3("EL_PARCELA")[1])	
		Case cPaisLoc=="ARG" .and. cCampo == "M->EL_BCOCHQ" 
		nPosCpo	:= AScan(aCposSEL,"EL_PREFIXO")
		If Empty(aCols[n][nPosCpo])
			aCols[n][nPosCpo]:= M->EL_BCOCHQ
		EndIf
	EndCase
	If (lRet,FaMoedas(),)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa840LinOk  บAutor  ณGuilherme C. Leal   บ Data ณ  05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListBox que contem as taxas das moedas.     			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados na funcao                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ lTudo	- Indica se rotina esta sendo chamada pela TUDOOK() |
//ณ nLinaCols - Linha do aCols a ser Validada.             		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
Function Fa840LinOk(lTudo,nLinaCols)

	Local nI			:= 0
	Local lRet			:= .T.
	Local nPosPref		:= 0
	Local nPosNum		:= 0
	Local nPosParc		:= 0
	Local nPosBcoDep	:= 0
	Local nPosAgeDep	:= 0
	Local nPosCtaDep	:= 0
	Local nPosTpDoc	:= 0
	Local nPosTipo		:= 0
	Local nPosEndoss	:= 0
	Local nPosTerc		:= 0
	Local nPosBcoChq    := 0
	Local nPosAgeChq    := 0
	Local nPosPostal    := 0
	Local cTipCobra     := " "
	Local cCfgTerc		:= ""
	Local aBcoDefault   := {}

	Local aHelpPor := {}
	Local aHelpEsp := {}
	Local aHelpEng := {}

	Local nPosMun 	 := 0
	Local nPosEst    := 0
	Local nPosCodFis := 0
	Local nPosRetGan := 0
	Local nPosRetSUS := 0
	Local nPosBaseR  := 0
	Local nPosAliqR  := 0
	Local nPosValR   := 0  
	Local nNumDocPag := 0
	Local aDesCols := {} 
	Local nColCos 	 := 0

	If lTudo
		n := nLinaCols
	EndIf

	nPosPref	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_PREFIXO"})
	nPosNum	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_NUMERO" })
	nPosParc	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_PARCELA"})
	nPosBcoDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_BANCO"})
	nPosAgeDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_AGENCIA"})
	nPosCtaDep	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_CONTA"})

	nPosTpDoc 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_TIPODOC"})
	nPosTipo 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_TIPO"})
	nPosValor 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_VALOR"}) 
	nPosMoeda 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_MOEDA"})
	nPosEmiss	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_EMISSAO"})
	nPosVencto	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_DTVCTO"})
	nPosCGC 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_CGC"}) //CUIT
	nPosTrans 	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_TRANSIT"}) 
	nPosEndoss	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_ENDOSSA"})
	nPosTerc   := AScan(aHeader,{|x|Alltrim(x[2]) == "EL_TERCEIR"})
	aBcoDefault:= xCxFina()

	If  cPaisLoc == "ARG"
		If SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
			nPosMun		:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_RET_MUN"})
		EndIf 
		nPosEst		:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_EST"})
		nPosCodFis	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_CFO"})
		nPosRetGan	:= AScan(aHeader,{|x|Alltrim(x[2]) == "A2_AGREGAN"})
		nPosRetSUS	:= AScan(aHeader,{|x|Alltrim(x[2]) == "A2_CONCSUS"})
		nPosBaseR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_VALBASE"})
		nPosAliqR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_ALIQ"})
		nPosValR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_VALOR"})
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Requisito de Controle de Entidades Bancarias de Terceiros       ณ
	//ณ  Valida a obrigatoriedade de preenchimento do campo  EL_BCOCHQ   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cPaisLoc <> "RUS" 
		nPosBcoChq := AScan( aHeader, {|x|Alltrim( x[2] ) == "EL_BCOCHQ" } )
		nPosAgeChq := AScan( aHeader, {|x|Alltrim( x[2] ) == "EL_AGECHQ" } )
	Endif
	If cPaisLoc == "ARG" 
		If SEL->( FieldPos("EL_POSTAL") ) > 0
			nPosPostal := AScan( aHeader, {|x|Alltrim( x[2] ) == "EL_POSTAL" } )
		EndIf
	EndIf

	//Usuario nao digita o numero do documento, logo, supoe que nao houve nenhum recebimento e 
	//serah feita compensacao de igual valor entre titulos a receber e RAs
	If lTudo .And. !(aCols[n][Len(aCols[n])])
		If Empty(aCols[n][nPosNum]) .And. !(aCols[n][nPosValor] > 0) .And. AllTrim(aCols[n][nPosTpDoc]) != "DC" //DC - Pagare
			aCols[n][Len(aCols[n])]  := .T.      
		EndIf
	EndIf   

	IF !(aCols[n][Len(aCols[n])])    // Somente Linhas nใo Deletadas

		For nI:= 1 to Len(aHeader)
			&("M->"+aHeader[nI][2]):= aCols[n][nI]
		Next nI
		If lCarga .And. lRet
			lRet:=(Upper(AllTrim(Posicione("DAP",1,xFilial("DAP")+cCarga+cSeqCar+aCols[n][nPosTpDoc],"DAP_CODGRU")))==Upper(AllTrim(aCols[n][nPosTpDoc])))
			If !lRet
				If !lRotAuto
					Alert(STR0101)   // Tipo de Valor nใo ingressado na conferencia da carga.
				Else
					cTxtRotAut := STR0101 +" "+ CRLF
					lMsErroAuto := .T.
				EndIf			
				lRet := .F.
			EndIf
			Iif(lRet,lRet:=(DAP->DAP_VALPRE+M->EL_VALOR<=DAP->DAP_REALIZ),)
			If !lRet`
				If !lRotAuto
					Alert(STR0100) // Valor prestado ultrapassa o valor realizado para esta carga.
				Else 
					cTxtRotAut := STR0100 +" "+ CRLF
					lMsErroAuto := .T.
				EndIf
				lRet := .F.
			EndIf
		EndIf
		Iif(lRet .And. Val(M->EL_MOEDA)!=1 .And. aTaxa[Val(M->EL_MOEDA)]==0,leTaxa:=.T.,leTaxa:=.F.)
		Iif(lRet,lRet:=M->EL_DTVCTO>=M->EL_EMISSAO,)
		If !lRotAuto	
			Iif(lRet,oLBMoed:Refresh(),)
		EndIf
		If lRet
			aDesCols := Array(Len(aCols) - N)

			For nI := 1 To len(aCols)
				If nI != N .And. aCols[nI][Len(aHeader)+1] != .T.
					If N < Len(aCols)
						aCopy(aCols,aDesCols, N+1, Len(aCols))
						nNumDocPag := AScan(aDesCols,{|x| x[nPosTpDoc]+x[nPosPref]+x[nPosNum]+x[nPosParc]==aCols[n][nPosTpDoc]+aCols[n][nPosPref]+aCols[n][nPosNum]+aCols[n][nPosParc] .And. x[Len(aHeader)+1] == aCols[n][Len(aHeader)+1]})
						lRet:=IIf(nNumDocPag == 0, .T., .F.)
					EndIf
					If lRet
						nNumDocPag := AScan(aCols,{|x| x[nPosTpDoc]+x[nPosPref]+x[nPosNum]+x[nPosParc]==aCols[n][nPosTpDoc]+aCols[n][nPosPref]+aCols[n][nPosNum]+aCols[n][nPosParc]})
						lRet:=IIf(nNumDocPag > 0 .And. nNumDocPag == N, .T., .F.)
					EndIf
					If!lRet
						Alert(OemToAnsi(STR0060)) //  "Este Registro ya se incluy๓."
						Exit
					Endif
				Endif
			Next nI
		Endif                 

		//Validar o banco dependendo do tipo de titulo
		If lRet 
			DbSelectArea("SA6")
			DbSetOrder(1)
			If AllTrim(aCols[n][nPosTipo]) $ cCredMed+"/"+cCredInm .And. Subs(aCols[n][nPosTpDoc],1,2) != "EF" .And. AllTrim(aCols[n][nPosTpDoc]) != "DC"
				If Empty(aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep]) .Or. !DbSeek(xFilial("SA6")+aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep])
					Help("",1,"FA840DEP")  //"Caja no existente"
					lRet	:=	.F.
				Endif
			ElseIf AllTrim(aCols[n][nPosTipo]) $ cCredMed+"/"+cCredInm .And. Subs(aCols[n][nPosTpDoc],1,2) = "EF" //Tipo EF, caso nao 
				If Empty(aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep])									//seja preenchido o banco
					aCols[n][nPosBcoDep]:= aBcoDefault[1]																		//deve ir para o caixa fin
					aCols[n][nPosAgeDep] := aBcoDefault[2]
					aCols[n][nPosCtaDep] := aBcoDefault[3]
					If !lRotAuto
						oGetSEL:oBrowse:Refresh()		
					EndIf		
				ElseIf !DbSeek(xFilial("SA6")+aCols[n][nPosBcoDep]+aCols[n][nPosAgeDep]+aCols[n][nPosCtaDep])
					Help("",1,"FA840DEP")  //"Caja no existente"
					lRet	:=	.F.
				Endif
			ElseIf AllTrim(aCols[n][nPosTpDoc]) == "DC" //Pagar้
				If !Empty(aCols[n][nPosBcoDep]) .And. !(aCols[n][nPosBcoDep] $ (GetNewPar("MV_CARTEIR","") + "/" + Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
					Help( " ", 1, "FA840BCO")//"Banco invแlido para Pagar้"				
					lRet := .F.
				EndIf
			Endif

			If (lTudo .and. (nPanel == 1) .and. (aCols[n][nPosTpDoc] $ cTiposAdm))
				lRet := TelaAdmCar(	aCols[n][nPosPref],aCols[n][nPosNum],;
				aCols[n][nPosParc],aCols[n][nPosValor],;
				Val(aCols[n][nPosMoeda]),n)			
			Endif
		Endif

		SE1->(DbSetOrder(1))
		If lRet .And. SE1->(DbSeek(xFilial("SE1")+aCols[n][nPosPref]+aCols[n][nPosNum]+aCols[n][nPosParc]+Padr(aCols[n][nPosTpDoc],TAMSX3("E1_TIPO")[1])))
			If !lRotAuto 
				MsgAlert(STR0113)  //"Documento para recebimento ja existe. Verifique Tipo do Valor,Prefixo,Numero ou Parcela."
			Else 
				cTxtRotAut +=  STR0113   +" "+ CRLF
				lMsErroAuto := .T.
			EndIf
			lRet := .F.
		EndIf
		If cPaisLoc<> "BRA" .And. lRet .And. aCols[n][nPosTipo] $ cCredInm .And. aCols[n][nPosVencto] <> dDataBase
			Help(" ",1,"BLOQDTVENC")
			lRet:= .F.
		EndIf
		If lRet
			lRet:=lRetCkPG(0,aCols[n][1],aCols[n][10],IF(aCols[n][1]$"TF",2,1))
		Endif

		If lRet .and. nPosTrans > 0 .and. nPosTipo > 0 .and. FJS->(FieldPos("FJS_TRANS")) > 0
			If FJS->(GetAdvFVal("FJS","FJS_TRANS",xFilial("FJS")+PadR(aCols[n][nPosTipo],TamSx3("FJS_TIPO")[1]),1,"")) == "2" 
				If aCols[n][nPosTrans] != "2"
					Help(" ", 1, "FANOTRANSIT",,STR0190,1,0)//"Nใo ้ possํvel usar documento em transito para o tipo de documento em questใo"
					lRet:= .F.
				EndIf
			EndIf 
		EndIf

		//EL_TIPODOC = DC (Pagare) - Caso o numero do documento esteja preenchido o CUIT (EL_CGC) devera ser preenchido
		If lRet .And. (nPosCGC > 0) .And. (AllTrim(aCols[n][nPosTpDoc]) $ "DC") .And. !Empty(aCols[n][nPosNum]) .And. Empty(aCols[n][nPosCGC])
			Help(" ", 1, "IDCONTVAZIO") 
			lRet:= .F.
		EndIf

		//Caso o campo Numero (EL_NUMERO) esteja vazio o campo CUIT (EL_CGC) tamb้m deverแ permanecer vazio
		If lRet .And. (nPosCGC > 0) .And. (AllTrim(aCols[n][nPosTpDoc]) $ "DC") .And. Empty(aCols[n][nPosNum]) .And. !Empty(aCols[n][nPosCGC])
			aCols[n][nPosCGC] := CriaVar("EL_CGC",.F.)
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHฟ
		//ณValida a obrigatoriedade de preenchimento do campo Numero (EL_NUMERO)ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHู
		If lRet .And. Empty(aCols[n][nPosNum]) .And. AllTrim(aCols[n][nPosTpDoc]) != "DC"
			lRet := .F.												
			Help(" ", 1, "NUMEROVAZIO")
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Requisito de Controle de Entidades Bancarias                   ณ
		//ณ  Valida a obrigatoriedade de preenchimento do campo  EL_BCOCHQ  ณ
		//ณ  Depende da Criacao da tabela FJN - Entidades Bancarias         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If lRet .and. cPaisLoc <> "RUS""
			If AllTrim( aCols[ n ][ nPosTpDoc ] ) == "CH" 
				If Empty( aCols[ n ][ nPosBcoChq ] ) 
					lRet := .F.
					If !lRotAuto
						ApMsgAlert( OemToAnsi( STR0208 ) )   // "O campo <Banco Cheque> deve ser preenchido !" 
					Else
						cTxtRotAut +=  OemToAnsi( STR0208 )	 +" "+ CRLF
						lMsErroAuto := .T.
					EndIf												
				EndIf
			Else
				If !Empty( aCols[ n ][ nPosBcoChq ] ) 

					lRet := .F.												
					// "Para este Tipo de Titulo, o campo <Banco Cheque> nใo deve ser preenchido."  
					If !lRotAuto
						ApMsgAlert( STR0215 + RetTitle( "EL_BCOCHQ" ) + STR0216, STR0149 )  // "Para este Tipo de Tํtulo, el campo < " # " > no debe completarse." #"Atenci๓n"    
					Else 
						cTxtRotAut += STR0215 + RetTitle( "EL_BCOCHQ" ) + STR0216  +" "+  STR0149  +" "+ CRLF  // "Para este Tipo de Tํtulo, el campo < " # " > no debe completarse." #"Atenci๓n"    
						lMsErroAuto := .T.
					EndIf
					If lRet 
						aCols[ n ][ nPosBcoChq ] := CriaVar( "EL_BCOCHQ" )
						aCols[ n ][ nPosAgeChq ] := CriaVar( "EL_AGECHQ" )                 

						If cPaisLoc = "ARG"
							aCols[ n ][ nPosPostal ] := CriaVar( "EL_POSTAL" )
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Requisito de Entidades Bancarias - Fim  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Valida็ใo FJS X SEL - Terceiro e Endossa
		If lRet .And. nPosTerc > 0 .And. nPosEndoss > 0 .And. nPosTipo > 0 

			cCfgTerc := FJS->(GetAdvFVal("FJS","FJS_TERCEI",xFilial("FJS")+PadR(aCols[n][nPosTipo],TamSx3("FJS_TIPO")[1]),1,""))

			//EL_TERCEIR
			If lRet .And. AllTrim(cCfgTerc) $ "2|4" .And. aCols[n][nPosTerc] <> "1"
				Help(" ", 1, "FA840ALTTR")
				lRet:= .F.
			EndIf

			//EL_ENDOSSA
			If lRet .And. AllTrim(cCfgTerc) $ "1|4" .And. aCols[n][nPosEndoss] <> "2"
				Help(" ", 1, "FA840ALTEN")
				lRet:= .F.
			EndIf

			//Valida็ใo Cheque Terc. X  CUIT
			If lRet .And. nPosTerc > 0 .And. nPosTpDoc > 0 .And. nPosCGC > 0 	
				If aCols[n][nPosTerc] == "2" .And. aCols[n][nPosTpDoc] $ MVCHEQUE .And. Empty(aCols[n][nPosCGC])
					Help(" ", 1, "FA840IDTRC") 
					lRet:= .F.
				EndIf
			EndIf

			//Valida data de vencimento
			If lRet .And. nPosVencto > 0 .And. nPosEmiss > 0 .And. nPosTipo > 0 	
				lRet := F840VldVct(aCols[n][nPosVencto],aCols[n][nPosEmiss],aCols[n][nPosTipo])
			EndIf

			//-------------------------------------------------------------------------
			// Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			//-------------------------------------------------------------------------
			If lRet
				lRet := FA840TpBco(aCols[n][nPosTipo],aCols[n][nPosBcoDep],aCols[n][nPosAgeDep],aCols[n][nPosCtaDep])
			EndIf
			If  cPaisLoc == "ARG"
				If Alltrim(aCols[n][nPosTipo]) $ ("RB|RI|RG|RS|RM") .And. lRet
					If ( aCols[n][nPosValR] > 0 ) .And. ( aCols[n][nPosBaseR] == 0)  
						Help(" ", 1, "VALBASEVAZIO")
						lRet := .F.
					ElseIf ( aCols[n][nPosValR] > 0 ) .And. ( aCols[n][nPosAliqR] == 0)
						Help(" ", 1, "ALICUOTAVAZIO")
						lRet := .F.	
					EndIf		
				EndIf
				If Alltrim(aCols[n][nPosTipo]) == "RB" .And. lRet 
					If Empty(Alltrim(aCols[n][nPosEst]))  
						Help(" ", 1, "ESTADOVAZIO")
						lRet := .F.
					ElseIf Empty(Alltrim(aCols[n][nPosCodFis]))
						Help(" ", 1, "CODFISVAZIO")
						lRet := .F.	
					EndIf		
				ElseIf Alltrim(aCols[n][nPosTipo]) == "RI" .And. lRet
					If Empty(Alltrim(aCols[n][nPosCodFis])) 
						Help(" ", 1, "CODFISVAZIO")
						lRet := .F.	
					EndIf	
				ElseIf Alltrim(aCols[n][nPosTipo]) == "RG" .And. lRet
					If Empty(Alltrim(aCols[n][nPosRetGan]))
						Help(" ", 1, "ACTRETIGVAZIO")
						lRet := .F.	
					EndIf	
				ElseIf Alltrim(aCols[n][nPosTipo]) == "RS" .And. lRet
					If Empty(Alltrim(aCols[n][nPosRetSUS]))  
						Help(" ", 1, "CONCSUSSVAZIO")
						lRet := .F.	
					EndIf
				ElseIf Alltrim(aCols[n][nPosTipo]) == "RM" .And. lRet
					If Empty(Alltrim(aCols[n][nPosCodFis])) 
						Help(" ", 1, "CODFISVAZIO")
						lRet := .F.
					ElseIf Empty(Alltrim(aCols[n][nPosEst]))
						Help(" ", 1, "ESTADOVAZIO")
						lRet := .F. 
					ElseIf SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
						If Empty(Alltrim(aCols[n][nPosMun])) 
							Help(" ", 1, "CODRETMUNVAZIO")
							lRet := .F.	
						EndIf
					EndIf	
				EndIf
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Validacao de Documento em Transito                             ณ
		//ณ  Confronta AQ_DOCTRAN com o conteudo do aCols campo EL_TRANSIT  ณ
		//ณ                                                                 ณ
		//ณ  AQ_DOCTRAN , Documento em Transito : 1 = Sim                   ณ
		//ณ                                     : 2 = Nao                   ณ
		//ณ                                     : 3 = Indiferente           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lRet .And. !Empty( cCobrador ) 
			// 
			If cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|TRI|URU|VEN" .And. nPosTrans > 0
				// 
				cTipCobra := GetAdvFVal("SAQ","AQ_DOCTRAN",xFilial("SAQ")+cCobrador,1,"")         
				// 
				If cTipCobra != "3"   // Se for Indiferente, nao verifica
					// 
					If cTipCobra == "1" .And. AllTrim( aCols[n][nPosTrans] ) == "2"   // Documento em Transito, 2 = Nao  
						lRet := .F.
						If !lRotAuto
							ApMsgAlert( STR0213 )  // "O cobrador informado so pode receber documentos em transito. Altere o tipo de documento ou cobrador."
						Else
							cTxtRotAut :=  STR0213  +" "+ CRLF
							lMsErroAuto := .T.
						EndIf
					EndIf
					//
					If lRet .And. cTipCobra == "2" .And. AllTrim( aCols[n][nPosTrans] ) == "1"   // Documento em Transito, 1 = Sim
						lRet := .F.
						Help(" ",1,"NODOCTRAN",,STR0200,1,0) //"O cobrador informado nao pode receber documentos em transito. Altere o tipo de documento ou cobrador"
					EndIf

				EndIf

			EndIf
		EndIf

	
		If lRet //Solo valide si las demas validaciones estan OK
			If cPaisLoc == "ARG" .And. (SEL->(FieldPos('EL_SIRESEG'))>0 .And. SEL->(FieldPos('EL_SIRECER'))>0 ) .And. (SFE->(FieldPos('FE_SIRECER'))>0 .And. SFE->(FieldPos('FE_SIRESEG'))>0)
				lRet := VldCerSUSS()
			EndIf    
			If cPaisLoc == "ARG" .And. M->EL_TIPO == "RS" .And. Empty(M->EL_SIRESEG) .And. Empty(M->EL_SIRECER)		
				 lRet := .F.
			EndIf	 
		Endif    
	
	
	EndIf
	If len(aCols)>1 .And. cPaisLoc == "ARG" 
		nColCos:= Len(aCols[N])
		If (ALLTRIM(aCols[1][1])=="GR" .AND. ALLTRIM(aCols[N][1])<>"GR" .AND. aCols[N][nColCos] != .T.) .Or. (ALLTRIM(aCols[1][1])!="GR" .AND. ALLTRIM(aCols[N][1])=="GR" .AND. aCols[N][nColCos] != .T. )
			 Help(" ", 1,OemToAnsi(STR0262),,OemToAnsi(STR0263),1,0)
			lRet := .F.
	    EndIf
	EndIf


Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFa840TudoOk   บAutor  ณGuilherme C. Leal บ Data ณ05/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a validacao de todos os campos.               		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa840TudoOk(cNumFatAut,lIncAdt)

	Local nI:=0
	Local nX := 0
	Local lRet:=.T.
	Local lTemReceb := .F.        
	Local cErrMoed:=""
	Local aArea:={}
	Local aNumCert  := {}
	Local nPosTpDoc := AScan(aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})
	Local nPosTrans := AScan(aHeader,{|x|Alltrim(x[2])=="EL_TRANSIT"})
	Local lTransit	:= .F.

	Private leTaxa:=.F.            

	DEFAULT cNumFatAut := ""
	DEFAULT lIncAdt	:= .F. //Angola - Inclusao de Adiantamento

	If Empty(cRecibo)
		If !lRotAuto
			MsgStop(STR0116) //  "Por favor, primero indique el campo de nบ de recibo"
		Else
			cTxtRotAut += STR0116		 +" "+ CRLF //  "Por favor, primero indique el campo de nบ de recibo"
		EndIf
		lRet:=.F.
	EndIf

	If lRet .And. Empty(cCliente)
		Help(" ",1,"NUMCLI") 
		lRet:=.F.
	EndIf

	If lRet .And. Empty(cLoja)
		Help(" ",1,"NUMCLI") 
		lRet:=.F.
	EndIf      

	If lRet .And. !(dtMovFin(dDataRef,,"2") )      // Verificar data do recibo com o parametro MV_DATAFIN
		lRet:=.F.            
	EndIf

	If lRet .And. Empty(dDataRef)
		If !lRotAuto
			MsgStop(STR0099)  //"Data de Emissao Invalida."
		Else
			cTxtRotAut += STR0099		 +" "+ CRLF  //"Data de Emissao Invalida."
		EndIf
		lRet:=.F.            
	EndIf

	If lRet .And. !lIncAdt		//ANGOLA - Nao e inclusao de adiantamento
		If nPanel == 2 
			MsAguarde({||RefData(3,cNumFatAut) })
		ElseIf nPanel == 3 
			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aCols[nX])] 		
					lTemReceb  := .T.        
					Exit
				EndIf
			Next nX    	
			If !lTemReceb
				For nX := 1 to Len(aLinMoed)      
					If aLinMoed[nX][4] > 0
						If !lRotAuto
							Alert(STR0114) //"Para compensacoes sem recebimento de titulos, o saldo da operacao deve ser zero!"
						Else
							cTxtRotAut += STR0114  +" "+ CRLF //"Para compensacoes sem recebimento de titulos, o saldo da operacao deve ser zero!"
						EndIf
						lRet  := .F.
						Exit
					EndIf
				Next nX
				If lRet .And. cPaisLoc == "PER" 
					lRet := Fa840IGV(cCliente,cLoja,cNumFatAut)  
				EndIf    
			ElseIf cPaisLoc $ "PER" 
				// verifica se ha retencoes (para criar os gets dos valores rateados pelos titulos selecionados) 
				lRet := Fa840Ret()                                  
			ElseIf cPaisLoc == "PER"
				lRet := Fa840IGV(cCliente,cLoja,cNumFatAut)
			EndIf
		EndIf
	Endif

	If lRet .And. IIf(cPaisLoc == "ARG", nPanel < 2 .Or. nPanel > 3, .T.)
		AEval(aLinMoed,{|x,y|If(x[4]<0,cErrMoed+=SuperGetmv("MV_MOEDA"+Alltrim(STR(y)))+", ",) })
		cErrMoed:=Alltrim(cErrMoed)
		If Len(cErrMoed)>0
			lRet:=.F.
			IF !lRotAuto
				Alert(STR0050 + Left(cErrMoed,Len(cErrMoed)-1) + STR0051) //"Saldo em "###" insuficiente para efetuar a baixa. "
			Else
				cTxtRotAut += STR0050 + Left(cErrMoed,Len(cErrMoed)-1) + STR0051  +" "+ CRLF // /"Saldo em "###" insuficiente para efetuar a baixa. "
			EndIF
		Endif
	EndIf

	If lRet .And. nPanel == 1
		For nI:= 1 to Len(aCols)
			lRet:=Fa840LinOk(.T.,nI)
			If lRet .And. leTaxa
				If !lRotAuto
					Alert(STR0049) //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."
				Else
					cTxtRotAut += STR0049		 +" "+ CRLF	 //"Informe todas as taxas das moedas que serใo utilizadas nos Documentos."				
				EndIf
				lRet:=.F.
				Exit
			Endif
			If !lRet 
				If !lRotAuto
					oGetSEL:oBrowse:nAt:=nI
					oGetSEL:oBrowse:Refresh()
					oGetSEL:oBrowse:SetFocus()
				EndIF
				Exit
			Endif
		Next nI                        

		If lRet .And. cPaisLoc $ "EQU|VEN"
			For nX := 1 To Len(aCols)
				If ! aCols[nX][Len(aCols[1])]	
					If cPaisLoc $ "EQU|VEN" .And. AllTrim(aCols[nX][nPosTpDoc]) $ "RI|RR"
						aNumCert  := GerNumCert("IVA",.F.)    
						If Len(aNumCert) == 0
							If !lRotAuto
								MsgAlert(STR0169,STR0149) //"Tabla de Control de Comprobantes invalida, favor evaluar la tabla SFP en el m๓dulo Fiscal.","Atenci๓n!")
							Else
								cTxtRotAut += STR0169+" " + " " + STR0149  +" "+ CRLF //"Tabla de Control de Comprobantes invalida, favor evaluar la tabla SFP en el m๓dulo Fiscal.","Atenci๓n!")	                		
							EndIF
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf                	 
	Endif

	If lRet .And. (nPanel < 5) .And. (nPanel != nlastPan)
		FaMoedas()
	EndIf

	If lRet .And. !Empty(cCobrador)
		aArea:=GetArea()       
		DbSelectArea("SAQ")
		DbSetOrder(1)
		If dbSeek(xFilial("SAQ")+cCobrador) 
			ctipo:= SAQ->AQ_TIPOREC
			If cTipo<> "3" .and. lRet
				lRet:= FA840Cob(cTipo)
			EndIf
		EndIf	
		RestArea(aArea)
	EndIf 

	If lRet
		lRet:=IF(cPaisLoc=='PER' .AND. AllTrim(cCalcITF) == '1',If(!Empty(cNatureza),CkNatureza(cNatureza,@lNatureza),;
		Eval({||IIf(!lRotAuto,MsgAlert(STR0166),cTxtRotAut += STR0166+" "+CRLF ),.F.})),.T.) // "กEl campo Modalidad es obligatorio!"
	Endif  

	If lRet .And. ExistBLock('A087TUDOK')
		lRet :=	ExecBlock('A087TUDOK',.F.,.F.,nPanel)	
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA840DelLinบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A840DelLin()

	FaMoedas()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA840PagtosบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840Pagtos(nLin,cNumFatAut,lAltTitulo)

	Local nI 			:= 0
	Local nPosMoed		:= AScan(aCposSE1,"E1_MOEDA")
	Local nPosValor		:= AScan(aCposSE1,"E1_VALOR")
	Local aValores      := Array(8)
	Local nPosBaixa		:= Ascan(aCposSE1,"nBaixar") 
	Local nX 			:= 0
	Local aLinTit1 		:= {}
	Local nPosPref  	:= Ascan( aCposSE1, "E1_PREFIXO")
	Local nPosNum   	:= Ascan( aCposSE1, "E1_NUM")
	Local nPosParc  	:= Ascan( aCposSE1, "E1_PARCELA")
	Local nPosTipo  	:= Ascan( aCposSE1, "E1_TIPO")   
	Local nPosCli   	:= Ascan( aCposSE1, "E1_CLIENTE")   
	Local nPosLoja  	:= Ascan( aCposSE1, "E1_LOJA") 
	Local nPosNatu  	:= Ascan( aCposSE1, "E1_NATUREZ") 
	Local nPosImpRet    := AScan(aCposSE1,"nImpRetSE1")
	Local nAliq2		:= 0
	Local nAliq1		:= 0
	Local cCalcITF   	:= SuperGetMv("MV_CALCITF",.F.,"2")
	Local aConcepto		:= {}
	Local lRet 			:= .T.
	Local aAreaSE1a:={}
	Local lRaGR := .F.
	Local lRaNor := .F.
	Local lLocAgr 	:=  cPaisLoc == "ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0 .AND. SEL->(ColumnPos("EL_TIPAGR")) >0.AND.  SF2->(ColumnPos("F2_CANJE"))>0

	DEFAULT cNumFatAut 	:= ""
	DEFAULT lAltTitulo	:= .T.

	//Se nao for um registro valido sai
	If aLinSE1[nLin,1]== 0
		lRet := .F.
	EndIf
	If lRet .And. cPaisLoc=="PER" .and. AllTrim(cCalcITF) == "1"
		If lFindITF .AND. FinProcITF( ,1,,,,,aLinSE1[nLin,nPosNatu])
			If !lNatureza
				lRet := .F.
				IF !lRotAuto
					MsgAlert(STR0159 + " ["+ cNatureza + "] " + STR0160) // "La Modalidad" #   "no se tributa por ITF. Seleccione tํtulos sin tributacion de ITF."
				ELSE 
					cTxtRotAut += STR0159 + " ["+ cNatureza + "] " + STR0160  +" "+ CRLF //"La Modalidad" #   "no se tributa por ITF. 
				EndIf
			EndIF
		EndIf
	Else
		If lNatureza
			IF !lRotAuto      	
				MsgAlert(STR0159 + " [" + cNatureza + "] " + STR0161) // "La Modalidad" #   "se tributa por ITF. Seleccione tํtulos sin tributacion de ITF."
			ELSE
				cTxtRotAut += STR0159 + " [" + cNatureza + "] " + STR0161 +" "+ CRLF // "La Modalidad" #   "se tributa por ITF. Seleccione tํtulos sin tributacion de ITF."
			ENDIF	
			lRet := .F.
		Endif   	  
	EndIf

// verifica tipo de RA
 	
 	lRaGR:=.F.
 	lRaNor:=.F.
 	If lRet .And. lLocAgr .and. Alltrim(aLinSE1[nLin,nPosTipo]) =="RA"
 		aAreaSE1a:=SE1->(GetArea())
 		SE1->(DbSetOrder(1))
 		If SE1->(MsSeek(xFilial("SE1")+ aLinSE1[nLin][nPosPref]+aLinSE1[nLin][nPosNum]+aLinSE1[nLin][nPosParc]+aLinSE1[nLin][nPosTipo]))
 			If SE1->E1_TIPOGR=="1"
 				lRaGR:=.T.
 			Else
 				 lRaNor:=.T.
 			EndIf
 		EndIf
 	
		
		For nX:=1 to Len(aLinSE1)
			If  nX <> nLin

				If Alltrim(aLinSE1[nX][nPosTipo]) =="RA"  .and. aLinSE1[nX][1]=1 
									
					SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									
					If SE1->(MsSeek(xFilial("SE1")+ aLinSE1[nX][nPosPref]+aLinSE1[nX][nPosNum]+aLinSE1[nX][nPosParc]+aLinSE1[nX][nPosTipo]))
						  If SE1->E1_TIPOGR=="1" 
						  		lRaGR:=.T.
						  Else
						  		lRaNor:=.T.
						  EnDif
					EndIf
									
				EndIf
			Endif
			If lRaGR  .And. 	lRaNor					
				IF !lRotAuto      	
					MsgAlert("Existe RAs do Tipo Granos Seleccionado e No Granos Seleccionados, verifique los registros seleccionados" )
				ELSE
					cTxtRotAut += "Existe RAs do Tipo Granos Seleccionado e No Granos Seleccionados, verifique los registros seleccionados" 
				ENDIF	
				nX:= Len(aLinSE1)
				lRet:= .F.
			EndIf
			
		Next	
		SE1->(RestArea(aAreaSE1a))
	EndIf

	If lRet   
		//Se esta marcado desmarca
		If (aLinSE1[nLin,1] * -1) != 1 
			aLinSE1[nLin,1] := aLinSE1[nLin,1] * -1

			aLinSE1[nLin][nPosDesc]  	:=0
			aLinSE1[nLin][nPosJuros]	:=0
			aLinSE1[nLin][nPosMulta]	:=0

			if nPosImpRet > 0
				aLinSE1[nLin][nPosImpRet]	:=0
			endif

			for nI:=1 to nQtMoedas
				&("nPosBx" + Alltrim(Str(nI))) := Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
				aLinSE1[nLin][&("nPosBx" + Alltrim(Str(nI)))] := 0
			Next nI
			aLinSE1[nLin][nPosBaixa] := 0
			a840Lock(nLin,.F.)

			FaMoedas()
			RefData(4,cNumFatAut)
			nValRec:= 0
			lRet := .F.
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณO titulo que teve seu ajuste de saldo por dif. de cambio nao pode ser baixado emณ
			//ณdata anterior ao ajuste, porque senao o ajuste feito seria sobre o saldo errado ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If cPaisLoc $ "ARG|COS"
				SE1->(MsGoto(aLinSE1[nLin][Len(aLinSE1[nLin])-1]))
				If SE1->E1_DTDIFCA>= dDataBase
					Help('',1,'BXDIFCAMB')
					lRet := .F. 
				Endif	
			Endif
		Endif
	EndIF
	If lRet .And. !a840Lock(nLin,.T.)
		lRet := .F. 
	Endif

	If lRet .And. !lRotAuto
		//Bloqueia o painel para exibir a tela de pagamentos
		oPanel[nPanel]:lReadOnly:= .T.
		oPanBut:lReadOnly:=.T.
	EndIf

	If lRet 
		nValOrig	:= aLinSE1[nLin][nPosValor]
		nTotAbat	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataRef)
		nParciais:= aLinSE1[nLin][nPosValor]-SE1->E1_SALDO

		If cPaisLoc == "COS" .And. SE1->E1_VALOR == SE1->E1_SALDO
			aConcepto := fa840Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_VALOR})
			nRetCfg := 0
			aEval(aConcepto,{|x| nRetCfg += x[5] }) 
		EndIf

		nDescont:= aLinSE1[nLin][nPosDesc]
		nJuros	:= aLinSE1[nLin][nPosJuros]
		nMulta	:= aLinSE1[nLin][nPosMulta]
		nValEstr:= 0
		dnCorrec	:= 0
		nSaldo	:= SE1->E1_SALDO-nTotAbat-nDescont+nMulta+nJuros-nRetCfg
		nValRec	:= aLinSE1[nLin][nPosBx] + nMulta - nDescont + nJuros
		nMotBx  := AScan(aMotBx,{|x| Substr(x,1,3)==aLinSE1[nLin][nPosMotBx]})
		cMotBx  := aDescMotBx[iif(nMotBx>0,nMotBx,1)]
		If !lRotAuto
			oMotBx:Refresh()
		EndIF

		If Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1
			cM:="1"
		Else
			cM:=Alltrim(Str(SE1->E1_MOEDA))
		Endif
		cMoedOri:=SuperGetMv("MV_MOEDA" + cM)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPonto de entrada antes da montagem da tela de baixas,    ณ
		//ณpermite que o analista configue os valores para baixa.	ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ExistBlock("FA087ValBX")   
			aValores[1] := nDescont  
			aValores[2] := nJuros
			aValores[3] := nMulta
			aValores[4] := nValEstr
			aValores[5] := nCorrec
			aValores[6] := nSaldo
			aValores[7] := nValRec                      
			aValores[8] := Val(cM)
			aValores:=	ExecBlock("FA087ValBX",.F.,.F.,aValores)
			nDescont:=	aValores[1]
			nJuros	:=	aValores[2]
			nMulta	:=	aValores[3]
			nValEstr:=	aValores[4]
			nCorrec	:=	aValores[5]
			nSaldo	:=	aValores[6]-nTotAbat-nRetCfg
			nValRec	:=	aValores[7]
		Endif
		
		If cPaisLoc == "ARG" .And. nQtMoedas <> 0 .And. Len(aLinBaixa) == 0
			aLinBaixa	:=Array(nQtMoedas)
		EndIf
	
		nI:=1
		For nI := 1 To nQtMoedas
			aLinBaixa[nI]:={SuperGetMV("MV_MOEDA"+Alltrim(Str(nI))),aLinSE1[nLin][anPosMoed[nI]]}
		Next nI

		//Caso a nValRec esteja zerada ou o valor do campo nBaixar (adicionado atraves da array aCposExtra depois do MontaGrid[2]) estiver zerado
		If nValRec == 0 .OR. aLinSE1[nLin][nPosBx] == 0
			nValRec := nSaldo +nRetCfg
			aLinBaixa[Val(cM)][2]:=nSaldo +nRetCfg
		Endif
	EndIF

	If lRet .And. !lRotAuto 
		oLBBaixa:SetArray(aLinBaixa)
		oLBBaixa:bLine	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
		Transform(aLinBaixa[oLBBaixa:nAT][2],PesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
		oLBBaixa:Refresh()
	EndIf

	If lRet
		cPictTit:=PesqPict("SE1","E1_VALOR",TamSX3("E1_VALOR")[1],aLinSE1[nLin][nPosMoed])

		If !lRotAuto
			oDescont:Picture:=cPictTit
			oMulta:Picture:=cPictTit
			oJuros:Picture:=cPictTit
			oValRec:Picture:=cPictTit
			oValOrig:Picture:=cPictTit
			oSaldo:Picture:=cPictTit
			If oRetCfg != Nil	//protecao para nao ocorrer errorlog em localizacoes diferentes de COS.
				oRetCfg:Picture:=cPictTit
			EndIf

			oParciais:Picture:=cPictTit

			oDescont:Refresh()
			oMulta:Refresh()
			oJuros:Refresh()
			oValRec:Refresh()
			oValOrig:Refresh()
			oSaldo:Refresh()
			oMoedOri:Refresh()
			If oRetCfg != Nil
				oRetCfg:Refresh()
			EndIf
			oParciais:Refresh()

			If lAltTitulo
				oPPagto:Show() 
				oLbBaixa:SetFocus()
			Else
				Fa840BaixaOK(cNumFatAut)
			Endif
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAPagtoAtuบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FAPagtoAtu()

	nSaldo	:= SE1->E1_SALDO-nTotAbat-nDescont+nMulta+nJuros-nRetCfg
	AEval(aLinBaixa,{|x,y| If(y==SE1->E1_MOEDA,x[2]:=nSaldo+nRetCfg,x[2]:=0)})

	oLBBaixa:bLine	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
	Transform(aLinBaixa[oLBBaixa:nAT][2],PesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
	oLBBaixa:Refresh()

	oDescont:Refresh()
	oMulta:Refresh()
	oJuros:Refresh()
	oSaldo:Refresh()

	nValRec:=Round(nSaldo+nRetCfg,MsDecimais(SE1->E1_MOEDA))
	oValRec:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDCLBMoed  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DCLBMoed(cNumFatAut)
	
	Local nPosCpo
	Local nPosCpo1
	Local lRet:=.T.                   
	
	DEFAULT cNumFatAut := ""
	
	If oLBMoed:nAT > 1
		nPosCpo:=Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(oLBMoed:nAT)))
		nPosCpo1:=Ascan(aCposSE1,"E1_MOEDA")
		AEval(aLinSE1,{|x| If(x[1]==1 .And. (x[nPosCpo1]==oLBMoed:nAT .Or. x[nPosCpo]>0),lRet:=.F.,) })
		If !lRet
			Alert(STR0063) // "Esta tasa no puede cambiarse pues se efectuaron bajas utilizando esta moneda."
		Else
			lEditCell(@aLinMoed,oLBMoed,PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oLBMoed:nAT)),9),2)
		Endif
	Endif
	oLBMoed:SetFocus()
	FAMoedas()
	RefData(4,cNumFatAut)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDCLBBaixa บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DCLBBaixa()
	
	Local nValSDesc,nDescFin
	Local nX:=1
	Local lAdiant:= .F. 
	Local bValid

	bValid := {|| a840VerPE(oLBBaixa:nAt,&(ReadVar()) ) }

	If !lAdiant
		lEditCell(@aLinBaixa,oLBBaixa,PesqPict("SE1","E1_VALOR",TamSx3("E1_VALOR")[1],oLBBaixa:nAt),2,,,bValid)
	EndIf
	nValRec:=0
	nMoedTit:=Iif(Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1,1,SE1->E1_MOEDA)
	For nX:=1 to nQtMoedas
		If aLinMoed[nMoedTit][2]>0 .And. aLinMoed[nX][2]>0
			nValRec += aLinBaixa[nX][2]*(aLinMoed[nX][2]/aLinMoed[nMoedTit][2])
		Endif
	Next nX
	nValOri:=nValRec //Round(nValRec,MsDecimais(nMoedTit))
	oDescont:Refresh()
	oMulta:Refresh()
	oJuros:Refresh()
	oSaldo:Refresh()
	oValRec:Refresh()
	If SuperGetMV("MV_DESCFIN",,"I")=="P"   //verifica se o desconto financeiro pode ser parcial "P" ou integral "I"
		nDescFin:=FaDescFin("SE1",dDataRef,SE1->E1_SALDO,SE1->E1_MOEDA)
		If nDescFin<>0 
			nValSDesc:=nValRec / ((100-SE1->E1_DESCFIN)/100)
			nDescFin:=nDescFin * (nValSDesc/SE1->E1_SALDO)
			nDescont:=nDescFin
			oDescont:Refresh()
		Endif
	Endif

	oLBBaixa:SetFocus()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFa840BaixaOKบAutor  ณMicrosiga           บ Data ณ  03/23/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840BaixaOK(cNumFatAut,nItem)

	Local nX:=0
	Local nPosTpSE1	:=	0                  
	Local lTemReceb := .F.        
	Local nI := 0    
	Local lRet := .T.           
	Local nValorBx   := 0
	Local nValImpRet := 0
	Local nY := 0

	Default cNumFatAut	:= ""
	Default nItem		:= 0 

	If !lRotAuto
		F840MotBx()
		cMotBxSE1:=Substr(aMotBx[oMotBx:nAt],01,03)
	Endif
	If cPaisLoc == "ARG" .And. nQtMoedas <> 0 .And. Len(aLinBaixa) == 0 
		aLinBaixa	:=Array(nQtMoedas)

		nY:=1
		For nY := 1 To nQtMoedas
			aLinBaixa[nY]:={SuperGetMV("MV_MOEDA"+Alltrim(Str(nY))),aLinSE1[If(lRotAuto,nItem,oLBSE1:nAt)][anPosMoed[nY]]}
			aLinBaixa[nY][2] := aTaxa[nY]
		Next nY
	EndIf

	nI:=0
	for nI:=1 to nQtMoedas
		&("nPosBx" + Alltrim(Str(nI))) := Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
	Next nI
	nPosBx :=	Ascan(aCposSE1,"nBaixar")
	nPosTpSE1:=(AScan(aCposSE1,"E1_TIPO"))
	nX:=1

	//Verifica se tem recebimentos no Panel 1
	//Caso nao tenha, avisa ao usuario para selecionar primeiro as NCCs e RAs, pois eh possivel compensar 
	//os titulos a receber com as RAs de mesmo valor sem a necessidade do recebimento de cheque, dinheiro etc.
	For nX := 1 to Len(aCols)
		If !aCols[nX][Len(aCols[nX])] 		
			lTemReceb  := .T.        
			Exit      
		EndIf
	Next nX
	
	If IIf(cPaisLoc == "ARG", nPanel < 2 .Or. nPanel > 3, .T.)
		For nX:=1 To nQtMoedas
			If !(aLinSE1[If(lRotAuto,nItem,oLBSE1:nAt)][nPosTpSE1]$(MVRECANT+"/"+MV_CRNEG) .Or. cMotBxSE1=="DAC") .And. ;
				Round(aLinBaixa[nX][2],MsDecimais(nX)) > Round(aLinBaixa[nX][2],MsDecimais(nX)) + (Round(aLinMoed[nX][4],MsDecimais(nX)))
				If lTemReceb
					If lRotAuto
						cTxtRotAuto += STR0050 + aLinMoed[nX][1] + STR0051 + CRLF + CRLF // "Saldo en "
					Else
						Alert(STR0050 + aLinMoed[nX][1] + STR0051) //"Saldo em "###" insuficiente para efetuar a baixa. "
					Endif
				Else
					//"Saldo em "###" insuficiente para efetuar a baixa. "		
					//"Como nao foram digitados recebimentos na tela inicial, selecione primeiro os documentos de credito do cliente(NCCs, RAs, etc.)"
					If lRotAuto 
						cTxtRotAuto += STR0050 + aLinMoed[nX][1] + STR0051 + CRLF + CRLF // "Saldo en "
					Else 
						Alert(STR0050 + aLinMoed[nX][1] + STR0051) //"Saldo em "###" insuficiente para efetuar a baixa. "
					Endif
				EndIf   
				Return .F.
			Endif
			If aLinBaixa[nX][2]>0 .And. aTaxa[nX]<=0
				If lRotAuto
					cTxtRotAuto += STR0052 + CRLF + CRLF  //"Informe todas as taxas das moedas que serใo utilizadas nas Baixas." 
				Else
					Alert(STR0052) //"Informe todas as taxas das moedas que serใo utilizadas nas Baixas."
				Endif
				Return .F.
			Endif
		Next nX
	EndIf

	nMoedTit:=Iif(Empty(SE1->E1_MOEDA) .or. SE1->E1_MOEDA <= 1,1,SE1->E1_MOEDA)
	nDec:= SuperGetMV("MV_CENT" + Iif(nMoedTit==1,"", Alltrim(Str(nMoedTit)) ) )
	If Round(nValRec,nDec)>Round(nSaldo+nRetCfg,nDec)
		If lRotAuto
			cTxtRotAut += STR0053 + CRLF + CRLF
		Else
			Alert(STR0053) //"Valor Recebido nใo pode ser maior que o saldo a receber."
		Endif
		Return .F.
	Endif
	If nValRec == 0 .And. Ascan(aLinSE1, {|x| x[1] == 1 }) <> 0
		If lRotAuto 
			cTxtRotAut += STR0054 + CRLF + CRLF //"Valor Recebido deve ser maior que zero."
		Else
			Alert(STR0054) //"Valor Recebido deve ser maior que zero."
		Endif
		Return .F.
	Endif


	If ExistBlock("F087ABXOK")
		lRet:= ExecBlock("F087ABXOK",.F.,.F.)
	EndIf
	If lRet  .And. !IsInCallStack("MSAGUARDE")
		nX:=1
		For nX:=1 To nQtMoedas
			nBx:=&("nPosBx" + Alltrim(Str(nX)))
			If lRotAuto
				aLinSE1[nItem][nBx]	:= aLinBaixa[nX][2]
			Else
				aLinSE1[oLBSE1:nAt][nBx] := aLinBaixa[nX][2]
			Endif
		Next nX

		If !lRotAuto	
			nValorBx := nValRec-nMulta+nDescont-nJuros

			aLinSE1[oLBSE1:nAt][nPosDesc]	:= nDescont
			aLinSE1[oLBSE1:nAt][nPosJuros]	:= nJuros
			aLinSE1[oLBSE1:nAt][nPosMulta]	:= nMulta
			aLinSE1[oLBSE1:nAt][nPosBx]	:=  nValorBx //nValRec-nMulta+nDescont-nJuros
			aLinSE1[oLBSE1:nAt][nPosMotBx]	:= cMotBxSE1 
			if nPosImpRet > 0
				aLinSE1[oLBSE1:nAt][nPosImpRet]	:= nRetCfg
			endif
			If cPaisLoc == "ARG" .And. (nPercGer > 0 .Or. nDescGer <> 0 )
				AEval(aLinSE1,{|x| x[nPosDesc] := 0})
			EndIf
		Endif
		If nValRec > 0
			If lRotAuto
				aLinSE1[nItem,1] := 1
			Else
				aLinSE1[oLBSE1:nAt,1] := 1
			Endif
		Endif
	EndIf
	If !lRotAuto
		oLBSE1:Refresh()
		RefData(4,cNumFatAut)
		oPanBut:lReadOnly		:=.F.
		oPanel[nPanel]:lReadOnly	:=.F.
		FaMoedas()
		oPPagto:Hide()
		oGetSel:oBrowse:SetFocus()
	Endif
lBax 		:= .T.
nValRec2	:=	nValRec
nSaldo2	:=	nSaldo
nAtoLBSE1	:= oLBSE1:nAt
aLinBaixa2 := aClone(aLinBaixa)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFA840UnlockบAutor  ณMicrosiga           บ Data ณ  03/23/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840Unlock()
	AEval(aRLocks,{|x,y| SE1->(MsRUnlock(x))})
	aRLocks:={}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFA840AtuCliบAutor  ณMicrosiga           บ Data ณ  03/23/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840AtuCli(cNumFatAut,lIncAdt)
	
	DEFAULT cNumFatAut := ""
	lLinArr 	:= .F.
	cNome		:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
	cCGC		:= SA1->A1_CGC
	cTel		:= SA1->A1_TEL
	cContato	:= SA1->A1_CONTATO
	cCliori	:= cCliente
	cLojOri	:= cLoja
	RefData(2,cNumFatAut,lIncAdt)
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa840SalvarบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa840Salvar(lTela,lGerNCC,cNumFatAut,lIncAdt,aRecAdt)

	Local cKeyImp		:= ""
	Local nTx
	Local nX			:= 1
	Local nY			:= 1
	Local nI			:= 1
	Local aCposHead	:= {}
	Local nTot 		:= 0
	Local nPosDados 	:= 0
	Local aSerRec		:= {}
	Local cRecAnt   	:= cRecibo
	Local lOk       	:= .T.     
	Local lExiste   	:= .F.
	Local nValMoed		:= 1
	Local nVlrTit		:= 0
	Local nPosTP		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TIPO"})
	Local nPosTpDoc	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TIPODOC"})
	Local nPosPrefixo	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_PREFIXO"})
	Local nPosNumero	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_NUMERO"})
	Local nPosParcela	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_PARCELA"})
	Local nPosTransit	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TRANSIT"})
	Local nPosVal		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_VALOR"}) 
	Local nPosBco		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_BANCO"}) 
	Local nPosDtVcto	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_DTVCTO"})
	Local nPosMun 	 := 0
	Local nPosEst    := 0
	Local nPosCodFis := 0
	Local nPosRetGan := 0
	Local nPosRetSUS := 0
	Local nPosBaseR  := 0
	Local nPosAliqR  := 0
	Local nPosValR   := 0
	Local nPosValBx	:= AScan(aCposSE1,"nBaixar")
	Local nPosDesc		:= AScan(aCposSE1,"nDescSE1")
	Local nPosMoed		:= AScan(aCposSE1,"E1_MOEDA")
	Local nPosNatur   := AScan(aCposSE1,"E1_NATUREZ")
	Local nDesc		:= 0
	Local nDescRat		:= 0
	Local nDias, dBase,aFeriados
	Local nDescoSlv	:= 0
	Local nMultaSlv	:= 0
	Local nJurosSlv	:= 0
	Local nVlLiqSlv	:= 0
	Local nValMinRa 	:= SuperGetMv("MV_VLMINRA",,0)  // valor minimo para geracao do titulo de credito
	Local lExterno 	:= .F.  
	Local lRatImp		:= GetMv("MV_RATIMP",.F.,"0")=="0" 
	Local cSerieC 		:= GETNEWPAR("MV_SERPERC","") 
	Local nBaseRec		:= 0 
	Local nBaseITF 	:= 0 
	Local nBaseTIT 	:= 0 
	Local aCert 		:= {}
	Local aNumCert  	:= {}
	Local aConcepto 	:= {}
	Local nTotReceb 	:= 0
	Local nCount 		:= 0
	Local lSelectSE1	:= .F.
	Local nTotBx		:= 0
	Local nTotRec		:= 0
	Local nPosTpSEL	:= 0
	Local nPosValSEL	:= 0
	Local nPosMoedSEL	:= 0
	Local aRecs		:= {}      
	Local nTotRat		:= 0    
	Local nDifDesc		:= 0    
	Local nPosUlt		:= 0
	Local lGerouPGR	:= .F.
	Local aRecibPGR	:=	{}
	Local lRet := .T.           
	Local lNumDoc  := .F.     
	Local lBanM:= .F.

	//Usado devido adaptacoes para documentos em transito
	Local lNoDocTran	:= .T.
	Local lExecSEF		:= .T. 
	Local nPosTrans	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_TRANSIT"})

	Local aAreaAux		:= {}
	Local cChaveAux	:= ""
	Local nVrRetCfg	:= 0

	Local cFilFRF		:= xFilial("FRF")
	Local cSeqFRF		:= ""
	Local lSELDicTrs	:= ""
	Local nPosBcoChq	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_BCOCHQ"})
	Local nPosAgeChq	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_AGECHQ"})
	Local nPosCtaChq	:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_CTACHQ"})
	Local nPosImpRet  := AScan(aCposSE1,"nImpRetSE1")
	Local nTotImpRet  := 0
	Local nColig		:= GetNewPar("MV_RMCOLIG",0)
	Local lMsgUnica	:= IsIntegTop()
	Local cIDProc		:= ""		/* codigo do processo referente ao recibo */
	Local nPosEmiss		:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_EMISSAO"})
	Local nPosSIRES		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_SIRESEG"})  
	Local nPosCERT		:= AScan(aHeader,{|x|Alltrim(x[2])=="EL_SIRECER"})
	Local lRecibo			:= .T.
	Local lUsoSerie      := SuperGetMv('MV_SERREC',,.F.)
	Local aSF2area	:=""
	Local cSF2aux	:=""
	Local aAux935   :={}
	Local nMvPO935	:= GETNEWPAR("MV_POSON", 0)
	Local nVLMOED1:= 0
	Local lRaGR:=.F.
	Local nPosPref  := Ascan( aCposSE1, "E1_PREFIXO")
	Local nPosNum   := Ascan( aCposSE1, "E1_NUM")
	Local nPosParc  := Ascan( aCposSE1, "E1_PARCELA")
	Local nPosTipo  := Ascan( aCposSE1, "E1_TIPO")   
	Local lLocAgr 	:=  cPaisLoc == "ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0 .AND. SEL->(ColumnPos("EL_TIPAGR")) >0.AND.  SF2->(ColumnPos("F2_CANJE"))>0
	Local aAreaAt:= GetArea()
	Local nPos935	:= 0
	Local cIdMetric := ""
	Local cSubRutina := ""
	DbSelectArea("SEL")

	nTotalBx	:= IIf( Type("nTotalBx")=="U",0,nTotalBx)  // Valor total dos titulos selecionados para baixa

	Private aDiario	:=	{}
	Private aRecnoITF	:= {}
	Private aRatAFT 	:={}
	Private aDatBnDif := {}
	DEFAULT lGerNCC	:= .F.
	DEFAULT lTela 		:=	.T.
	DEFAULT cNumFatAut:= ""
	DEFAULT lIncAdt	:= .F.   //Angola
	DEFAULT aRecAdt	:= {}
	
	If nPanel != nLastPan
		If Fa840TudoOk(cNumFatAut,lIncAdt)
			nPanel +=1
			ShowPanel(nPanel, @oPanel,cNumFatAut,lIncAdt) 
		EndIf
		lRet := .F.
	EndIf
	Iif(cPaisLoc == "ARG", lRatImp := .F., "") //Forza a no realizar prorrateo

	If  cPaisLoc == "ARG"
		If SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
			nPosMun		:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_RET_MUN"})
		EndIf 
		nPosEst		:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_EST"})
		nPosCodFis	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_CFO"})
		nPosRetGan	:= AScan(aHeader,{|x|Alltrim(x[2]) == "A2_AGREGAN"})
		nPosRetSUS	:= AScan(aHeader,{|x|Alltrim(x[2]) == "A2_CONCSUS"})
		nPosBaseR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_VALBASE"})
		nPosAliqR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_ALIQ"})
		nPosValR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_VALOR"})
	EndIf

	If lRet .And. nPanel == nLastPan
		lTela := .F.

		nPosTpSEL	:= ASCAN(aCposSEL,"EL_TIPODOC")
		nPosValSEL	:= ASCAN(aCposSEL,"EL_VALOR")
		nPosMoedSEL	:= ASCAN(aCposSEL,"EL_MOEDA")

		aLinReceb	:= {}

		aRecs := ACLONE(aCols)
		ASORT(aRecs,,,{|x,y| x[nPosTpSEL] < y[nPosTpSEL]})
		cTipo := Nil
		nX := 1
		For nX := 1 To Len(aRecs)
			If (cTipo != aRecs[nX][nPosTpSEL]) .And. !aRecs[nX][Len(aRecs[nX])]
				AAdd(aLinReceb,{aRecs[nX][nPosTpSEL],0})
				cTipo := aRecs[nX][nPosTpSEL]
			Endif
			If (aRecs[nX][nPosValSEL] != Nil) .And. !aRecs[nX][Len(aRecs[nX])]
				nM := IIf(Empty(aRecs[nX][nPosMoedSEL]) .Or. Val(aRecs[nX][nPosMoedSEL]) <= 1, 1, Val(aRecs[nX][nPosMoedSEL]))
				aLinReceb[Len(aLinReceb)][2] += aRecs[nX][nPosValSEL] * (aTaxa[nM]/iIF(!lRotAuto,(aTaxa[oCBMOed:nAt]),1))
			Endif
		Next nX

		AEVAL(aLinBx,	{|x| nTotBx +=x[2]	})
		AEVAL(aLinReceb,{|x| nTotRec += x[2]})

		nTotal:= Round(nTotRec - IIf(!lRotAuto,nTotBx,nTotSE1), IIf(!lRotAuto,MsDecimais(oCBMOed:nAt),1))
	EndIf

	If lRet 
		///////////////////////////////////
		// Inicializa integra็ใo com PCO //
		///////////////////////////////////
		PcoIniLan("000361")

		AAdd(aCposHead,{"EL_FILIAL",xFilial("SEL")})
		AAdd(aCposHead,{"EL_SERIE",cSerie})
		AAdd(aCposHead,{"EL_RECIBO",cRecibo})
		AAdd(aCposHead,{"EL_DTDIGIT",dDataBase})
		AAdd(aCposHead,{"EL_CANCEL",.F.})
		AAdd(aCposHead,{"EL_CLIENTE",cCliente})
		AAdd(aCposHead,{"EL_LOJA",cLoja})
		AAdd(aCposHead,{"EL_COBRAD",cCobrador})
		AAdd(aCposHead,{"EL_RECPROV",cRecProv})
		AAdd(aCposHead,{"EL_CLIORIG",cCliOri})
		AAdd(aCposHead,{"EL_LOJORIG",cLojOri})

		If !(Fa840TudoOk(cNumFatAut,lIncAdt))
			Return .F.
		Endif

		If lTela
			Refdata(nPanel,cNumFatAut,lIncAdt)
		Endif

	EndIf

	//Verificar abatimentos atrav้s das Reten็๕es e validar totais
	If lRet .And. cPaisLoc $ "EQU|VEN" 
		nTotal    := 0             
		nTotReceb := 0
		//Verificar a existencia registros de SE1 selecionados para a Baixa.
		For nX := 1 To Len(aLinSE1)
			If aLinSE1[nX,1] == 1
				lSelectSE1 := .T.
			EndIf
		Next nX
		If !lSelectSE1                             
			//###"Seleccione por lo menos una factura a cancelar en la tercera pantalla."###"Aten็ใo"
			If !lRotAuto
				MsgAlert(STR0168,STR0149)// "Seleccione al menos un tํtulo de la tercera pantalla." #  "Atenci๓n"
			Else
				cTxtRotAut += STR0168 + " "+ " " + STR0149  +" "+ CRLF // "Seleccione al menos un tํtulo de la tercera pantalla."
			EndIf
			lRet := .F.
		EndIf	
		If lRet .And. Len(aLinSE1) > 0  
			For nCount := 1 To Len(aLinSE1)
				nTotal += aLinSE1[nCount][8]
			Next nCount
		EndIf		
		If lRet 	
			For nCount := 1 To Len(aLinReceb)
				nTotReceb += aLinReceb[nCount][2]
			Next nCount   
			If nTotReceb > nTotal
				lGerNCC:=MsgYesNo(STR0055+ cDocCred +	STR0056,STR0048) //  "El valor por bajar es menor que el valor cobrado. ฟConfirma generaci๓n de " # "/s de saldo pendiente ? " #"Saldo" 
			EndIf
		EndIf
	ElseIf lRet  
		If lIncAdt .and. (nTotal > 0 .and.( nTotal >= nValMinRa))
			lGerNCC:= .T.
		ElseIf !lGerNCC .And. (nTotal > 0 .and.( nTotal >= nValMinRa .or. nTotalBx == 0 ))
			lGerNCC:=MsgYesNo(STR0055+ cDocCred +	STR0056,STR0048)//  "El valor por bajar es menor que el valor cobrado.  ฟConfirma generaci๓n de " # "/s de saldo pendiente ? " #"Saldo" 
			If !lGerNCC
				lRet :=  .F.
			EndIf    
		EndIf
	Endif        

	If lRet .and. len(aLinReceb)==0 .and. Len(aLinBX)==0
		MsgAlert(STR0260,STR0149)// "Seleccione al menos un tํtulo de la tercera pantalla." #  "Atenci๓n"
		lRet :=  .F.
	EndIf
	

	If lRet .And. lRotAuto .And. nTotal == 0
		lGerNCC := .F.
	Endif

	If lRet .And. nDescGer >0
		nDesc:=nDescGer*nMoedDesc
		nDescRat:=0
		// Totaliza valor das baixas em moeda 1
		anTotBx:=SomaTitBaixa()
		AEval(anTotBx,{|x,y| nTot += x*aTaxa[y]})
		// Faz rateio do desconto geral, por item.
		If cPaisLoc == "BRA"
			AEval(aLinSE1,{|x| nDescRat:= iif (x[1]==1 .And. !(x[nPosTp]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx]=="DAC"),((x[nPosValBx]/(nTot/aTaxa[x[nPosMoed]]))*(nDescGer*(aTaxa[nMoedDesc]/aTaxa[x[nPosMoed]]))),0),x[nPosDesc]+=nDescRat,nDesc -= nDescRat*(aTaxa[x[nPosMoed]]/aTaxa[nMoedDesc])})
		Else                          
			// Tratamento para quando existir rateio e ao calcular o rateio do ultimo titulo o valor rateado nใo seja o valor total do
			// desconto informado, neste caso serแ ajustado o valor restante no ultimo titulo.
			For nX:=1 to Len(aLinSE1)     
				If aLinSE1[nX][1] == 1 // Se estiver marcado
					nDescRat:= Round(aLinSe1[nX][nPosValBx]/(nTot/aTaxa[aLinSe1[nX][nPosMoed]]) * (nDescGer*(aTaxa[nMoedDesc]/aTaxa[aLinSe1[nX][nPosMoed]])),MsDecimais(1))	
					nTotRat += nDescRat
					aLinSe1[nX][nPosDesc] += nDescRat
					nPosUlt:=nX
				EndIf
			Next nX
			If nDescGer > nTotRat
				nDifDesc := (nDescGer - nTotRat)
				aLinSe1[nPosUlt][nPosDesc] += nDifDesc
			EndIF
		EndIf
	Endif

	If lRet .And. nPercGer >0
		nDescRat:=0
		// Faz rateio do desconto por item.
		If cPaisLoc<> "ARG"
				AEval(aLinSE1,{|x| nDescRat:= iif (x[1]==1 .And. !(x[nPosTp]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx]=="DAC"),(nPercGer*x[nPosValBx]*0.01),0),x[nPosDesc]+=nDescRat})
		Else
		   For nX:=1 to Len(aLinSE1)     
				If aLinSE1[nX][1] == 1 // Se estiver marcado
					nDescRat:= (nPercGer*aLinSe1[nX][nPosValBx] *0.01)	
					nTotRat += nDescRat
					aLinSe1[nX][nPosDesc] += nDescRat
					nPosUlt:=nX
				EndIf
			Next nX
		EndIf
	Endif

	If lRet
		// verifica se o numero do recibo ja foi utilizado (e nao eh pre-recibo) antes do inicio da transacao de gravacao
		lExiste := IIf(SEL->( dbSeek(xFilial("SEL")+cSerie+cRecibo) ) .or. !MayIUseCode( "SEL"+xFilial("SEL")+cSerie+cRecibo ),.T.,.F.)

		If lExiste 

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe utiliza controle de numeracao sem SERIE, estou utilizando        ณ
			//ณos semaforos, portanto nao posso simplesmente pegar o proximo numeroณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !SuperGetMv('MV_SERREC')
				Help(" ",1,"EXISTNUM")
				lRet := .F.
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe utiliza controle de numeracao COM SERIE, NAO estou utilizando os ณ
				//ณsemaforos, e sim o SX5, portanto posso pegar o proximo numero disp. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Else
				aSerRec := Fa840Ser(cSerie,cRecibo)
				If Len(aSerRec) > 0
					cSerie  :=aSerRec[1]
					cRecibo :=aSerRec[2]
				Else
					lRet:= .F.
				EndIf

				While  SEL->( dbSeek(xFilial("SEL")+cSerie+cRecibo) )  .Or. !MayIUseCode( "SEL"+xFilial("SEL")+cSerie+cRecibo )
					cRecibo := StrZero(Val(cRecibo)+1,TamSx3("EL_RECIBO")[1])
				EndDo

				If cRecAnt  <> cRecibo
					lOk:= MsgYesNo(OemToAnsi(STR0117) + cRecAnt +OemToAnsi(STR0118) + cRecibo) // "El documento no.: "" existe, confirma cambio de numeracion para: "
				EndIf

				If !lOK
					lRet := .F.
				EndIf
			Endif
		Endif
	EndIF

	If lRet .And. UsaSeqCor() 
		If !CTBvldDiario(cDiario,dDataBase) 
			lRet := .F.
		Endif
	Endif

	If lRet
		lRet := .F.
		Begin Transaction

			DbSelectArea("SE1")
			SE1->(DbSetOrder(1)) //EL_FILIAL+EL_PREFIXO+EL_NUMERO

			//ANGOLA - Inclusao de Adiantamento nao tem tela de titulos a baixar
			//Logo aLinSE1 nao vai existir para a soma de valores a baixar
			aLinSE1 := If(Type("aLinSE1") != "A",{},aLinSE1)
			aSort(aLinSE1,,,{|x,y| x[1]>y[1]})
			DbSelectArea("SEL")
			SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
			SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))  // Posiciona SA1

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTratamento para preencher o campo Numero (EL_NUMERO) para recibos do tipo Pagar้ (EL_TIPODOC) ณ
			//ณObs: Caso o campo esteja vazio o Pagar้ estแ sendo gerado para o cliente.                     ณ
			//ณ		Caso esteja preenchido o cliente esta pagando com Pagar้ de terceiros.                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nX:=1 to Len(aCols)
				If AllTrim(aCols[nX][nPosTpDoc]) == "DC" .And. Empty(aCols[nX][nPosNumero])

					aCols[nX][nPosNumero] := GetSXENum("SEL","EL_NUMERO")
					ConfirmSX8()

					Aadd(aRecibPGR,{aCols[nX][nPosTpDoc]								,;	//EL_TIPODOC
					aCols[nX][nPosPrefixo]								,;	//EL_PREFIXO
					aCols[nX][nPosNumero]								,;	//EL_NUMERO
					aCols[nX][nPosDtVcto]								,;	//EL_DTVCTO
					TRANSFORM(aCols[nX][nPosVal],"@R 999,999,999.99"),;	//EL_VALOR
					aCols[nX][nPosMoedSEL]})									//EL_MOEDA

					lGerouPGR := .T.

				EndIf
			Next nX

			cIDProc := GetSx8Num('FKA','FKA_IDPROC')

			//Guarda Encabezado de Recibo
	For nX:=1 to Len(aCols)												//E1_FILIAL+					E1_PREFIXO				+E1_NUM+E1_PARCELA		+E1_TIPO

		If	SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo+aCols[nX][nPosTpDoc]+aCols[nX][nPosPrefixo]+;
				aCols[nX][nPosNumero]+aCols[nX][nPosParcela]))
					If aCols[nX][Len(aCols[nX])]
						Loop
					Else
						RecLock("SEL",.F.)
							nI:=1
							AEval(aCposHead,{|x,y| If(FieldPos(x[1])>0,FieldPut(FieldPos(ALLTRIM(x[1])),x[2]),)})
							FaGrv(aCposSEL,aCols[nX])
							If aCols[nX][nPosTpDoc] $ cTiposAdm
								nPosDados := aScan(aDadosAdm,{|x| x[5]==nX})
								SEL->EL_CLIENTE	:= aDadosAdm[nPosDados][01]
								SEL->EL_LOJA 		:= aDadosAdm[nPosDados][02]				
								SEL->EL_TIPODOC 	:= aDadosAdm[nPosDados][04]
							EndIf
							SEL->EL_VLMOED1	:= Round( SEL->EL_VALOR*aTaxa[Val(SEL->EL_MOEDA)], MsDecimais(1) )
							SEL->EL_MOEDA	:= STRZERO(Val(SEL->EL_MOEDA),2)
	
							IF !Empty(cNatureza)
								SEL->EL_NATUREZ	:= cNatureza
							ENDIF	
							If cPaisLoc=="BRA" .And. Alltrim(SEL->EL_TIPODOC) == "CH" 
								SEL->EL_NATUREZ	:= Iif( Empty(SA1->A1_NATUREZ), &(GetMv("MV_1DUPNAT")) , SA1->A1_NATUREZ )
							EndIF	
							F840GrvTx( aTaxa )
						MsUnlock()
					EndIf
				Else
					If aCols[nX][Len(aCols[nX])]
						Loop
					Endif
					RecLock("SEL",.T.)
					nI:=1
					AEval(aCposHead,{|x,y| If(FieldPos(x[1])>0,FieldPut(FieldPos(ALLTRIM(x[1])),x[2]),)})
					FaGrv(aCposSEL,aCols[nX])
					If Fna840LibM()
						cIdMetric   := "financeiro-protheus_tipo-rec-recibo_total"
						cSubRutina  := "fina840-tipo-rec-" + AllTrim(SEL->EL_TIPODOC)
						If isBlind()
							cSubRutina  += "-auto"
						EndIf
						FWCustomMetrics():setSumMetric(cSubRutina, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/,"FINA840")
					EndIf
					If aCols[nX][nPosTpDoc] $ cTiposAdm
						nPosDados := aScan(aDadosAdm,{|x| x[5]== nX})
						SEL->EL_CLIENTE	:= aDadosAdm[nPosDados][01]
						SEL->EL_LOJA	:= aDadosAdm[nPosDados][02]				
						SEL->EL_TIPODOC	:= aDadosAdm[nPosDados][04]
					EndIf
					SEL->EL_VLMOED1	:= Round( SEL->EL_VALOR*aTaxa[Val(SEL->EL_MOEDA)] , MsDecimais(1))
					SEL->EL_RECIBO	:= cRecibo
					SEL->EL_MOEDA	:= STRZERO(Val(SEL->EL_MOEDA),2)
					If cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|TRI|URU|VEN"
						SEL->EL_VERSAO	:= cRevisao
					EndIf

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณDevido adaptacoes para documentos em transito ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If SEL->EL_TRANSIT == "2" 
						SEL->EL_DTENTRA := dDataBase 		
						lNoDocTran := .T.
					Else
						lNoDocTran := .F.
					EndIf			
					/*
					* Verifica se estแ implementado o tratamento de documentos em trโnsito nos recibos de cobran็a
					* Verifica็ใo dos tipos de documentos para cheques
					*/			
					If AllTrim(aCols[nX][nPosTpDoc]) $ MVCHEQUE
						/*
						* Gera็ใo de Hist๓rico de Cheques atrav้s do Recibos de Cobran็a
						*/
						cSeqFRF := GetSx8Num("FRF","FRF_SEQ")

						FRF->(RecLock("FRF",.T.))
						FRF->FRF_FILIAL		:= cFilFRF
						FRF->FRF_BANCO		:= aCols[nX][nPosBcoChq]
						FRF->FRF_AGENCIA	:= aCols[nX][nPosAgeChq]
						FRF->FRF_CONTA		:= aCols[nX][nPosCtaChq]
						FRF->FRF_NUM		:= aCols[nX][nPosNumero]
						FRF->FRF_PREFIX		:= aCols[nX][nPosPrefixo]
						FRF->FRF_CART		:= "R"
						FRF->FRF_DATPAG		:= dDataBase 
						FRF->FRF_CLIENT	:= SEL->EL_CLIENTE
						FRF->FRF_LOJA	:= SEL->EL_LOJA
						FRF->FRF_NUMDOC	:= SEL->EL_RECIBO
						If aCols[nX][nPosTransit]  == "1"				    
							FRF->FRF_MOTIVO		:= "A0"
							FRF->FRF_DESCRI		:= STR0205 //"Entrada de Cheque via Recibo de Cobran็a"
						ElseIf aCols[nX][nPosTransit]  == "2"
							FRF->FRF_MOTIVO		:= "A1"
							FRF->FRF_DESCRI		:= STR0206 //"Entrada de Cheque em Trโnsito via Recibo de Cobran็a"
						EndIf
						FRF->FRF_SEQ		:= cSeqFRF
						FRF->(MsUnLock())

						If  __lSX8
							While ( GetSX8Len() > nSaveSx8 )
								ConfirmSX8()
							End
						Endif
					EndIf

					IF !Empty(cNatureza)
						SEL->EL_NATUREZ  	:= cNatureza
					Endif   
					If cPaisLoc=="BRA" .And. Alltrim(SEL->EL_TIPODOC) == "CH" 
						SEL->EL_NATUREZ:= Iif( Empty(SA1->A1_NATUREZ), &(GetMv("MV_1DUPNAT")) , SA1->A1_NATUREZ )
					EndIF

					If SEL->EL_TIPODOC == "RM" .and. SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0 ;
					.and. cPaisLoc == "ARG" .and. !Empty(cMunp)
						SEL->EL_RET_MUN := cMunp
					Endif 
					F840GrvTx( aTaxa )
					SEL->(MsUnlock())

					If cPaisLoc $ "ARG|COS"

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

						If SEL->EL_TIPODOC == "CH"					//Cheque
							PcoDetLan("000361","01","FINA840")
						ElseIf SEL->EL_TIPODOC $ "RI|RG|RB|RS" 	// Retencion IVA
							PcoDetLan("000361","03","FINA840")
						ElseIf SEL->EL_TIPODOC == "EF"				// En Efectivo
							PcoDetLan("000361","04","FINA840")
						ElseIf SEL->EL_TIPODOC == "TF"				// Deposito
							PcoDetLan("000361","05","FINA840") 
						Endif
					Endif

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Grava็ใo das Reten็๕es de IVA,Rentas ou ISRL - Equador/Venezuela.     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If cPaisLoc $ "EQU|VEN" .And. AllTrim(aCols[nX][nPosTpDoc]) $ "RI|RR"

						If Len(aNumCert) == 0
							aNumCert  := GerNumCert("IVA",.T.)    
						EndIf
						If Len(aNumCert) > 0

							aConcepto := fa840Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,aCols[nX][nPosTpDoc])

							//-- Grava Reten็ใo
							For nCount := 1 To Len(aConcepto)
								RecLock("SFE",.T.)    
								FE_FILIAL   := xFilial("SFE")   
								FE_NROCERT	:= aNumCert[1]
								FE_NUMAUT	:= aNumCert[2]
								FE_EMISSAO  := dDataRef
								FE_CLIENTE  := cCliente
								FE_LOJCLI 	:= cLoja    
								FE_TIPO   	:= Subs(aCols[nX][nPosTpDoc],2,1)
								FE_RECIBO   := cRecibo       
								FE_NFISCAL  := SE1->E1_NUM
								FE_SERIE    := SE1->E1_PREFIXO
								FE_CONCEPT 	:= aConcepto[nCount][1]									
								FE_VALBASE	:= aConcepto[nCount][3]								
								FE_ALIQ		:= aConcepto[nCount][4]								
								FE_VALIMP	:= aConcepto[nCount][5]							
								FE_TES		:= aConcepto[nCount][6]	
								If aCols[nX][nPosVal] <> aConcepto[nCount][5]
									FE_RETENC	:= aConcepto[nCount][5]
								Else
									FE_RETENC	:= aCols[nX][nPosVal]
								EndIf									
								FE_ESPECIE	:= SF2->F2_ESPECIE

								dbSelectArea("SFB") 
								SFB->(DbSetOrder(1))                                
								If SFB->(DbSeek(xFilial("SFB")+AvKey(aConcepto[nCount][2],"FB_CODIGO")))
									FE_CODRET := SFB->FB_CODRET
								EndIf					


								SFE->(MsUnLock())

							Next nCount
							//-- Grava Tํtulo de Abatimento no Contas a Receber.
							If Len(aConcepto) > 0
								cTipoRet := Subs(aCols[nX][nPosTpDoc],2,1)
								fGerAbatCR(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA, "NF ",SE1->E1_CLIENTE, SE1->E1_LOJA, aCols[nX][nPosVal], cTipoRet)
							EndIf	  
						EndIf
					EndIf

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Grava็ใo da tabela de Cheques - Controle de Cheques          .                ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If SEL->EL_TIPODOC == "CH" .and. lNoDocTran   
						Fin840SEF()
					Endif
				EndIf

				If lCarga .And. cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN" .And. ;
				DAP->(Upper(AllTrim(Posicione("DAP",1,xFilial("DAP")+cCarga+cSeqCar+aCols[nX][nPosTpDoc],"DAP_CODGRU")))==Upper(Alltrim(aCols[nX][nPosTpDoc])))
					RecLock("DAP",.F.)
					DAP->DAP_VALPRE:=DAP->DAP_VALPRE+SEL->EL_VALOR
					DAP->DAP_RECIBO:=cRecibo
					MsUnlock()
				EndIf

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGerar registro no SE1 se sao cheques ou pagtos sem movimenta็ใo imediata.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If (aCols[nX][nPosTp] $ cCredMed) .and. lNoDocTran
					Fin840SE1(cCliente,cLoja,aTaxa,"3",cSerie,cRecibo)
				EndIf

				If aCols[nX][nPosTp] $ cCredInm .and. lNoDocTran
					Fa840GSE5(2,"1",cNatureza,,,,,,cIDProc)
					If lFindITF .And. FinProcITF( SE5->(Recno()),1,,,,,cNatureza ) .AND. lRetCkPG(3,,aCols[nX][nPosBco])
						FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,,,cNatureza,@aRecnoITF)
					EndIf				
				EndIf

				If ExistBlock("FA087INC")
					ExecBlock("FA087INC",.F.,.F.)
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCalculo da Comissao do Cobrador caso o mesmo seja informado no Recibo e grava no ณ
				//ณarquivo SEX                                                                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(cCobrador)
					Fa840Com()
				EndIf	
			Next nX
			lRecibo := .T.
			nX:=1

			If !lIncAdt

				SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				aSort(aLinSE1,,,{|x,y| x[1]>y[1]}) // Organiza aLinSE1 para que os marcados venham primeiro.
				lRaGR:=.F.
				
				If lLocAgr 
					If Len(acols) >=1 .and. Empty(ALLTRIM(aCols[1][1]))
						aAreaSE1a:=SE1->(GetArea())
						For nX:=1 to Len(aLinSE1)

								If aLinSE1[nX][1]=1 .And.  Alltrim(aLinSE1[nX][nPosTipo]) =="RA"
									
									SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									
									If SE1->(MsSeek(xFilial("SE1")+ aLinSE1[nX][nPosPref]+aLinSE1[nX][nPosNum]+aLinSE1[nX][nPosParc]+aLinSE1[nX][nPosTipo]))
									  If SE1->E1_TIPOGR=="1"
									  	lRaGR:=.T.
									  	nX:= Len(aLinSE1)
									  EnDif
									EndIf
									
								EndIf
					
						Next	
						SE1->(RestArea(aAreaSE1a))
						
					EndIf
				EndIf
				For nX:=1 to Len(aLinSE1)
					If aLinSE1[nX][1]!=1
						Exit
					Endif

					SE1->(MsGoto(aLinSE1[nX][Len(aLinSE1[nX])-1]))

					nVrRetCfg := 0
					If cPaisLoc == "COS" .And. SE1->E1_SALDO == SE1->E1_VALOR
						aAreaAux := {	SE1->(GetArea()),;
						SFE->(GetArea()),;
						GetArea()         }
						aConcepto := {}
						aConcepto := fa840Concept(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,Nil,{"2|3","2",SE1->E1_NATUREZ,SE1->E1_VALOR})

						//-- Grava Reten็ใo
						For nCount := 1 To Len(aConcepto)
							nVrRetCfg += aConcepto[nCount][5]  
							RecLock("SFE",.T.)    
							FE_FILIAL   := xFilial("SFE")   
							FE_EMISSAO  := dDataRef
							FE_CLIENTE  := SE1->E1_CLIENTE
							FE_LOJCLI 	:= SE1->E1_LOJA   
							FE_TIPO   	:= "R"
							FE_RECIBO   := cRecibo       
							FE_NFISCAL  := SE1->E1_NUM
							FE_SERIE    := SE1->E1_PREFIXO
							FE_PARCELA	:= SE1->E1_PARCELA
							FE_CONCEPT 	:= aConcepto[nCount][1]									
							FE_VALBASE	:= aConcepto[nCount][3]								
							FE_ALIQ		:= aConcepto[nCount][4]								
							FE_VALIMP	:= aConcepto[nCount][5]							
							FE_TES		:= aConcepto[nCount][6]	
							FE_RETENC	:= aConcepto[nCount][5]

							FRM->(DbSetOrder(2)) //-- FRM_FILIAL+FRM_COD+FRM_SEQ+FRM_CARTEI
							If FRM->(MsSeek(xFilial("FRM") + aConcepto[nCount][7] + StrZero(0,Len(FRM_SEQ))))
								SFE->FE_SIGLA    := FRM->FRM_SIGLA
								SFE->FE_TPTIMP   := FRM->FRM_TPABT
								SFE->FE_TPTPAI   := SE1->E1_TIPO
								SFE->(MsUnLock())

								cChaveAux := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
								fGerAbatCR(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE,SE1->E1_LOJA,SFE->FE_VALIMP, "R",FRM->FRM_TPABT)

								//-- Baixa o Tํtulo de Reten็ใo de Impostos
								SE1->(DbSetOrder(1)) //-- E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								If SE1->(MsSeek(xFilial("SE1")+cChaveAux+FRM->FRM_TPABT))
									RecLock("SE1",.F.)
									SE1->E1_SALDO   := 0
									SE1->E1_BAIXA   := dDataBase
									SE1->E1_MOVIMEN := dDataBase
									SE1->(MsUnLock())
								EndIf
							Else
								SFE->(MsUnLock())
							EndIf

							aEval(aAreaAux, {|xArea| RestArea(xArea) })
						Next nCount
					EndIf
					
					If  lLocAgr 
						If  ALLTRIM(SE1->E1_tipo) <> "RA"
							cSF2aux:= fIvaPosdatado(SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_CLIENTE,SE1->E1_LOJA,lRaGR)
						Else
							cSF2aux:="0"
						EndIf
					EndIf
					
					RecLock("SE1",.F.)
					E1_BAIXA 	:=	dDataRef
					E1_MOTIVO	:=aLinSE1[nX][nPosMotBx]
					E1_MOVIMEN	:=dDataRef
					E1_SALDO	:=SE1->E1_SALDO - aLinSE1[nX][nPosValBx] // - nVrRetCfg
					nDescoSlv	:= E1_DESCONT
					nMultaSlv	:= E1_MULTA
					nJurosSlv	:= E1_JUROS
					nVlLiqSlv	:= E1_VALLIQ
					E1_DESCONT	:=aLinSE1[nX][nPosDesc]
					E1_MULTA		:=aLinSE1[nX][nPosMulta]
					E1_JUROS		:=aLinSE1[nX][nPosJuros]
					E1_VALLIQ	:=aLinSE1[nX][nPosValBx]-aLinSE1[nX][nPosDesc]+aLinSE1[nX][nPosJuros]+aLinSE1[nX][nPosMulta]
					E1_SERREC   :=cSerie
					E1_RECIBO	:=cRecibo
					E1_DTACRED	:=dDataRef
					E1_STATUS	:= IF(SE1->E1_SALDO<=0,"B","A")
					//+--------------------------------------------------------------+
					//ฆ Baixar titulos de abatimento se for baixa total              ฆ
					//+--------------------------------------------------------------+
					IF SE1->E1_SALDO > 0 .And. SE1->E1_SALDO == nTotAbat .And. !(SE1->E1_TIPO$ MV_CPNEG)

						E1_SALDO := 0
						E1_STATUS 	:= "B"
						cTitulo  := xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
						aAreaSE1 := GetArea()
						SE1->(DbSetOrder(1))

						If DbSeek(cTitulo )
							While !SE1->(EOF()) .And. xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA==cTitulo
								If SE1->E1_TIPO $ MVABATIM
									RecLock("SE1",.F.)
									Replace E1_SALDO    With 0
									Replace E1_BAIXA    With dDataBase
									Replace E1_MOVIMEN  With dDataBase
									SE1->(MsUnLock())
								EndIf
								dbSkip()
							Enddo
						EndIf
						RestArea(aAreaSE1)
					EndIf
					MsUnlock()		

					If SE1->E1_SALDO==0 .AND. (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
						FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.T.,SE1->E1_ORIGEM,"R")
					Endif

					Fa840GSE5(1,,,,,,,,cIDProc)
					If len(aCols)>0 .And. lLocAgr
						If  nMvPO935== 1 .and. ALLTRIM(SE1->E1_TIPO) <> "RA"
							If (nPos935	:=	Ascan(aAux935,{|x| x[1] == cRecibo .And. x[2] == SE1->E1_CLIENTE .And. x[3] == SE1->E1_LOJA})) > 0 //(nPos	:=	Ascan(aGerar,{|x| x[2]==(TRB)->EL_CLIENTE+(TRB)->EL_LOJA+(TRB)->EL_NUMERO}))==0
								aAdd(aAux935[nPos935][5], {SE1->(Recno()), SE1->E1_PREFIXO, aLinSE1[nX][nPosValBx], SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, "", "", "", "", 0, , .F., .F., .F.})
								aAux935[nPos935][4] += aLinSE1[nX][nPosValBx]
							Else
								aAdd(aAux935,{cRecibo, SE1->E1_CLIENTE, SE1->E1_LOJA, aLinSE1[nX][nPosValBx], {{SE1->(Recno()), SE1->E1_PREFIXO, aLinSE1[nX][nPosValBx], SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, "", "", "", "", 0, , .F. , .F., .F.}}})
							Endif 
						EndIf
					Else
						cSF2aux:=""
					EndIf  
					
					nVLMOED1 := 0
					For nI:=1 To nQtMoedas
						nBx:= Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(nI)))
						nVLMOED1:= nVLMOED1 + Round( aLinSE1[nX][nBx] * aTaxa[nI], MsDecimais(1) )
					Next nI
					If cPaisLoc == "ARG" .And. (nPercGer > 0 .Or. nDescGer <> 0 )
						nVLMOED1:= nVLMOED1 - Round( nDescont, MsDecimais(1) )
					EndIf
					DbSelectArea("SEL")
					RecLock("SEL",.T.)
					EL_FILIAL   := xFilial("SEL") //SE1->E1_FILIAL
					EL_TIPODOC  := "TB"
					EL_PREFIXO  := SE1->E1_PREFIXO
					EL_NUMERO   := SE1->E1_NUM
					EL_PARCELA  := SE1->E1_PARCELA
					EL_TIPO		:= SE1->E1_TIPO
					EL_BCOCHQ 	:= SE1->E1_BCOCHQ
					EL_AGECHQ   := SE1->E1_AGECHQ
					EL_CTACHQ   := SE1->E1_CTACHQ
					EL_EMISSAO  := SE1->E1_EMISSAO
					EL_DTDIGIT  := dDataBase
					EL_DTVCTO   := SE1->E1_VENCREA
					EL_NATUREZ  := SE1->E1_NATUREZ
					EL_MOEDA    := STRZERO(SE1->E1_MOEDA,2)			
					EL_VLMOED1 := Round(nVLMOED1,MsDecimais(1))
					EL_DESCONT  := SE1->E1_DESCONT
					EL_MULTA:= SE1->E1_MULTA
					EL_JUROS:= SE1->E1_JUROS
					EL_VALOR    := SE1->E1_VALLIQ
					EL_CLIENTE 	:= SE1->E1_CLIENTE
					EL_LOJA	 	:= SE1->E1_LOJA
					EL_SERIE    := cSerie
					EL_RECIBO 	:= cRecibo
					EL_VERSAO	:= cRevisao
					EL_COBRAD	:=	cCobrador
					EL_RECPROV	:=	cRecProv
					EL_CLIORIG	:=	cCliOri
					EL_LOJORIG	:=	cLojOri   
					
					If len(aCols)>0 .And. cPaisLoc == "ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0 .AND. SEL->(ColumnPos("EL_TIPAGR")) >0.AND.  SF2->(ColumnPos("F2_CANJE"))>0
						EL_TIPAGR	:=  cSF2aux 
					EndIf
					
					F840GrvTx( aTaxa )
					MsUnlock()		
					
					If cPaisLoc $ "ARG|COS"
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						PcoDetLan("000361","06","FINA840") // Cobran็as diversas - Transferencia Bancaria
					Endif

					SE1->(MsGoto(aLinSE1[nX][Len(aLinSE1[nX])-1]))
					RecLock("SE1",.F.)	
					E1_DESCONT	+= nDescoSlv
					E1_MULTA	+= nMultaSlv
					E1_JUROS	+= nJurosSlv
					E1_VALLIQ	+= nVlLiqSlv
					SE1->(MsUnlock())


					If cPaisloc=="MEX"
						Fa840GrvIVA()
					EndIf	

					If ExistBlock("FA087BAIXA")
						ExecBlock("FA087BAIXA",.F.,.F.)
					Endif

				Next nX
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz as gravacoes dos titulos que tem retencoes no SFE		 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If cPaisLoc $ "ARG" .And. Len(aCols) > 0 .and. lNoDocTran
				DbSelectArea("SFE")  
				nX	:=	0	  	    
				//Rateia os impostos nos titulos informados
				For nI:= 1 to Len(aCols)
					If aCols[nI][nPosTpDoc] $ "RS|RL|RB|RI|RG|RM"
						nX++
						SE1->(DbSetorder(1))
							If aCols[nI][nPosTpDoc] == "RB"
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := aCols[nI][nPosEmiss]
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli       
									If !lRatImp
										FE_EST 		:= aCols[nI][nPosEst]  
										FE_CFO	 	:= aCols[nI][nPosCodFis]
										FE_VALBASE 	:= aCols[nI][nPosBaseR]
										FE_ALIQ		:= aCols[nI][nPosAliqR]
										FE_RETENC 	:= aCols[nI][nPosValR]
									Endif
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNumero] 
									FE_TIPO   	:= "B"
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf
									MsUnlock() 
								EndIf
							ElseIf aCols[nI][nPosTpDoc] == "RM" 
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := aCols[nI][nPosEmiss]
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli       
									If !lRatImp //Prorateo MV_RATIMP
										cMunp 			:= aCols[nI][nPosMun] // aLinRet[nX][nY][2]
										FE_EST			:= aCols[nI][nPosEst]
										FE_RET_MUN		:= aCols[nI][nPosMun]
										FE_CFO			:= aCols[nI][nPosCodFis]
										FE_VALBASE 	:= aCols[nI][nPosBaseR]
										FE_ALIQ		:= aCols[nI][nPosAliqR]   
										FE_RETENC		:= aCols[nI][nPosValR]
									Endif
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNumero] 
									FE_TIPO   	:= "M"
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf
									MsUnlock() 
								EndIf  
							ElseIf aCols[nI][nPosTpDoc] == "RI"
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := dDataRef
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli       
									If !lRatImp
										FE_EST 		:= aCols[nI][nPosEst]
										FE_CFO	 	:= aCols[nI][nPosCodFis]  
										FE_VALBASE 	:= aCols[nI][nPosBaseR]   
										FE_ALIQ		:= aCols[nI][nPosAliqR]
										FE_RETENC 	:= aCols[nI][nPosValR]
									Endif
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNumero] 
									FE_TIPO   	:= "I"
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf
									If SFE->(FieldPos("FE_SIRECER")) > 0
										FE_SIRECER := aCols[nI][nPosCERT]
									EndIf
									If SFE->(FieldPos("FE_SIRESEG")) > 0
										FE_SIRESEG := aCols[nI][nPosSIRES]
									EndIf
									MsUnlock() 
								EndIf	
							ElseIf aCols[nI][nPosTpDoc] == "RG"
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := dDataRef
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli       
									If !lRatImp
										FE_EST 	:= aCols[nI][nPosEst]
										FE_CFO	 	:= aCols[nI][nPosCodFis]
										FE_CONCEPT 	:= aCols[nI][nPosRetGan]
										FE_VALBASE 	:= aCols[nI][nPosBaseR]
										FE_ALIQ		:= aCols[nI][nPosAliqR]
										FE_RETENC 	:= aCols[nI][nPosValR]								 
									Endif
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNumero] 
									FE_TIPO   	:= "G"
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf
									MsUnlock() 
								EndIf	
							ElseIf aCols[nI][nPosTpDoc] == "RS"
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := dDataRef
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli       
									If !lRatImp
										FE_EST 		:= aCols[nI][nPosEst]
										FE_CFO		:= aCols[nI][nPosCodFis]
										FE_CONCEPT	:= aCols[nI][nPosRetSUS]
										FE_VALBASE 	:= aCols[nI][nPosBaseR]
										FE_ALIQ		:= aCols[nI][nPosAliqR]
										FE_RETENC	:= aCols[nI][nPosValR]
									EndIf
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNumero] 
									FE_TIPO   	:= "S"
									If SFE->(FieldPos("FE_SIRECER")) > 0
										FE_SIRECER := aCols[nI][nPosCERT]
									EndIf
									If SFE->(FieldPos("FE_SIRESEG")) > 0
										FE_SIRESEG := aCols[nI][nPosSIRES]
									EndIf
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf
									MsUnlock() 
								EndIf	
							Else
								If !aCols[nI][Len(aCols[nI])] .And. ( aCols[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aCols[nI][nPosEst] + aCols[nI][nPosCodFis] + STR(aCols[nI][nPosBaseR]) + STR(aCols[nI][nPosAliqR]) )))
									RecLock("SFE",.T.)    
									FE_FILIAL   := xFilial('SFE')   
									FE_EMISSAO  := dDataRef
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLojCli    
									FE_NFISCAL  := SE1->E1_NUM
									FE_SERIE    := SE1->E1_SERIE
									FE_RECIBO   := cRecibo       
									FE_NROCERT	:= aCols[nI][nPosNum1]   
									FE_TIPO   	:= Subs( aLinRet[nX][nY][7] ,2 ,1) // I-B-S-L
									FE_RETENC 	:= aCols[nI][nPosValR]
									If lUsoSerie
										FE_SERIE := cSerie
									EndIf   
									MsUnlock() 							
								Endif
							Endif
					Else          
						If (aCols[nI][nPosVal] > 0) .And. (aCols[nI][nPosTpDoc] $ "RI") .AND. aCols[nI][nPosTransit] == "2"
							RecLock("SFE",.T.)    
							FE_FILIAL   := xFilial('SFE')   
							FE_NROCERT	:= aCols[nI][nPosNumero]  
							FE_EMISSAO  := dDataRef
							FE_CLIENTE  := cCliente
							FE_LOJCLI 	:= cLojCli    
							FE_TIPO   	:= Subs( aCols[nI][nPosTpDoc] ,2 ,1) // I-B
							FE_RECIBO   := cRecibo       
							FE_RETENC 	:= aCols[nI][nPosVal]
							If lUsoSerie
								FE_SERIE := cSerie
							EndIf   
							MsUnlock() 
						EndIf
					Endif
				Next nI
			ElseIf cPaisLoc = "PER" .And. Len(aCols) > 0
				DbSelectArea("SFE")  	  	    
				For nI:= 1 to Len(aCols)	
					If (aCols[nI][nPosTpDoc] $ "RI")
						SE1->(DbSetorder(1))
						For nX := 1 to Len(aLinRet)      
							For nY := 1 to Len( aLinRet[nX])
								If aLinRet[nX][nY][7] == aCols[nI][nPosTpDoc]      
									If (aLinRet[nX][nY][5] > 0) .And. ;
									(SE1->( DbSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) ))
										RecLock("SFE",.T.)    
										FE_FILIAL   := xFilial('SFE')   
										FE_NROCERT	:= aLinRet[nX][nY][6]  
										FE_EMISSAO  := dDataRef
										FE_CLIENTE  := cCliente
										FE_LOJCLI 	:= cLoja    
										FE_TIPO   	:= Subs( aLinRet[nX][nY][7] ,2 ,1) // I
										FE_RECIBO   := cRecibo       
										FE_NFISCAL  := SE1->E1_NUM
										FE_SERIE    := SE1->E1_SERIE
										FE_RETENC 	:= aLinRet[nX][nY][5]   
										MsUnlock() 
									EndIf
								Endif
							Next nY
						Next nX
					EndIf
				Next nI	
			EndIf

			If cPaisLoc=="PER" .And. Len(aPerc) > 0 
				cCert:= FinCertPer("P",cCliente+cLoja+"P")
				AADD(aCert,{cCert,cSerieC})
				nItem:=0
				For nX:= 1 to Len(aPerc)
					nItem+=1
					If nItem > nItensC  //  Gera novo numero de certificado de acordo com quantidade de itens no recibo
						cCert:= FinCertPer("P",cCliente+cLoja+"P") 
						AADD(aCert,{cCert,cSerieC})
						nItem:= 0 
					EndIf			

					RecLock("SFE",.T.)    
					FE_FILIAL   := xFilial('SFE')   	
					FE_NROCERT	:= cCert
					FE_SERIEC	:= cSerieC
					FE_EMISSAO  := dDataRef
					FE_CLIENTE  := cCliente
					FE_LOJCLI 	:= cLoja    
					FE_TIPO   	:= "P"
					FE_RECIBO   := cRecibo       
					FE_NFISCAL  := Iif(aPerc[nX][8],cRecibo,aPerc[nX][4])
					FE_SERIE    := aPerc[nX][5]
					FE_VALIMP 	:= Round(xMoeda(aPerc[nX][1],nMoedDesc,1,3,,aTaxa[nMoedDesc]),2)//aPerc[nX][1] 
					FE_VALBASE 	:= Round(xMoeda(aPerc[nX][3],nMoedDesc,1,3,,aTaxa[nMoedDesc]),2)//aPerc[nX][3]
					FE_ALIQ 	:= aPerc[nX][2]  
					FE_ITEM		:= nItem
					FE_ESPECIE 	:= aPerc[nX][7]
					MsUnlock()  
				Next
			EndIf

			If lGerNCC
				lGerNCC	:= .F.
				cParc	:= " "

				While SE1->(DbSeek(xFilial("SE1")+"REC"+Padr(cRecibo,TamSx3("E1_NUM")[1]," ")+Padr(cParc,TamSx3("E1_PARCELA")[1]," ")+cDocCred))
					cParc:=Soma1(cParc)
				Enddo

				For nValMoed := 1 to Len(aLinMoed)
					If cPaisLoc $ "EQU|PER" .And. lTitAd
						nValimp:= (nValPerc*(aTaxa[IIf(!lRotAuto,oCBMoed:nAt,1)]/aTaxa[nValMoed])*(1))
						nVlrTit:= aLinMoed[nValMoed,4] - nValimp
					Else
						nVlrTit	:= aLinMoed[nValMoed,4]
					EndIf	
					If nVlrTit > 0
						//-- Registro no SEL
						RecLock("SEL",.T.)
						SEL->EL_FILIAL	:= xFilial("SEL") 
						SEL->EL_TIPODOC 	:= "RA"
						SEL->EL_PREFIXO  	:= "REC"
						SEL->EL_NUMERO   	:= cRecibo
						SEL->EL_PARCELA  	:= cParc
						SEL->EL_TIPO   		:= cDocCred   // correto, grava o tipo do SX1 
						SEL->EL_EMISSAO  	:= dDataRef
						SEL->EL_DTDIGIT  	:= dDataBase
						SEL->EL_DTVCTO   	:= dDataRef
						If Empty(cNatureza)
							SEL->EL_NATUREZ  	:= Iif( Empty(SA1->A1_NATUREZ), &(GetMv("MV_1DUPNAT")) , SA1->A1_NATUREZ )
						else 
							SEL->EL_NATUREZ  	:= cNatureza
						Endif   
						SEL->EL_MOEDA    	:= StrZero(nValMoed,2)//Aqui representa qual e a moeda
						SEL->EL_VLMOED1  	:= Round( nVlrTit*aTaxa[nValMoed], MsDecimais(1))
						SEL->EL_VALOR    	:= nVlrTit
						SEL->EL_CLIENTE  	:= cCliente
						SEL->EL_LOJA	 	:= cLoja
						SEL->EL_SERIE 	 	:= cSerie
						SEL->EL_RECIBO 	 	:= cRecibo
						SEL->EL_VERSAO 		:= cRevisao
						SEL->EL_COBRAD		:=	cCobrador
						SEL->EL_RECPROV	:=	cRecProv
						SEL->EL_CLIORIG	:=	cCliOri
						SEL->EL_LOJORIG	:=	cLojOri  

						F840GrvTx( aTaxa )

						MsUnlock()

						If cPaisLoc $ "ARG|COS"
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							PcoDetLan("000361","02","FINA840") // "Cobran็as diversas - Recebimento Antecipado"
						Endif	
						//-- Registro no SE1
						RecLock("SE1",.T.)
						SE1->E1_FILIAL   	:= xFILIAL("SE1")
						SE1->E1_FILORIG     := cFilant
						SE1->E1_PREFIXO  	:= "REC"
						SE1->E1_NUM			:= cRecibo
						SE1->E1_PARCELA		:= cParc
						SE1->E1_TIPO     	:= cDocCred  // correto grava o tipo do SX1 
						SE1->E1_EMISSAO  	:= dDataRef
						SE1->E1_EMIS1    	:= dDataBase
						SE1->E1_VENCTO  	:= dDataRef
						SE1->E1_VENCREA 	:= DataValida(dDataRef)
						SE1->E1_NATUREZ  	:= SEL->EL_NATUREZ
						SE1->E1_MOEDA   	:= nValMoed
						If ( cPaisLoc == "CHI" )
							SE1->E1_VLCRUZ	:= Round( nVlrTit*aTaxa[nValMoed], MsDecimais(1) )
						Else
							SE1->E1_VLCRUZ	:= nVlrTit*aTaxa[nValMoed]
						Endif
						SE1->E1_VALOR   	:= nVlrTit
						SE1->E1_SALDO   	:= nVlrTit
						SE1->E1_CLIENTE 	:= cCliente
						SE1->E1_LOJA    	:= cLOJA
						SE1->E1_SERREC      := cSerie
						SE1->E1_RECIBO  	:= cRecibo
						SE1->E1_NOMCLI   	:= SA1->A1_NOME 
						SE1->E1_SITUACA  	:= "0"
						SE1->E1_ORIGEM   	:= "FINA840"
						SE1->E1_LA       	:= "S"
						SE1->E1_STATUS   	:= "A"
						SE1->E1_TXMOEDA		:= aTaxa[nValMoed]
						If cPaisLoc == "CHI"
							SE1->E1_CGC 		:= SA1->A1_CGC
						Endif
						If !lMsgUnica .and. nColig >0 .and. IntePms().and. MsgYesNo (OemToAnsi(STR0210)+" "+"("+cDocCred+")"+" ";
						+AllTrim(SE1->E1_NUM)+" " +OemToAnsi(STR0211)+" " +GetMv("MV_SIMB1")+" " + AllTrim(Transform(SE1->E1_VLCRUZ,PesqPict("SE1","E1_VLCRUZ")))+" " +OemToAnsi(STR0212))//"Voc๊ deseja associar o tํtulo" "de valor" "a um projeto?"
							PmsFi840()
						Endif
						If  cPaisLoc == "ARG"   
							SE1->E1_EMIS1  	:= dDataRef 
						Endif  
						
						If len(aCols)>0 .And. cPaisLoc == "ARG" .AND. SE1->(ColumnPos("E1_TIPOGR")) >0
							If ALLTRIM(aCols[1][1])=="GR"
								SE1->E1_TIPOGR="1"
							Else
								SE1->E1_TIPOGR="0"
							EndIf
						EndIf
						MsUnlock()

						aadd(aRecAdt,{SE1->(RECNO()),SE1->E1_VALOR}) //Controle de inclusใo de adiantamentos

						AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[SE1->E1_MOEDA],SE1->E1_EMISSAO)
						cParc:=Soma1(cParc)//Atualiza a proxima parcela

					EndIf
				Next nValMoed
			EndIf

			If !SuperGetMV('MV_SERREC') 
				If  __lSX8
					While ( GetSX8Len() > nSaveSx8 )
						ConfirmSX8()
					End
				Endif
			Else
				//Grava Nr do proximo Recibo da tabela RN no SX5.
				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If DbSeek(xFilial("SX5")+"RN"+cSerie)
					lBanM := .F. 
					If cpaisLoc == 'ARG' .and. Val(X5_DESCRI) == Val(cRecibo)
						lBanM:= .T.	
					ElseIf Val(X5_DESCRI) < Val(cRecibo) .and.  cpaisLoc != 'ARG' 
						lBanM:= .T.
					Endif
					//Verifica se nao foi atualizado com um numero de recibo mais novo (outra estacao)
					If lBanM == .T.
						RecLock("SX5", .F.)
						Replace X5_DESCRI  With StrZero((Val(cRecibo) + 1),TamSX3("EL_RECIBO")[1])
						Replace X5_DESCENG With StrZero((Val(cRecibo) + 1),TamSX3("EL_RECIBO")[1])
						Replace X5_DESCSPA With StrZero((Val(cRecibo) + 1),TamSX3("EL_RECIBO")[1])
						MsUnlock()
					Endif
				EndIf
			EndIf
			//Guarda Encabezado de Recibo
			DBSelectArea("FJT")
			FJT->(DBSetOrder(1))//FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
			If !(FJT->(DBSeek(xFilial("FJT")+cSerie+cRecibo+cRevisao)))
				RecLock('FJT',.T.)
				FJT_FILIAL 	:= xFilial()
				FJT_SERIE	:= cSerie
				FJT_RECIBO	:= cRecibo
				FJT_CLIENT	:= cCliente
				FJT_LOJA	:= IIf(cPaisLoc == "ARG", cLojCli, cLoja)
				FJT_COBRAD	:= cCobrador
				FJT_EMISSA	:= dDataRef
				FJT_NATUREZ	:= cNatureza
				FJT_RECPRV	:= cRecProv
				FJT_VERSAO	:= cRevisao
				FJT_VERATU	:= '1'
				FJT_DTDIGI	:= dDataBase
				MsUnLock()
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPonto de entrada depois da grava็ใo de TODOS os arquivos ณ
			//ณe antes da contabilidade                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock("FA087GRV")
				ExecBlock("FA087GRV",.F.,.F.)
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o cadastro de Recibo x Cobradores			    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nRecnoSEY > 0
				SEY->(dbGoto(nRecnoSEY))
				RecLock("SEY")
				SEY->EY_RECPEND:=SEY->EY_RECPEND -1
				If SEY->EY_RECPEND<=0
					SEY->EY_STATUS:="2"                
				EndIf	
				MsUnlock("SEY")
			EndIf
			lCancel:=.F.
			//Contabiliza
			Fa840Cont()

			//ANGOLA - Inclusao de Adiantamento nao necessita calculo de diferenca de cambio
			If !lIncAdt
				//Gera diferen็a de cambio automatica apos a grava็ใo do recebimento diversos
				aSort(aLinSE1,,,{|x,y| x[1]>y[1]})			// Organiza aLinSE1 para que os marcados venham primeiro.
				If lGeraDCam .And. lTemMon // verifica se a moeda eh maior que 1 e se irแ gerar diferen็a automatica
					DbSelectArea("SE1")
					For nI:=1 to Len(aLinSE1)
						If aLinSE1[nI][1]!=1
							Exit
						Endif
						cPrefixo := aLinSE1[nI][2] 
						cNum := aLinSE1[nI][3]
						cParcela := aLinSE1[nI][4] 
						cMoeda := aLinSE1[nI][7] 		
						DbSelectArea("SE1")
						SE1->(dbSetOrder(1))
						SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela))
						If xFilial()==SE1->E1_FILIAL .And. cNum==SE1->E1_NUM .AND. cPrefixo==SE1->E1_PREFIXO .AND. SE1->(!EOF())
							lExterno:=.T.
							lExecCor:=.T.
							nPosIni:=1
							While lExecCor 
								Pergunte("FIN74A",.F.) 
								MV_PAR01:=0    // taxa
								MV_PAR07:=2                       // Gera para   saldo
								MV_PAR08:=1                         // Gera para pago
								aArea:=GetArea()
								If!Empty(nMoedaCor:=Val(Subs(GetMv("MV_MDCFIN"),nPosIni,2)))
									If !Empty(GetMv("MV_MOEDA"+Alltrim(Str(nMoedaCor))))
										aAdd(aDatBnDif, {aRecs[1][12], aRecs[1][13], aRecs[1][14]})
										If SE1->E1_MOEDA <> nMoedaCor
											MV_PAR10:=nMoedaCor   
											cMoeda := aLinSE1[nI][7] 
											nTxaAtual:= IIf ( !Empty(SE5->E5_MOEDA) .and.  Len(aTaxa) >= VAL(SE5->E5_MOEDA), aTaxa[VAL(SE5->E5_MOEDA)], aTaxa[nMoedaCor] )
											nMdaTit=aTaxa[cmoeda]
											FA074GDif(.F.,,,lExterno)
									   		If cPaisLoc == "ARG"
												lExecCor := .F.
											EndIf
										Endif
									EndIf
									nPosIni:=nPosIni+3	 
									RestArea(aArea)	
								Else		  
									lExecCor:=.F.
								EndIf							  
							EndDo
						EndIf	
					Next nI
					Pergunte("FIN87A",.F.)
				EndIf	
			Endif      

			If cPaisLoc == "PER" .And. Len(aCert) > 0
				If MV_PAR07 == 1 
					For nI:=1 to Len(aCert)
						bBlock := &("{||"+Alltrim(mv_par08)+"(aCert[nI][1],aCert[nI][2],.T.)"+"}")
						Eval(bBLock)
					Next nI	                         
				EndIf	  	                                 
			EndIf	

			lRet := .T.  		
		End Transaction 

		ConfirmSX8()

		//Libera codigo usado pela MayIUseCode
		FreeUsedCode()
		//Destrava os registros que tenham ficado travados
		FA840Unlock()

		If cPaisLoc $ "ARG|COS"
			////////////////////////////////////////	
			// Finaliza integra็ใo com M๓dulo PCO //
			//////////////////////////////////////// 
			PcoFinLan("000361")
		Endif

	EndIf 

	If !lRet  .And. lRotAuto  
		lMsErroAuto := .T.
	EndIf

	If cPaisLoc == "ARG"  .And. ExistBlock("FA087SEL") .And. Funname()=="FINA846" .AND. lRet
		ExecBlock("FA087SEL",.F.,.F.,{})  //PE para imprimir recivos despues ge generarlos
	EndIf
	If cPaisLoc $"ARG" .AND. lRet .and. len(aAux935)>0
		For Nx:=1 to Len(aAux935)
			MSExecAuto( { |a,d| F935Grava(aAux935[Nx],.F.,.T.,.T.) },aAux935[Nx])
		Next
	EndIf
RestArea(aAreaAt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFaGrv     บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FaGrv(aCampos,aLinha)
	AEval(aCampos,{|x,y| iIf(FieldPos(x)>0,FieldPut(FieldPos(ALLTRIM(x)),aLinha[y]),)})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa840GSE5 บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa840GSE5(nTipo,cTpCred,cNatureza,cReciboSE5,cSerieSE5,aTxMoed,cDiarioSE5,cMotBxSE5,cIDProc)
	
	Local lAdiantamento:=.F.
	Local nTxMoeda := 0   
	Local nMoedaF := 1
	Local lRet			:= .T.
	Local cCposSE5		:= ""
	Local cLog			:= ""
	Local oModMovBco	:= Nil
	Local oFK5MovBco	:= Nil
	Local oFKAMovBco	:= Nil
	Local cChaveCH 	:= ""
	Local aAreaSEF 	:= ""

	Private aBaixas:= {}
	Default cReciboSE5	:= cRecibo
	Default cSerieSE5	:= cSerie
	Default aTxMoed		:= aTaxa 
	Default cDiarioSE5	:= cDiario 
	Default cMotBxSE5	:= cMOtBx	
	Default cIDProc		:= ""	

	If nTipo==1
		lAdiantamento := .F.
		nDescont	  := SE1->E1_DESCONT * aTxMoed[Max(SE1->E1_MOEDA,1)]
		nJuros		  := SE1->E1_JUROS   * aTxMoed[Max(SE1->E1_MOEDA,1)]
		nMulta		  := SE1->E1_MULTA   * aTxMoed[Max(SE1->E1_MOEDA,1)]
		nValRec		  := SE1->E1_VALLIQ  * aTxMoed[Max(SE1->E1_MOEDA,1)]

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Taxa da moeda: calcula segundo valores do titulo SE1         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nTxMoeda := Round( SE1->E1_VLCRUZ/SE1->E1_VALOR , TamSx3("M2_MOEDA"+AllTrim(STR(SE1->E1_MOEDA)))[2] )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณA correcao monetaria nao deve ser gravada pois os pagamentos sao feitos em bloco,    ณ
		//ณe nao temos como saber se o titulo foi pago com a mesma moeda (neste caso nao existe ณ
		//ณcorrecao monetaria) ou com outra moeda diferente.                                    ณ
		//ณA correcao eh tratada nos relatorios.                                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nCM			:=	0
		nValToler	:=	0
		cLoteFin	:= GetSx8Num("SE5", "E5_LOTE", "E5_LOTE" + cEmpAnt)
		If lAdiantamento
			cBanco		:= SE1->E1_PORTADO
			cAgencia	:= SE1->E1_AGEDEP
			cConta		:= SE1->E1_CONTA
		Else
			cBanco		:= ""
			cAgencia	:= ""
			cConta		:= ""
		Endif
		nValEstrang	:= SE1->E1_VALLIQ
		dBaixa  	:= SE1->E1_DTACRED
		cMotBxSE5		:= IF(Empty(SE1->E1_MOTIVO),"NOR",SE1->E1_MOTIVO)
		cHist070	:=STR0057+cReciboSE5+"-"+cSerieSE5 //"Valor recebido por Recibo "
		nMoedaF:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(GetMV("MV_MCUSTO")))
		FA070Mov(.T.,.T.,lAdiantamento,SE1->E1_DTACRED,@aBaixas,,,aTxMoed[Max(SE1->E1_MOEDA,1)],,,,,cIDProc)
		ConfirmSX8()
		AtuSalDup(IIf(SE1->E1_TIPO$MV_CRNEG+"/"+MVRECANT,"+","-"),SE1->(E1_VALLIQ+E1_DESCONT-E1_JUROS-E1_MULTA),SE1->E1_MOEDA,SE1->E1_TIPO,aTxMoed[nMoedaF],dDataBase)
		dbSelectArea("SE1")
		nSalvRec	:= SE1->(RecNo())
		cNum	  	:= SE1->E1_NUM
		cPrefixo	:= SE1->E1_PREFIXO
		cParcela	:= SE1->E1_PARCELA
		cCliente	:= SE1->E1_CLIENTE
		cLoja      	:= SE1->E1_LOJA
		cTipo   	:= ""
		If lCarga
			OmsGrvDAM(nSalvRec,SE5->E5_SEQ,cCarga,cSeqcar,cReciboSE5,"1")
		EndIf
		If SuperGETMV("MV_TPCOMIS") == "O"
			aBaixas:={}
			If UsaSeqCor()
				AAdd(aDiario,{"SE5",SE5->(Recno()),cDiarioSE5,"E5_NODIA","E5_DIACTB"})
			EndIf
			AAdd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno()),,SE1->E1_VEND1})
			Fa440CalcB(aBaixas,.F.,.F.,"FINA840",,,,.T.,SE1->(Recno()))
		Endif

	ElseIf nTipo==2

		SE5->(DbSetOrder(3))			//	E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)
		IF !(SE5->(DbSeek(xFilial("SE5")+	SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA+;
		SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPODOC+Dtos(SEL->EL_DTVCTO))))
			oModMovBco := FWLoadModel("FINM030")
			oFKAMovBco := oModMovBco:GetModel("FKADETAIL")
			oFK5MovBco := oModMovBco:GetModel("FK5DETAIL")	
			oModMovBco:SetOperation(MODEL_OPERATION_INSERT)
			oModMovBco:Activate()		
			oModMovBco:SetValue( "MASTER", "E5_GRV", .T.)
			oModMovBco:SetValue( "MASTER", "IDPROC", cIDProc)
			oModMovBco:SetValue( "MASTER", "NOVOPROC", .F. ) //Informa que a inclusใo nใo serแ feita com um novo n๚mero de processo
		Else
			Return
		Endif
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial()+SEL->(EL_BANCO+EL_AGENCIA+EL_CONTA)))
		cCposSE5 := "{"
		cCposSE5 += "{'E5_DTDIGIT', dDataBase},"
		cCposSE5 += "{'E5_DATA', SEL->EL_EMISSAO},"
		cCposSE5 += "{'E5_PREFIXO', SEL->EL_PREFIXO},"
		cCposSE5 += "{'E5_NUMERO', SEL->EL_NUMERO},"
		cCposSE5 += "{'E5_PARCELA', SEL->EL_PARCELA},"
		cCposSE5 += "{'E5_CLIFOR', SEL->EL_CLIENTE},"
		cCposSE5 += "{'E5_LOJA', SEL->EL_LOJA},"
		cCposSE5 += "{'E5_BENEF', SE1->E1_NOMCLI},"
		cCposSE5 += "{'E5_SERREC', '" + cSerieSE5 + "'},"
		cCposSE5 += "{'E5_TIPO', SEL->EL_TIPODOC},"

		If cPaisloc $ "ARG|CHI|URU|PAR"
			cCposSE5 += "{'E5_FILORIG', '" + cFilant + "'},"
		Endif
		
		// Grava o valor de corre็ใo monetแria no SE5 para ser visualizado na consulta
		If cPaisLoc == "MEX" .And. SEL->EL_MOEDA <> "1"  
			nTxCor:= Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO, SE1->E1_MOEDA))
			nValOrig:= xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),1,,,nTxCor)       
			nValAtu:= xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),1,,,aTxMoed[Val(SEL->EL_MOEDA)],aTxMoed[Max(SA6->A6_MOEDA,1)])
			cCposSE5 += "{'E5_VLCORRE', " + AllTrim(Str(nValAtu - nValOrig)) + "},"
		EndIf
		If cPaisLoc $ "EQU|DOM"
			cCposSE5 += "{'E5_BCOCHQ', SEL->EL_BCOCHQ},"
			cCposSE5 += "{'E5_AGECHQ', SEL->EL_AGECHQ},"
			cCposSE5 += "{'E5_CTACHQ', SEL->EL_CTACHQ},"		
		Endif
		cCposSE5 += "{'E5_VENCTO', STOD('" + DTOS(SEL->EL_DTVCTO) + "')}"
		cCposSE5 += "}"
		oModMovBco:SetValue( "MASTER", "E5_CAMPOS", cCposSE5)

		oFKAMovBco:SetValue( "FKA_IDORIG", FWUUIDV4() )
		oFKAMovBco:SetValue( "FKA_TABORI", "FK5" )

		oFK5MovBco:SetValue( "FK5_RECPAG", "R" )
		oFK5MovBco:SetValue( "FK5_HISTOR", PadR(STR0057 + ' '+ cReciboSE5+"-"+cSerieSE5,TamSX3("FK5_HISTOR")[1]) )	 				//"Valor recebido por Recibo "
		oFK5MovBco:SetValue( "FK5_DATA", SEL->EL_EMISSAO )
		oFK5MovBco:SetValue( "FK5_DTDISP", If(cTpCred=="1",dDataRef,SEL->EL_DTVCTO) )	 // 1-Imediato  2-Vencimento
		oFK5MovBco:SetValue( "FK5_TPDOC", "VL" )
		oFK5MovBco:SetValue( "FK5_VLMOE2", SEL->EL_VALOR )
		oFK5MovBco:SetValue( "FK5_ORDREC", cReciboSE5 )
		oFK5MovBco:SetValue( "FK5_MOEDA", StrZero( SA6->A6_MOEDA, 2))
		oFK5MovBco:SetValue( "FK5_VALOR", xMoeda(SEL->EL_VALOR,Val(SEL->EL_MOEDA),Max(SA6->A6_MOEDA,1),,,aTxMoed[Val(SEL->EL_MOEDA)],aTxMoed[Max(SA6->A6_MOEDA,1)]) )
		oFK5MovBco:SetValue( "FK5_BANCO", SEL->EL_BANCO )
		oFK5MovBco:SetValue( "FK5_AGENCI", SEL->EL_AGENCIA )
		oFK5MovBco:SetValue( "FK5_CONTA", SEL->EL_CONTA )
		oFK5MovBco:SetValue( "FK5_SEQ", PadL("1",TamSX3("E5_SEQ")[1],"0") )
		oFK5MovBco:SetValue( "FK5_LA", "S" )
		oFK5MovBco:SetValue( "FK5_NATURE", cNatureza )
		oFK5MovBco:SetValue( "FK5_TXMOED", aTxMoed[Max(SA6->A6_MOEDA,1)] )
		oFK5MovBco:SetValue( "FK5_ORIGEM", FunName() )

		//Se for movimento de cheque, vincula o cheque no processo 	
		If SEL->EL_TIPODOC == "CH"
			aAreaSEF := GetArea()
			//Verifica se o  possui ID se nใo ele cria
			dbSelectArea( "SEF" )
			dbSetOrder( 1 )

			If msSeek( xFilial("SEF") + SEL->EL_BCOCHQ + SEL->EL_AGECHQ + SEL->EL_CTACHQ + SEL->EL_NUMERO )
				If Empty( SEF->EF_IDSEF )
					cChaveCH := FWUUIDV4()             
					Reclock( "SEF", .F. )
					SEF->EF_IDSEF	:= cChaveCH
					SEF->( msUnlock() )
				Else
					cChaveCH := SEF->EF_IDSEF
				Endif

				oFKAMovBco:AddLine()
				oFKAMovBco:SetValue( "FKA_IDORIG", cChaveCH )
				oFKAMovBco:SetValue( "FKA_TABORI", "SEF" )
			Endif

			RestArea( aAreaSEF )
		Endif

		If oModMovBco:VldData()
			oModMovBco:CommitData()

			If  UsaSeqCor() 
				AAdd(aDiario,{"SE5",SE5->(Recno()),cDiarioSE5,"E5_NODIA","E5_DIACTB"})
			EndIf

			nValToler	:=0
			cBanco		:= SEL->EL_BANCO
			cAgencia	:= SEL->EL_AGENCIA
			cConta		:= SEL->EL_CONTA
			cLoteFin	:= ""
			nValEstrang	:= SE1->E1_VALLIQ
			If SEL->EL_TPCRED == "1"
				dBaixa := dDataBase
			Else
				dBaixa := SEL->EL_DTVCTO
			Endif				
			cHist070:=STR0057+cReciboSE5+"-"+cSerieSE5 //"Valor recebido por Recibo "
			IF !EMPTY(SEL->EL_BANCO).And. MovBcoBx(Padr(cMotBxSE5,10), .T.) .and. !lAdiantamento 
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Gravar Saldo Banc rio	        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				AtuSalBco(cBanco,cAgencia,cConta,dBaixa,SE5->E5_VALOR,"+")
			EndIf		
		Else
			cLog := cValToChar(oModMovBco:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModMovBco:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModMovBco:GetErrorMessage()[6])        	
			Help( ,,"MF840GSE5",,cLog, 1, 0 )
			lRet := .F.
			lMsErroAuto := .T.
		Endif
		oModMovBco:DeActivate()		
	Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa840Cont บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840Cont()
	
	Local nHdlPrv	:=0
	Local cKeyImp 	:= ""
	Local cAlias	:= ""
	Local lAchou	:=.F.       
	Local aFlagCTB 	:= {}
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
	Local nXE5 		:=0
	Local cPadrao 	:= ""
	
	nTotalLanc		:=0
	cArquivo		:= ""
	nLinha 			:= 1

	If lGeraLanc

		//+--------------------------------------------------------------+
		//ฆ Posiciona numero do Lote para Lancamentos do Financeiro      ฆ
		//+--------------------------------------------------------------+
		dbSelectArea("SX5")
		dbSeek(xFilial()+"09FIN")
		cLoteCom:=IIF(Found(),AllTrim(X5DESCRI()),"FIN")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa Lancamento Contabil                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nHdlPrv := HeadProva( cLoteCom,;
		"FINA840" /*cPrograma*/,;
		Substr( cUsuario, 7, 6 ),;
		@cArquivo )

		If nHdlPrv <= 0
			Help(" ",1,"A100NOPROV")
		EndIf
	Else 
		Return
	EndIf

	If nHdlPrv > 0 .and. lGeraLanc

		//+--------------------------------------------------+
		//ฆ Gera Lancamento Contab. para RECIBO.             ฆ
		//+--------------------------------------------------+
		If lGeraLanc
			SEL->(DbSetOrder(8))
			SEL->(DbGotop())
			SEL->(DbSeek(xFilial("SEL")+cSerie+cRECIBO,.F.))
			Do while !SEL->(EOF()) .And. SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRECIBO

				Do Case 
					Case SEL->EL_TIPODOC == "TB" .And. SEL->EL_TIPO $ MV_CRNEG+"/"+ MVRECANT .And. VerPadrao("5BN")
					lLancPad70 := .T. 
					cPadrao := "5BN" 
					Case SEL->EL_TIPODOC == "TB" .And. !(SEL->EL_TIPO $ MV_CRNEG+"/"+MVRECANT) .And. VerPadrao("5BO")
					lLancPad70 := .T.
					cPadrao := "5BO"			
					Case SEL->EL_TIPODOC == "RA" .And. VerPadrao("5BP")
					lLancPad70 := .T. 
					cPadrao := "5BP"
					Case SEL->EL_TIPODOC == "CH" .And. VerPadrao("5BQ")
					lLancPad70 := .T.  
					cPadrao := "5BQ"
					Case SEL->EL_TIPODOC == "DC" .And. VerPadrao("5BR")
					lLancPad70 := .T.
					cPadrao := "5BR"
					Case SEL->EL_TIPODOC == "EF" .And. VerPadrao("5BS")
					lLancPad70 := .T. 
					cPadrao := "5BS"
					Case SEL->EL_TIPODOC == "TF" .And. VerPadrao("5BT")
					lLancPad70 := .T.
					cPadrao := "5BT"
					Case SEL->EL_TIPODOC $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5BU")
					lLancPad70 := .T.
					cPadrao := "5BU"
					Otherwise
					lLancPad70 := VerPadrao("575")
					cPadrao := "575"   
				EndCase			
				If lLancPad70
					SA6->(DbsetOrder(1))
					SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))

					SE1->(DbsetOrder(2))
					SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))

					Do Case
						Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
						cAlias := "SF1"
						Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
						cAlias := "SF1"         
						Otherwise
						cAlias := "SF2"    
					EndCase
					cKeyImp := 	xFilial(cAlias)	+;
					SE1->E1_NUM		+;
					SE1->E1_PREFIXO	+;
					SE1->E1_CLIENTE	+;
					SE1->E1_LOJA			
					If ( cAlias == "SF1" )
						cKeyImp += SE1->E1_TIPO   
					Endif
					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
					lAchou:=.F.

					SE5->(DbSetOrder(2))
					//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
					//A diferenca estah no campo E5_ORDREC(numero do recibo)		
					If SE5->(DbSeek(xFilial("SE5")+"BA"+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
						While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
						SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;
						SEL->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_TIPODOC == "BA" .And.!SE5->(Eof()) .And. !lAchou
							If (SE5->E5_ORDREC == cRECIBO .And. SE5->E5_SERREC== cSerie )
								lAchou:=.T.
							Else
								SE5->(DbSkip())			
							EndIf

						EndDo
					EndIf

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Prepara Lancamento Contabil                                      ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
						aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
					Endif
					nTotalLanc := nTotalLanc + DetProva( nHdlPrv,;
					cPadrao,;
					"FINA840" /*cPrograma*/,;
					cLoteCom,;
					@nLinha,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )


					If UsaSeqCor()
						AAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
					EndIf
				Endif	

				SEL->(DbSkip())
			EndDo
			If cPaisLoc == "PER"
				For nXE5 := 1 to Len(aRecnoITF)
					SE5->(DbGoto(aRecnoITF[nXE5]))
					If lFindITF 
						FinProcITF(SE5->(Recno()),8,SE5->E5_VALOR,.F.,{nHdlPrv,cPadrao,"FINA840","FINA840",cLotecom})
					Endif   
				Next
			Endif
		Endif

		//+-----------------------------------------------------+
		//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
		//+-----------------------------------------------------+
		SEL->(DbSetOrder (8))
		SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetiva Lanamento Contabil                                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RodaProva(	nHdlPrv,; 
		nTotalLanc )

		lLanctOk := cA100Incl(	cArquivo,;
		nHdlPrv,;
		3 /*nOpcx*/,;
		cLoteCom,;
		lDigita,;
		lAglutina,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		aDiario )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento


		If lLanctOk
			SEL->(DbSetOrder (8))
			If SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))
				Do while SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRecibo
					RecLock("SEL",.F.)
					Replace EL_LA With "S"
					MsUnLock()
					SEL->(DbSkip())
				Enddo
			EndIf
		Endif
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa840When  บAutor  ณBruno Sobieski      บ Data ณ  07/30/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermissao de digitacao dependendo de outros campos.		  บฑฑ
ฑฑบ          ณX3_WHEN                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a840When(cCampo)
	
	Local nPosTpDoc 	:=	Ascan(aHeader,{|x| x[2] == "EL_TIPODOC"})
	Local nPosTpCred	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == "EL_TPCRED"})
	Local lRet	:=	.T.
	If cCampo == "TPCRED"
		If Empty(aCols[n][nPosTpCred])
			MsgAlert(OemToAnsi(STR0061)) // "Por favor, complete el campo 'Tipo de documento' primero"
			lRet	:=	.F.
		ElseIf	!(aCols[n][nPosTipo] $ cCredMed) .Or. (aCols[n][nPosTpDoc] == "CHF") 
			MsgAlert(OemToAnsi(STR0062)) //  "Este campo esta disponible solamente para documentos de credito Aplazado"
			lRet	:=	.F.
			If (aCols[n][nPosTipo] $ cCredInm) 
				//Imediato
				aCols[n][nPosTpCred]	:=	"1"
			Else          
				If (aCols[n][nPosTpDoc] == "CHF") 
					//Acreditacion
					aCols[n][nPosTpCred]	:=	"3"
				Else
					//Fiscal
					aCols[n][nPosTpCred]	:=	"4"
				EndIF
			Endif
		Endif
	ElseIf cCampo == "PREFIXO"
		If nPosTpDoc > 0
			If AllTrim(aCols[n][nPosTpDoc]) == "DC" //Pagare
				lRet := .F.
			Endif
		EndIf
	Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa840CancelบAutor ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840Cancel(nPan,nLPan)

	FA840Unlock()

	If nPan == nLPan
		FA840aCtbA(2)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa840Lock  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a840Lock(nPos,lLock)
	
	Local nPosRec	:=	0
	Local lRet	:=	.T.
	
	If aLinSE1[nPos,Len(aLinSE1[1])-1] <> Nil
		If lLock
			SE1->(DbGoTo(aLinSE1[nPos,Len(aLinSE1[1])-1]))
			If SE1->(MsRLock(RECNO()))
				AAdd(aRLocks,SE1->(RECNO()))
			Else
				Alert(OemToAnsi(STR0073)) //"El registro esta en uso por otra estacion"
				lRet	:=	.F.	
			Endif
		Else
			SE1->(DbGoTo(aLinSE1[nPos,Len(aLinSE1[1])-1]))
			SE1->(MsRUnlock(RECNO()))
			nPosRec	:=	AScan(aRLocks,SE1->(RECNO()))
			If nPosRec != 0
				ADel(aRLocks,nPosRec)
				ASize(aRLocks,Len(aRLocks)-1)	
			EndIf			
		Endif
	EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA840SugerirบAutor  ณMicrosiga           บ Data ณ  03/23/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840Sugerir()

	Local nPosPref	:= AScan(aCposSE1,"E1_PREFIXO")
	Local nPosNum 	:= AScan(aCposSE1,"E1_NUM")
	Local nPosParc	:= AScan(aCposSE1,"E1_PARCELA")
	Local nPosTipo	:= AScan(aCposSE1,"E1_TIPO")
	Local nPosValor	:= AScan(aCposSE1,"E1_VALOR")
	Local nJ			:= 0   
	Local aRet := {}    

	nPosBx :=	Ascan(aCposSE1,"nBaixar")

	SE1->(DbSetorder(1))
	For nJ:=1 to Len(aLinSE1)

		SE1->(DbSeek(xFilial("SE1")+aLinSE1[nJ][nPosPref]+aLinSE1[nJ][nPosNum]+;
		aLinSE1[nJ][nPosParc]+aLinSE1[nJ][nPosTipo]))
		If cPaisLoc $ "ARG|COS"
			If SE1->E1_DTDIFCA >= dDataBase
				nJ++
				Loop
			Endif	
		Endif
		If !a840Lock(nJ,.T.)
			nJ++
			Loop
		Endif
		nValOrig	:= aLinSE1[nJ][nPosValor]
		nTotAbat	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataRef)
		nParciais	:= aLinSE1[nJ][nPosValor]-SE1->E1_SALDO

		nDescont	:= aLinSE1[nJ][nPosDesc]
		nJuros		:= aLinSE1[nJ][nPosJuros]
		nMulta		:= aLinSE1[nJ][nPosMulta]
		nValEstr	:= 0
		dnCorrec	:= 0
		nSaldo		:= SE1->E1_SALDO-nTotAbat-nRetCfg-nDescont+nMulta+nJuros
		nValRec		:= nSaldo  + nRetCfg

		nBx:=Ascan(aCposSE1,"nBxMoeda" + Alltrim(Str(SE1->E1_MOEDA)))

		If aLinMoed[SE1->E1_MOEDA][4] >= nValRec-nMulta+nDescont-nJuros .Or. aLinSE1[nj][nPosTipo]$MVRECANT+"/"+MV_CRNEG
			aLinSE1[nJ][nBx]		:= nValRec
			aLinSE1[nJ][nPosDesc]	:= nDescont
			aLinSE1[nJ][nPosJuros]	:= nJuros
			aLinSE1[nJ][nPosMulta]	:= nMulta
			aLinSE1[nJ][nPosBx]	  	:= nValRec-nMulta+nDescont-nJuros
			aLinSE1[nJ][nPosMotBx] 	:= "NOR"
			If aLinSE1[nJ][nPosTipo] $ MVRECANT+"/"+MV_CRNEG
				aLinMoed[SE1->E1_MOEDA][4]+=nValRec-nMulta+nDescont-nJuros
			Else
				aLinMoed[SE1->E1_MOEDA][4]-=nValRec-nMulta+nDescont-nJuros
			Endif
			If nValRec>0
				aLinSE1[nJ,1] := 1
			Endif
		Endif
	Next nJ

	If ExistBlock("F087BTNSG")
		aRetLinSE1 := ExecBlock("F087BTNSG",.F.,.F.,{aLinSE1,aLinMoed})
		If ValType(aRet) == "A" .And. Len(aRet) == 2 //Se o retorno foi um array e se esta com duas dimensoes (aLinSE1 e aLinMoed)
			aLinSe1 := IIf(Len(aRet[1]) == Len(aLinSE1), aClone(aRet[1]), aLinSE1) //Se estiver com o mesmo tamanho do array original, atribuo o novo array
			aLinMoed := IIf(Len(aRet[2]) == Len(aLinMoed), aClone(aRet[2]), aLinMoed) //Se estiver com o mesmo tamanho do array original, atribuo o novo array
		EndIf
	EndIf

	oLbSE1:Refresh()
	FaMoedas()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA840FiltrarบAutor ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840Filtrar(nPan,cNumFatAut)

	Local aCpos:={}
	Local ctitulo
	Local oBtn
	Local oBtnOp
	Local cCampo := ""
	Local aStrOp
	Local cOper
	Local oExpr
	Local cExpr:=""
	Local oCampo
	Local aCampo:={}
	Local cTxtFil := ""
	Local cExpFil := ""
	Local oTxtFil
	Local oOper
	Local oMatch
	Local nMatch := 0
	Local nI := 0

	Private lMarca := -1                        

	Default cNumFatAut :=""       

	oGetSEL:oBrowse:lDisablepaint:=.T.
	If nPan==2
		aCpos:=aClone(aCabSA1)
		// Adiciona campo de Marca
		AADD(aCampo,{lMarca,STR0074,.F.,"01",1,Space(45),"N",0}) //"Selecionado"
		For nI:= 1 to Len(aHeadSA1)
			AADD(aCampo,{aHeadSA1[nI][2],aHeadSA1[nI][1],.T.,"01",aHeadSA1[nI][4],If(Empty(aHeadSA1[nI][3]),Space(45),aHeadSA1[nI][3]),aHeadSA1[nI][8],aHeadSA1[nI][5]})
		Next nI
	Endif
	If nPan==3
		aCpos:=aClone(aCabSE1)
		// Adiciona campo de Marca
		AADD(aCampo,{lMarca,STR0074,.F.,"01",1,Space(45),"N",0}) //"Selecionado"
		For nI:= 1 to Len(aHeadSE1)
			AADD(aCampo,{aHeadSE1[nI][2],aHeadSE1[nI][1],.T.,"01",aHeadSE1[nI][4],If(Empty(aHeadSE1[nI][3]),Space(45),aHeadSE1[nI][3]),aHeadSE1[nI][8],aHeadSE1[nI][5]})
		Next nI
	Endif
	nI:=1

	cTitulo:=STR0066 //"Filtrar"

	DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL OF oDlgRecibo

	aStrOp := { OemToAnsi(STR0075),OemToAnsi(STR0076),OemToAnsi(STR0077),OemToAnsi(STR0078),OemToAnsi(STR0079),OemToAnsi(STR0080),OemToAnsi(STR0081),OemToANsi(STR0082 ),OemToANsi(STR0083),OemToAnsi(STR0084)}	//  //"Igual a"###"DIferente de"###"Menor que"###"Menor ou igual a"###"Maior que"###"Maior ou igual a"###"Contm a expresso"###"No contm"###"Est  contido em"###"No est  contido em"
	@ 05,005 SAY OemToAnsi(STR0085) SIZE 20,8 PIXEL OF oDlgPesq //  //"Campo:"
	@ 05,060 SAY OemToAnsi(STR0086) SIZE 30,8 PIXEL OF oDlgPesq   //  //"Operador:"
	@ 05,115 SAY OemToAnsi(STR0087) SIZE 30,8 PIXEL OF oDlgPesq  //  //"Expresso:"
	@ 50,005 SAY OemToAnsi(STR0088) SIZE 20,8 PIXEL OF oDlgPesq  //  //"Filtro:"

	@ 35,005 BUTTON oBtna PROMPT OemToAnsi(STR0089) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Adiciona"
	ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,cExpr,.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtnExp:Disable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
	FONT oDlgPesq:oFont // 

	@ 35,45 BUTTON oBtn PROMPT OemToAnsi(STR0090) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Limpa Filtro"
	ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnExp:Enable(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
	FONT oDlgPesq:oFont // 

	@ 35,85 BUTTON oBtnExp PROMPT OemToAnsi(STR0091) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Expresso"
	ACTION (lRet:=FilterExp(@cTxtFil,@cExpFil),oTxtFil:Refresh(),If(lRet,oBtnOp:Disable(),oBtnOp:Enable()),If(lRet,oBtnExp:Disable(),oBtnExp:Enable()),If(lRet,oBtna:Disable(),oBtna:Enable()),If(lRet,oBtnE:Enable(),oBtnE:Disable()),If(lRet,oBtnOu:Enable(),oBtnOu:Disable())) ;
	FONT oDlgPesq:oFont  // 

	@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
	ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;

	@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
	ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;

	@ 45,175 BUTTON oBtne PROMPT OemToAnsi(STR0092) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" E "
	ACTION (cTxtFil+=STR0092,cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //" e "

	@ 45,190 BUTTON oBtnOu PROMPT OemToAnsi(STR0093) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" OU "
	ACTION (cTxtFil+=STR0093,cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //" ou "
	oMatch:Disable()
	
	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
	ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	cExpr := CalcField(oCampo:nAt,aCampo)
	cOper := aStrOp[1]
	
	@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
	ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	
	@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont
	
	@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
	oTxtFil:bRClicked := {||AlwaysTrue()}
	
	oBtne:Disable()
	oBtnou:Disable()
	
	DEFINE SBUTTON FROM 113,070  TYPE 1  ACTION (aFilOK(cExpFil,cNumFatAut),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON FROM 113,100  TYPE 2  ACTION (oDlgPesq:End()) OF oDlgPesq When .T.
	
	ACTIVATE MSDIALOG oDlgPesq CENTERED
	
	If nPan==2
		oLBCli:SetArray(aLinSA1)
		oLBCli:bLine:= { || &(cBLinSA1 + "}") }
		oLBCli:Refresh()
	Endif
	If nPan==3
		oLBSE1:SetArray(aLinSE1)
		oLBSE1:bLine:= { || &(cBLinSE1 + "}") }
		oLBSE1:Refresh()
	Endif
	
	oGetSEL:oBrowse:lDisablepaint:=.F.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalcField บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcField(nAt,aCampo)

	Local cRet
	
	If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
	ElseIf aCampo[nAt,7] == "N"
	cRet := 0
	ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuildTxt  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)

	Local cChar := OemToAnsi(CHR(39))
	Local cType := ValType(xExpr)
	Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}
	
	cTxtFil += cCampo+" "+cOper+" "+IIf(cType=="C",cChar,"")+cValToChar(xExpr)+IIf(cType=="C",cChar,"")
	
	If cType == "C"
		#ifndef TOP
			If aOper[nOper] == "!."    //  Nao Contem
				cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ AllTrim('+aCampo[nCpo,1]+'))'   // Inverte Posicoes
			ElseIf aOper[nOper] == "!x"   // Nao esta contido
				cExpFil += '!(AllTrim('+aCampo[nCpo,1]+") $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
			ElseIf aOper[nOper]	== ".."  // Contem a Expressao
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ AllTrim("+aCampo[nCpo,1] +" )"   // Inverte Posicoes
		#else
			If  aOper[nOper] == "!."    //  Nao Contem
			cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+aCampo[nCpo,1]+')'   // Inverte Posicoes
			ElseIf aOper[nOper] == "!x"   // Nao esta contido
			cExpFil += '!('+aCampo[nCpo,1]+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
			ElseIf aOper[nOper]	== ".."  // Contem a Expressao
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+aCampo[nCpo,1] +" "   // Inverte Posicoes
		#endif
	Else
		#ifndef TOP
			If (aOper[nOper]=="==")
				cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
				cExpFil += '"'+cValToChar(xExpr)+'"'
			Else
				cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
				cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
			EndIf
		#else
			If (aOper[nOper]=="==")
				cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
				cExpFil += '"'+cValToChar(xExpr)+'"'
			Else
				cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
				cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
			EndIf
		#endif
		EndIf
	ElseIf cType == "D"
		// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
		// 						 
		cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
		cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
	Else
		cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
		cExpFil += cValToChar(xExpr)
	EndIf

Return cTxtFil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFilterExp  บAutor  ณMicrosiga          บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FilterExp(cTxtFil,cExpFil)

	Local oDlg, oBtn, cExpr := Space(255), oPai
	Local lProcess := .f.
	
	oPai:= GetWndDefault()
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0094) FROM 0,0 TO 100,500 OF oPai PIXEL //"Expressใo:"
	
	@ 10,10 MSGET oExpr VAR cExpr SIZE 230,10 OF oDlg PIXEL
	
	@ 30,10 TO 30,240 OF oDlg PIXEL
	
	@ 35,10 BUTTON oBtn PROMPT OemToAnsi(STR0089) SIZE 40,10 PIXEL ACTION (lProcess := .t.,oDlg:End()) //  //"&Adiciona"
	
	@ 35,55 BUTTON oBtn PROMPT OemToAnsi(STR0095) SIZE 40,10 PIXEL ACTION oDlg:End() //  //"&Cancela"
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lProcess
	
		cTxtFil += Trim(cExpr)
		cExpFil += Trim(cExpr)
		
		// Retorno correto para o Enable/Disable dos botoes.
		If Empty(cExpr)
			lProcess:= .F.
		EndIf
	
	EndIf
	
Return lProcess

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFilOk    บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFilOk(xExpr,cNumFatAut)

DEFAULT cNumFatAut := ""

aFiltros[nPanel]:=xExpr
Refdata(nPanel,cNumFatAut)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA840Desconto  บAutor  ณMicrosiga       บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840Desconto()

	oPanel[nPanel]:lReadOnly:=.T.
	oPanBut:lReadOnly:=.T.
	oCBMoed1:nAt:=nMoedDesc
	oPDesc:Show()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA840OKDesc  บAutor  ณMicrosiga         บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840OKDesc(cNumFatAut)
	
	Local anTotBx
	Local nX     
	DEFAULT cNumFatAut := ""
	
	If aTaxa[nMoedDesc]<=0
		Alert(STR0052) //"Informe todas as taxas das moedas que serใo utilizadas nas Baixas."
		Return .F.
	Endif
	
	// Para poder fazer a valida็ใo do valor do desconto, transformo o valor 
	// total de baixas para a moeda em que o desconto foi dado, depois faco a comparacao.
	nTot	:= 0
	nX		:= 0
	If nDescTot > 0
		anTotBx:=SomaBaixa()
		For nX := 1 to Len(anTotBx)
			nTot += anTotBx[nX]*aTaxa[nX]
		Next nX
		nTot:=nTot/aTaxa[nMoedDesc]
		If nDescTot > nTot 
			Alert(STR0096)  //"Valor do desconto nใo pode ser maior que o valor a baixar."
			Return .F.
		Endif
	EndIf 
	
	nDescGer := nDescTot
	nPercGer := nPercDesc
	oPDesc:Hide()
	FaMoedas()
	oPanBut:lReadOnly := .F.
	oPanel[nPanel]:lReadOnly := .F.
	RefData(4,cNumFatAut)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF840MotBx บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840MotBx()

	If oMotBx:nAt>1   .and. cPaisLoc <> "ARG"
		nDescont:= aLinSE1[oLBSE1:nAt][nPosDesc]
		nJuros	:= aLinSE1[oLBSE1:nAt][nPosJuros]
		nMulta	:= aLinSE1[oLBSE1:nAt][nPosMulta]
		oDescont:Disable()
		oMulta:Disable()
		oJuros:Disable()
		FAPagtoAtu()
	Else
		oDescont:Enable()
		oMulta:Enable()
		oJuros:Enable()
	Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa840VerPE บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function a840VerPE(nMoeda,nValor)
	Local lRet := .T.
	Local cVar  
	
	If ExistBlock("Fa087Pg")                                         
		cVar := ReadVar()
		lRet := ExecBlock("Fa087Pg",.F.,.F.,{nMoeda,nValor})   
		&(cVar) := aLinBaixa[nMoeda][2]
		If oRetCfg != Nil
			oRetCfg:Refresh()
		EndIf
		oParciais:Refresh()
		oDescont:Refresh()
		oMulta:Refresh()
		oJuros:Refresh()
		oLBBaixa:SetArray(aLinBaixa)
		oLBBaixa:bLine 	:= { || {aLinBaixa[oLBBaixa:nAT][1],;
		Transform(aLinBaixa[oLBBaixa:nAT][2],PesqPict("SE1","E1_VALOR",18,oLBBaixa:nAT)) }}
		oLBBaixa:Refresh()
	EndIf

Return lRet


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTelaAdmCarณ Autor ณ Fernando Machima      ณ Data ณ19/08/2001ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Mostra a tela para selecionar a administradora de cartao deณฑฑ
ฑฑณ          ณ credito                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TelaAdmCar(cPref,cNum,cParc,nValor,nMoeda,n)

	Local oDlgAdm,oCbxAdm,olbl1,olbl2,oBtn1
	Local cCodAdm  := ""
	Local aAdm     := {}
	Local aSAE     := {}
	Local lRet     := .T. 
	Local aAreaAtu := GetArea()
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSAE := SAE->(GetArea())
	
	DEFINE FONT oFnt  NAME "Times New Roman" SIZE 7,15 
	DEFINE FONT oFntB NAME "Times New Roman" SIZE 7,15 BOLD
	
	DbSelectArea("SAE")
	DbSetOrder(1)
	DbGoTop()
	While !Eof()
		If (AllTrim(SAE->AE_TIPO) == "CC") .or. (AllTrim(SAE->AE_TIPO) == "CD")
			AAdd(aAdm,SAE->AE_COD +" - "+SAE->AE_DESC)
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SAE->AE_COD))
			AAdd(aSAE,{SA1->A1_COD,SA1->A1_LOJA,SubStr(SA1->A1_NOME,1,30),SAE->AE_TIPO})
		EndIf
		DbSkip()
	EndDo
	
	If Len(aAdm) == 0
		MsgStop(OemToAnsi(STR0103)) //"Nao e possivel efetuar a baixa dos titulos porque nao existe uma Administradora Financeira de Cartao de Credito/Debito cadastrada"
		lRet := .F.
	Else               
		//Limpa o array para que sejam armazenados apenas os 
		//dados mais recentes...
		
		DEFINE MSDIALOG oDlgAdm FROM  34,155 TO 245,510 ;
		TITLE STR0104 PIXEL //"Administradora de Cartao de Credito"
		
		@  05, 05 Group olbl1 TO 045,173 LABEL OemToAnsi(STR0105) OF oDlgAdm PIXEL //" Dados do Recebimento "
		
		@  15, 010 SAY STR0106       FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Numero: "
		@  15, 040 SAY oNum VAR cNum FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE 
		
		@  15, 075 SAY STR0107         FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Prefixo: "
		@  15, 110 SAY oPref VAR cPref FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE 
		
		@  25, 010 SAY STR0108         FONT oFnt  PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Parcela: "
		@  25, 040 SAY oParc VAR cParc FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE
		
		@  25, 075 SAY STR0109       FONT oFnt PIXEL SIZE 50,18 COLOR CLR_RED,CLR_WHITE //"Valor: "
		@  25, 110 SAY oValor VAR Transform(nValor,PesqPict("SEL","EL_VALOR",,nMoeda)) FONT oFntB PIXEL SIZE 50,18 COLOR CLR_BLACK,CLR_WHITE
		
		@  50, 005 Group olbl2 TO 75,173 LABEL OemToAnsi(STR0110) OF oDlgAdm PIXEL //" Administradora "
		
		@  60, 010 COMBOBOX oCbxAdm VAR cCodAdm ITEMS aAdm SIZE 70,35 OF oDlgAdm PIXEL
		
		DEFINE SBUTTON oBtn1 FROM 085,145 TYPE 1 ENABLE;
		ACTION (AAdd(aDadosAdm,{aSAE[oCbxAdm:nAt][01],aSAE[oCbxAdm:nAt][02],;
		aSAE[oCbxAdm:nAt][03],aSAE[oCbxAdm:nAt][04],n}),oDlgAdm:End());
		OF oDlgAdm PIXEL
		
		ACTIVATE DIALOG oDlgAdm CENTERED
	EndIf
	
	//Restaura as areas originais...
	SA1->(RestArea(aAreaSAE))
	SA1->(RestArea(aAreaSA1)) 
	RestArea(aAreaAtu)

Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFA840COB  ณ Autor ณ Paulo Augusto         ณ Data ณ07/08/2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida para saber se o recibo pertence ao cobrador e tb se ณฑฑ
ฑฑณ          ณ esse talao ja esta fechado                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840Cob(cTipo)
	// Paulo
	Local aArea:=GetArea()       
	Local lRet:=.F.
	Local lValSer 
	
	lValSer := SuperGetMv('MV_SERREC') // Usando serie nos recibos 
	
	If !Empty(cCobrador)
		DbSelectArea("SAQ")
		DbSetOrder(1)
		If dbSeek(xFilial("SAQ")+cCobrador) 
			nRecnoSAQ:=Recno()
			If SAQ->AQ_TIPOREC=="3" .or. cTipo <> SAQ->AQ_TIPOREC .or. cTipo= "3"
				lRet:=.T.
			Else
				cRecComp	:= Iif(SAQ->AQ_TIPOREC =="1",cRecibo,cRecProv)
				cTipo 	:= SAQ->AQ_TIPOREC // Valida Tipo do Recibo do Cobrador  
				DbSelectArea("SEY")
				DbSetOrder(1)
				If dbSeek(xFilial("SEY")+cCobrador)      
					//So validar a serie quando ้ um recibo definitivo, provisorio nao tem serie
					While !EOF() .and. cCobrador == SEY->EY_COBRAD 	
						If SEY->EY_STATUS<>"2" .and. cTipo == SEY->EY_TIPOREC .and. ;
							cRecComp  >= SEY->EY_RECINI .and. cRecComp <= SEY->EY_RECFIN .and.;
							If(lValser .And. cTipo == '1', cSerie== SEY->EY_SERIE .Or. Empty(SEY->EY_SERIE),.T.)
								
							lRet:=.T.
							nRecnoSEY := SEY->(Recno())
							Exit
						EndIf
						DbSkip()
					EndDo
				EndIf
				If !lRet
					HELP(" ",1,"A087NUMV")
				EndIf
			EndIf
		Else
			Help(" ",1,"RECNO")
		EndIf
	Else	
		lRet:=.T.
	EndIf	
	RestArea(aArea)
	
Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFa840Com  ณ Autor ณ Paulo Augusto         ณ Data ณ07/08/2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Grava o arquivo de comissoes  de cobrador                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840Com() 

	Local aCpoSEX:={}
	
	SAQ->(dbGoto(nRecnoSAQ))
	//SE MUDAR ALGUMA POSICAO DO ARRAY ABAIXO, PRECISA CORRIGIR TB NOS FONTES FINA016/FINA87A/FINA088.
	AADD(aCpoSEX,SEL->EL_COBRAD )
	AADD(aCpoSEX,SEL->EL_SERIE )
	AADD(aCpoSEX,SEL->EL_RECIBO )
	AADD(aCpoSEX,SEL->EL_DTDIGIT )
	AADD(aCpoSEX,SEL->EL_CLIORIG)
	AADD(aCpoSEX,SEL->EL_LOJORIG )
	AADD(aCpoSEX,SEL->EL_VALOR  )
	AADD(aCpoSEX, SAQ->AQ_COMIS)
	AADD(aCpoSEX,Val(SEL->EL_MOEDA))
	AADD(aCpoSEX,(SEL->EL_VALOR ) *(SAQ->AQ_COMIS/100) )
	AADD(aCpoSEX,SEL->EL_TIPODOC )	
	AADD(aCpoSEX,SEL->EL_NUMERO)
	
	Fa016Calc(aCpoSEX)	

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840Marca() ณAutor ณ  Paulo Augusto       ณDataณ 19.02.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Inverte selecao na tela de clientes                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION A840Marca()

Local nJ:=1

For nJ:=1 to Len(aLinSA1)
aLinSA1[nJ,1] := aLinSA1[nJ,1] * -1
Next nJ
oLBCli:Refresh()

Return
//--

Static Function A840Load(aC, nRecs, cCond, lAchou, lRecno, aCpos, c_Alias)

	Local nLin    := 0
	Local nCol    := 0
	Local nPos    := 0
	Local sPart   :=""
	Local sPart1  :=""
	
	If cPaisLoc == "ARG"
		nPos=AT('==',cCond)
		If nPos >0
			nPos=AT('"',cCond)
			If nPos>0
			   sPart:= SUBSTR(cCond,1,nPos-1)
			   sPart1:= SUBSTR(cCond,nPos,Len(cCond)-1)
			   sPart1:=StrTran(sPart1,'"', "" )
			   sPart1:=StrTran(sPart1,"'", "" )
			   sPart1:="'"+sPart1+"'"
			   cCond=sPart+sPart1
			EndIf
		EndIf
	EndIf
	If &(cCond)
		nSel:= -1
		lAchou:=.T.
		AAdd(aC,Array(Len(aCpos)+nRecs))
		aEval(aCpos,{|x,y| aC[Len(aC)][y] := &(x)})
		If lRecno
			aC[Len(aC)][Len(aC[1])-1]:=(c_Alias)->R_E_C_N_O_
		Endif	
		aC[Len(aC)][Len(aC[1])]:=.F.
		If c_Alias == "SE1TMP"
			nLin     := Len(aC)
			nCol     := Len(aC[nLin])-1             
			If !Empty(aC[nLin][nCol])
			SE1->(MsGoto(aC[nLin][nCol]))
			aC[nLin][nPosDesc]  := FaDescFin("SE1",dDataRef,SE1->E1_SALDO,SE1->E1_MOEDA)
			aC[nLin][nPosJuros] := fa070Juros(Max(SE1->E1_MOEDA,1))
			EndIf
	
			//Monta array de controle de alteracoes...
			AAdd(aLinSE1_Ori,{aC[nLin][1],aC[nLin][2],aC[nLin][3]})
		EndIf
	Endif

Return Nil

//--
Static Function ValAltArray(aArrayPanel,aArrayPanOri,aArrayAtu,aArrayOri,cCliOri)

	Local lRet := .F.
	Local nI   := 0
	Local nPosOri	:= 0
	Local nPosCod  :=	Ascan(aCposSA1,{|x| Alltrim(x)=="A1_COD"})
	Local nPosLoj	:=	Ascan(aCposSA1,{|x| Alltrim(x)=="A1_LOJA"})
	
	//O Array esta vazio e ainda nao valorizado...
	If Len(aArrayPanel)==1 .And. Empty(aArrayPanel[1][2])
		lRet     := .T.
		cCliOri  := cCliente+cLoja            
		//Monta de controle - Clientes...
		aArrayOri:= {}
		aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
	EndIf
	
	//Verifica se foi alterado o cliente e a loja...
	If !lRet .And. (cCliLoj_Ori <> cCliente+cLoja)
		lRet     := .T.
		cCliOri  := cCliente+cLoja            
		//Monta de controle - Clientes...
		aArrayOri:= {}
		aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
	EndIf
	
	//Verifica se existiu alguma alteracao no array...
	If !lRet       
		For nI := 1 To Len(aArrayOri)
			If (nPosOri	:=	AScan(aArrayAtu, {|x| x[nPosCod]+x[nPosLoj]==aArrayOri[nI][2]+aArrayOri[nI][3]}))==0 .Or.;
				aArrayAtu[nPosOri][01] != aArrayOri[nI][01]
				lRet := .T.
				//Monta de controle - Clientes...
				aArrayOri   := {}
				aEval(aLinSA1,{|x,y| AAdd(aArrayOri,{x[1],x[nPosCod],x[nPosLoj]})})
				aArrayPanOri:= {}
				Exit			
			Endif
		Next nI
	EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa840Ser  ณ Autor ณ Gilson da Silva       ณ Data ณ28.05.03  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Achoice para numero e serie do Recibo vindo do SX5         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa840Ser(cSerie, cRecibo)

	Local aSerRec	:= {}
	Local nOpcA		:= 0     
	Local cNewRec	:= '000001'
	Local aAreaSEL	:= {}
	
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	If DbSeek( xFilial("SX5")+"RN"+cSerie )
		aAdd(aSerRec, {Padr(X5_CHAVE, 3), StrZero(Val(X5Descri()), TamSX3("EL_RECIBO")[1])})
		cRecibo := aSerRec[1,2]
		cSerie  := aSerRec[1,1]
		nOpcA   := 1
	Else
		If Empty(cSerie)
			aAreaSEL	:=	SEL->(GetArea())
			SEL->(DbSetOrder(8))
			SEL->(MsSeek(xFilial()+cSerie+'zzzzzz'))
			SEL->(DbSkip(-1))
			If SEL->EL_FILIAL+SEL->EL_SERIE==xFilial('SEL')+cSerie
				cNewRec	:=	Soma1(SEL->EL_RECIBO)
			Endif	
			RestArea(aAreaSEL)
			RecLock('SX5',.T.)
			Replace X5_FILIAL		With xFilial('SX5')
			Replace X5_TABELA 	With 'RN'
			Replace X5_DESCRI  	With cNewRec
			Replace X5_DESCENG 	With cNewRec
			Replace X5_DESCSPA 	With cNewRec
			MsUnLock()
			AADD( aSerRec,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ),TamSX3("EL_RECIBO")[1] ) } )  
			cRecibo := aSerRec[1,2]
			cSerie  := aSerRec[1,1]
			nOpcA   := 1 
		Else
			MsgStop(STR0119)// "Serie invแlida"
			Return (.F.)
		Endif
	EnDIf

Return {cSerie, cRecibo}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณF840GrvTx   บAutor  ณCristiano Denardi   บ Data ณ22.01.2004 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณGrava taxa da Moeda em SEL para qdo existirem campos        บฑฑ
ฑฑบDesc.     ณcorrespondentes ( da moeda 2 ate n informada)               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840GrvTx( aTx )

	Local nTx := 0
	
	For nTx := 2 To Len(aTx) 
		If ( SEL->(FieldPos("EL_TXMOE"+StrZero(nTx,2))) > 0 )
			SEL->&("EL_TXMOE"+StrZero(nTx,2)) := aTx[nTx]
		Endif
	Next nTx

Return NIL
///////////////////////////////////////////////////////
//                                                   //
//    |  |       ---------------------------------   //
//   -    -      DAQUI PARA BAIXO ESTARAO            //
//   \    /      OS FONTES DO CONFIGURADOR           //
//    \  /       DOS CAMPOS DO BROWSE PARA RECIBOS   //
//     \/                                            //
//                                                   //
///////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840Prof()  ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna Array contendo lista de campos gravados no Profile ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION A840Prof(cAlias)

Local aCposProfile 	:= {}
Local nTamLin		:= 10
Local cMemoPro		:= ""
Local nTamMemo		:= 0
Local nA			:= 0
Local cAliasBM		:= ""
Local aCpoMemo          := {}
	
cMemoPro := RetProfDef(cUserName,cFunName,cProfChave,cAlias)
nTamMemo := MLCount(cMemoPro,nTamLin)  
	
For nA := 1 to nTamMemo
	Aadd( aCposProfile, Alltrim(MemoLine(cMemoPro,nTamLin,nA)) )
Next nA
	
///////////////////////////////////////////////////
	// Rastreia aCpos para retirar campos do tipo MEMO
	// Necessario ser desta forma, devido ao ponto de
	//   entrada do usuario, que pode criar a aCols com
	//   campo tipo MEMO
cAliasBM := Alias()  
DbSelectArea( "SX3" )
DbSetOrder(2)
For nA := 1 to Len(aCposProfile)
	DbSeek( Alltrim(aCposProfile[nA]) )
	If ( X3_TIPO = "M" )
		AADD(aCpoMemo,nA)
	Endif
Next nA
SX3->(DbSetOrder(1))
DbSelectArea( cAliasBM )          

// Borrar campos del tipo Memo do Array 
If Len(aCpoMemo) > 0
      For nA := 1 To Len(aCpoMemo)
            Adel( aCposProfile, aCpoMemo[nA] )
            Asize( aCposProfile, Len(aCposProfile)-1 )
      Next nA
EndIf

RETURN( aCposProfile )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFG()    ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Configurador da ordem das colunas de recibo no Profile     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION A840CFG()

	Local oFolder, oGet1, oGet2
	Local aTitles 		:= {STR0018,STR0120} //"Cliente"###"Titulo"
	Local aPages  		:= Aclone(aTitles)
	Local aTamFolder		:= {}
	Local lConfirm		:= .F.
	Local aButtons		:= {}
	Local cAlAnt			:= Alias()
	Local lPanelFin := IsPanelFin()
	
	Private oDlg
	Private lCancel			:= .F.
	Private cFunName  		:= "FINA840"
	Private cProfChave		:= "FINA84001"
	Private cAliasSA1 		:= "SA1"
	Private cAliasSE1 		:= "SE1"
	Private cAlias			:= ""
	Private aCposCliente	:= {}
	Private aCposTMPCli		:= {}
	Private aCposTitulo		:= {}
	Private aCposTMPTit		:= {}
	Private aCols           := {}
	Private aHeader 		:= {}
	
	// Monta aHeader
	Aadd(aHeader,{""     ,"CHECKBOL","@BMP"    , 07, 00, , ,"C", ,"V", , , , "V", , , })
	Aadd(aHeader,{""     ,"CHECK"   ,"@BMP"    , 05, 00, , ,"C", ,"V", , , , "V", , , })
	Aadd(aHeader,{STR0137,"ORDEM"   ,"@E 9,999", 04, 00, , ,"N", ,"V", , , , "A", , , }) //"Ordem"
	Aadd(aHeader,{STR0138,"NOMCAMPO", ""       , 12, 00, , ,"C", ,"V", , , , "V", , , }) //"Nome Campo"
	Aadd(aHeader,{STR0139,"CAMPO"   , ""       , 10, 00, , ,"C", ,"V", , , , "V", , , }) //"Campo"
	
	// Campos Obrigatorios
	aCposTMPCli := { 	"A1_COD"    , "A1_LOJA"   , "A1_NOME"   , "A1_CGC"   , "A1_CONTATO",	;
	"A1_TEL"    , "A1_NATUREZ"                								;
	}
	aCposTMPTit := {	"E1_PREFIXO", "E1_NUM"	  , "E1_PARCELA","E1_TIPO"	 , "E1_EMISSAO", 	;
	"E1_MOEDA"	, "E1_VALOR"  , "E1_SALDO"	,"E1_DESCONT", "E1_JUROS"  , 	;
	"E1_MULTA" 	, "E1_VENCREA"}
	
	// Tela
DEFINE MSDIALOG oDlg TITLE STR0121 FROM 0,0 TO 385,620 OF oMainWnd PIXEL //"Configurador de ordem e campos para browse de Recibos"
	
	aTamFolder := {040,002,oDlg:nHeight-115,150}
	oFolder    := TFolder():New(aTamFolder[1],aTamFolder[2],aTitles,aPages,oDlg,,,,.T.,.F.,aTamFolder[3],aTamFolder[4])	
	oFolder:bSetOption :={|nAt| nGot:=nAt,A840CFGfol(@oFolder,nGot,@oGet1,@oGet2) }
	
	// Alimenta pastas com os campos conforme Profile do Usuario
	A840CFGCo(cAliasSA1,cAliasSE1)
	
	// Monta Tela              
	nGetd := GD_UPDATE
	
	aCols :=  Aclone(aCposCliente)
	oGet1 := MsNewGetDados():New(0, 0, oFolder:aDialogs[1]:nClientHeight/2, oFolder:aDialogs[1]:nClientWidth/2,nGetd,,,,,,9999,,,,oFolder:aDialogs[1],aHeader,aCols)       
	oGet1:oBrowse:bEditCol   := {|| A840CFGOrd(oGet1:oBrowse:nAt,@oGet1,.T.) }
	oGet1:oBrowse:blDblClick := {|| If( oGet1:oBrowse:nColPos == 3 , A840CFGOrd(oGet1:oBrowse:nAt,@oGet1,.F.), A840CFGbmp(oGet1:oBrowse:nAt,@oGet1) ) }
	
	aCols :=  Aclone(aCposTitulo)
	oGet2 := MsNewGetDados():New(0, 0, oFolder:aDialogs[2]:nClientHeight/2, oFolder:aDialogs[2]:nClientWidth/2,nGetd,,,,,,9999,,,,oFolder:aDialogs[2],aHeader,aCols)       
	oGet2:oBrowse:bEditCol   := {|| A840CFGOrd(oGet2:oBrowse:nAt,@oGet2,.T.) }
	oGet2:oBrowse:blDblClick := {|| If( oGet2:oBrowse:nColPos == 3 , A840CFGOrd(oGet2:oBrowse:nAt,@oGet2,.F.), A840CFGbmp(oGet2:oBrowse:nAt,@oGet2) ) }
	
	Do Case
		Case oFolder:aDialogs[1]:lVisible // Folder 1 Ativo (Cliente)
			aCols :=  Aclone(aCposCliente)
		Case oFolder:aDialogs[2]:lVisible // Folder 2 Ativo (Titulo)
			aCols :=  Aclone(aCposTitulo)
	Endcase
	
	// Botoes
	Aadd( aButtons, {"BMPINCLUIR",{ || A840CFGlst(@oFolder,@oGet1,@oGet2)		},STR0122,STR0146} ) //"Refaz lista de campos."###"Refaz"
	Aadd( aButtons, {"SDUPROP",{ || A840CFGleg()                        		},STR0129} ) //"Legenda"
	Aadd( aButtons, {"CHECKED"   ,{ || A840CFGsel(@oFolder,@oGet1,@oGet2,1)	},STR0135,STR0147} ) //"Todos campos selecionados"###"Td.Cp.Sel"
	Aadd( aButtons, {"UNCHECKED" ,{ || A840CFGsel(@oFolder,@oGet1,@oGet2,2)	},STR0136,STR0148} ) //"Todos campos nao selecionados"###"Td.Cp.N.Sel"
	
	If lPanelFin	
		ACTIVATE MSDIALOG oDlg ON INIT ( FAMYBAR( oDlg,{|| lConfirm:=.T.,oDlg:End()} , {|| If(MsgYesNo(STR0123),oDlg:End(),) },aButtons )) CENTERED //"Deseja cancelar?"
	Else
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg,{|| lConfirm:=.T.,oDlg:End()} , {|| If(MsgYesNo(STR0123),oDlg:End(),) }, , aButtons )) CENTERED //"Deseja cancelar?"
	Endif
	
	// Grava em Profile
	If lConfirm
	A840CFGgrv(oGet1,oGet2)
	EndIf
	
	DbSelectArea( cAlAnt )

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGCo()  ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica Profile e monta lista de campos                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION A840CFGCo(cAliasSA1,cAliasSE1)

	Local aCposTMP 	:= {} // Campos obrigatorios, usuario nao pode deselecionar
	
	// CLIENTE
	aCposTMP := Aclone( aCposTMPCli )
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSA1 )
		// Resgata a lista do profile e mescla com campos de SX3
		A840CFGPR(cAliasSA1,aCposTMP,"aCposCliente")
	Else                
		// Cria Array com Lista nova de campos para Cliente
		A840CFGNR(cAliasSA1,aCposTMP,"aCposCliente")
	Endif
	
	// TITULO
	aCposTMP := Aclone( aCposTMPTit )
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSE1 )
		// Resgata a lista do profile e mescla com campos de SX3
		A840CFGPR(cAliasSE1,aCposTMP,"aCposTitulo")
	Else                
		// Cria Array com Lista nova de campos para Titulo
		A840CFGNR(cAliasSE1,aCposTMP,"aCposTitulo")
	Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGPR() ณAutor ณCristiano Denardi      ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Resgata a lista do profile e mescla com campos de SX3      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION A840CFGPR(c_alias,aCposTMP,cNomeArray)

	Local aCposPro	:= {} // Campos que estao gravados no Profile
	Local nTamLin	:= 10
	Local cAliasAnt := Alias()
	Local nOrdem	:= 0
	Local lEnable	:= .F.
	Local cBMP      := ""
	Local cBMPBOL   := ""
	Local cMemoProf	:= ""
	Local nTamMemo	:= 0
	Local nA		:= 0
	
	cMemoProf := RetProfDef(cUserName,cFunName,cProfChave,c_alias)
	nTamMemo  := MLCount(cMemoProf,nTamLin)  
	
	// Cria aCposPro
	For nA := 1 to nTamMemo
		Aadd( aCposPro, Alltrim(MemoLine(cMemoProf,nTamLin,nA)) )
	Next nA
	
	// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(2) // X3_CAMPO
	
	// Rastreia aCposPro
	For nA := 1 to nTamMemo
		nOrdem++
		
		DbSeek( Alltrim(aCposPro[nA]), .F. )	
		
		lEnable := If( (AScan(aCposTMP,Alltrim(aCposPro[nA]))==0), .T., .F. ) 
		
		If lEnable      
			cBMPBOL	:= "ENABLE"
			cBMP	:= "LBTIK"
		Else
			cBMPBOL	:= "DISABLE"
			cBMP	:= "LBTIK"
		Endif
		
		Aadd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
	Next nA       
	
	cBMPBOL	:= "ENABLE"
	cBMP	:= "LBNO"
	
	// Mescla com campos do SX3
	DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias) 
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .And. ( AScan(aCposPro,Alltrim(X3_CAMPO))==0 )
			nOrdem++
			AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	Enddo
	
	DbSelectArea(cAliasAnt)

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGNR()  ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria a lista nova de campos                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION A840CFGNR(c_alias,aCposTMP,cNomeArray)

	Local cAliasAnt := Alias()
	Local nOrdem	:= 0
	Local lEnable	:= .F.
	Local cBMP      := ""
	
	// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL )
			nOrdem++
			
			lEnable := IIf((AScan(aCposTMP,Alltrim(X3_CAMPO))==0),.T.,.F.) 
			
			cBMP	:= "LBTIK"
			
			If lEnable      
				cBMPBOL	:= "ENABLE"
			Else
				cBMPBOL	:= "DISABLE"
			EndIf
			
			AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	EndDo
	
	DbSelectArea(cAliasAnt)

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGlst() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Desconsidera a lista atual e restaura a config. inicial    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION A840CFGlst(oFolder,oGet1,oGet2)

	Local aCposTMP		:= {}
	Local cNomeArray	:= ""
	Local c_Alias		:= ""
	Local cAliasAnt 	:= Alias()
	Local nOrdem		:= 0
	Local lEnable		:= .F.
	Local cBMP      	:= ""
	Local nA			:= 0
	Local aFolders		:= {}
	Local lRefaz		:= .F.
	
	If MsgYesNo(STR0124) //"Deseja refazer a lista de campos para esta pasta?"
		lRefaz := .T.
	Endif
	
	If lRefaz
		// Pastas
		Aadd(aFolders, {"SA1","aCposCliente","aCposTMPCli"} )
		Aadd(aFolders, {"SE1","aCposTitulo" ,"aCposTMPTit"} )
		
		Do Case
			Case ( oFolder:aDialogs[1]:lVisible )
				aCposCliente 	:= {}
				nA 				:= 1
			Case ( oFolder:aDialogs[2]:lVisible )
				aCposTitulo := {}
				nA 			:= 2
		EndCase
		
		c_Alias		:= aFolders[nA][1]
		cNomeArray	:= aFolders[nA][2]
		aCposTMP 	:= Aclone( &(aFolders[nA][3]) )
		
		// Pega a Lista de Campos de SX3
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(c_Alias,.F.)
		Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
			If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL )
				nOrdem++
			
				lEnable := IIf((AScan(aCposTMP,Alltrim(X3_CAMPO))==0),.T.,.F.) 
		
				If lEnable      
					cBMPBOL	:= "ENABLE"
					cBMP	:= "LBTIK"
				Else
					cBMPBOL	:= "DISABLE"
					cBMP	:= "LBTIK"
				Endif
		
				AAdd(&cNomeArray,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
			Endif
			DbSkip()
		EndDo
		
		Do Case
			Case ( oFolder:aDialogs[1]:lVisible )
				oGet1:aCols := Aclone( aCposCliente )
				oGet1:oBrowse:Refresh()
				oGet1:ForceRefresh()
			Case ( oFolder:aDialogs[2]:lVisible )
				oGet2:aCols := Aclone( aCposTitulo )
				oGet2:oBrowse:Refresh()
				oGet2:ForceRefresh()
		EndCase
		
		oDlg:Refresh()
		DbSelectArea(cAliasAnt)
	
	EndIf

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGbmp() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Efetua a troca do BMP de aCOls                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840CFGbmp(nLin,oGet)

	If ( oGet:aCols[nLin][1] = "ENABLE" )
		If ( oGet:aCols[nLin][2] = "LBTIK" )
			oGet:aCols[nLin][2] := "LBNO"		
		ElseIf ( oGet:aCols[nLin][2] = "LBNO" )
			oGet:aCols[nLin][2] := "LBTIK"
		Endif
	Endif

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGsel() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Troca a selecao de campos para NAO SELECIONADOS            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840CFGsel(oFolder,oGet1,oGet2,nOpcBMP)

	Local nFor 	:= 0
	Local nA	:= 0
	
	Do Case
		Case ( oFolder:aDialogs[1]:lVisible )
			nFor := Len(oGet1:aCols)
			For nA := 1 to nFor
				If ( oGet1:aCols[nA][1] = "ENABLE" )
					If ( nOpcBMP = 1 )
						oGet1:aCols[nA][2] := "LBTIK"
					ElseIf ( nOpcBMP = 2 )
						oGet1:aCols[nA][2] := "LBNO"
					Endif
				Endif
			Next nA
		Case ( oFolder:aDialogs[2]:lVisible )
			nFor := Len(oGet2:aCols)
			For nA := 1 to nFor
				If ( oGet2:aCols[nA][1] == "ENABLE" )
					If ( nOpcBMP = 1 )
						oGet2:aCols[nA][2] := "LBTIK"
					ElseIf ( nOpcBMP = 2 )
						oGet2:aCols[nA][2] := "LBNO"
					Endif		
				Endif
			Next nA
	EndCase

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGOrd() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Organiza aCols qdo e trocado a ordem de um campo           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840CFGOrd(nLin,oGet,lVld)

	Local nPosNovo 	:= 0
	Local nValNovo 	:= 0
	Local nValAnti 	:= 0
	Local nValMaior := Len(oGet:aCols)
	Local nFor		:= 0
	Local nA		:= 0
	Local nOrdem	:= 0
	
	If lVld
		nValNovo := M->ORDEM	
		nValAnti := nLin
	Else
		nValAnti := oGet:aCols[nLin][3] 
		oGet:EditCell()
		nValNovo := oGet:aCols[nLin][3]
	Endif
	
	If ( nValNovo <= nValMaior ) .And. ( nValNovo > 0 ) 
		// Somente processa se valor for trocado
		If ( nValAnti <> nValNovo )
			If lVld
				nPosNovo := nValNovo
			Else
				nPosNovo := Ascan( oGet:aCols, {|aVal| aVal[3] == nValNovo } )
			Endif
	
			If ( nLin < nPosNovo )
				nFor := nPosNovo
				nLin++
				For nA := nLin to nFor
					nOrdem := nA
					nOrdem--
					oGet:aCols[nA][3] := nOrdem
				Next nA
			Else
				nFor := ( (nLin-nPosNovo) + nPosNovo ) - 1
				For nA := nPosNovo to nFor
					nOrdem := nA
					nOrdem++
					oGet:aCols[nA][3] := nOrdem
				Next nA
			Endif
			oGet:aCols := Asort( oGet:aCols,,, { |x,y| x[3] < y[3] } )
		Endif
	Else
		oGet:aCols[nLin][3] := nValAnti
		If ( nValNovo <= 0 )
			Alert(STR0125) //"Valor nao pode ser menor ou igual a Zero"
		Else
			Alert(STR0126) //"Valor nao pode ser maior do que o numero maximo de campos"
		Endif
	Endif   
	
	oGet:oBrowse:Refresh()
	oGet:ForceRefresh()
	oDlg:Refresh()

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGgrv() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava lista de campos no profile do usuario corrente	      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840CFGgrv(oGet1,oGet2)

	Local cList := ""
	Local nA	:= 0
	
	// Atualiza Arrays auxiliares
	aCposCliente := Aclone(oGet1:aCols)
	aCposTitulo  := Aclone(oGet2:aCols)
	
	// Grava Cliente
	cList := ""
	For nA := 1 to Len(aCposCliente)
		If ( aCposCliente[nA][2] == "LBTIK" )
			cList := cList + Alltrim( aCposCliente[nA][5] ) + _PL_
		Endif
	Next nA
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSA1 )
		WriteProfDef( cUserName, cFunName, cProfChave, cAliasSA1, cUserName, cFunName, cProfChave, cAliasSA1, cList )
	Else                
		WriteNewProf( cUserName, cFunName, cProfChave, cAliasSA1, cList )
	Endif     
	
	// Grava Titulo
	cList := ""
	For nA := 1 to Len(aCposTitulo)
		If ( aCposTitulo[nA][2] == "LBTIK" )
			cList := cList + Alltrim( aCposTitulo[nA][5] ) + _PL_
		Endif
	Next nA
	If FindProfDef( cUserName, cFunName, cProfChave, cAliasSE1 )
		WriteProfDef( cUserName, cFunName, cProfChave, cAliasSE1, cUserName, cFunName, cProfChave, cAliasSE1, cList )
	Else                
		WriteNewProf( cUserName, cFunName, cProfChave, cAliasSE1, cList )
	Endif
	
	MsgInfo(STR0127) //"As alteracoes gravadas, so serao efetivadas na proxima abertura da rotina de Recibos!"

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGfol() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Trata a troca de folder, fazendo a troca do valor de aCols ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A840CFGfol(oFolder,nGot,oGet1,oGet2)
	/////////////////////////////////////////////////////////////////
	//   nGot							-> Pasta que foi clicada   //
	//   oFolder:aDialogs[n]:lVisible 	-> Ultima pasta ativa      //
	/////////////////////////////////////////////////////////////////
	
	// Guarda valor de Arrays de auxilio do aCols
	Do Case
		Case ( oFolder:aDialogs[1]:lVisible )
			aCposCliente := Aclone(oGet1:aCols)
		Case ( oFolder:aDialogs[2]:lVisible )
			aCposTitulo := Aclone(oGet2:aCols)
	EndCase
	
	// Ajusta aCols
	Do Case
		Case ( nGot = 1 )
			oGet1:aCols := Aclone(aCposCliente)
		Case ( nGot = 2 )
			oGet2:aCols := Aclone(aCposTitulo)
	EndCase

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840CFGleg() ณAutor ณCristiano Denardi     ณDataณ 19.08.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Legenda                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function A840CFGleg()

	BrwLegenda(STR0129, STR0130,{	{"DISABLE", STR0131} ,; //"Legenda"###"Status"###" Campo obrigatorio"
		{"ENABLE" , STR0132} ,; //" Campo opcional"
		{""		  , " ------------------------ "} ,;
		{"LBTIK"  , STR0133} ,; //" Selecionado"
		{"LBNO"	  , STR0134}  ; //" Nao selecionado"
		} )

RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F840Get      ณAutor ณJulio Ceasr           ณDataณ 08.07.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria um get com os parametros informados.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F840Get(aInfGet,uVarRet,oVarRet)

	// Reinicializa a variavel.
	If aInfGet[9] <> Nil
		uVarRet := aInfGet[9]
	EndIf
	
	@ aInfGet[1],aInfGet[2] MSGET oVarRet Var uVarRet SIZE aInfGet[3],aInfGet[4] OF &(aInfGet[5]) PIXEL Valid &(aInfGet[6]) When &(aInfGet[7]) Picture aInfGet[8] HasButton

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Fa840Ret()   ณAutor ณSabrina Passini SoaresณDataณ 17.06.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que verifica se ha retencoes recebidas e chama a    ณฑฑ
ฑฑณ          ณ montagem do panel correspondente para rateio dos valores   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840Ret()

	Local lRet   	:= .T. 
	Local nI, nX	:= 1                       
	Local nPos	 	:= 0
	Local nNumRet	:= 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ StrTokArr: Esta funcao pega uma string com separadores e faz virar um array ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aDesc := IiF (cPaisLoc $ "ARG|COS",StrTokArr(FA840TpTit(),";"), StrTokArr(oGetsel:aInfo[AScan(aCposSEL,"EL_TIPODOC")][2], ';'))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega array com os titulos (NF) selecionados para distribuir as retencoes ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Local nPosPref  := Ascan( aCposSE1, "E1_PREFIXO")
	Local nPosNum   := Ascan( aCposSE1, "E1_NUM")
	Local nPosParc  := Ascan( aCposSE1, "E1_PARCELA")
	Local nPosTipo  := Ascan( aCposSE1, "E1_TIPO")
	Local lRatImp	:= GetMv("MV_RATIMP",.F.,"0")=="0"
	Local aCabRet   := {}
	Local aRetTmp   := {} 
	
	Local nPosTrans := AScan(aHeader,{|x|Alltrim(x[2])=="EL_TRANSIT"})
	Local lExRateio	:= .T.  
	
	Private aLinTit := {}
	aLinRet :={}
	
	Posicione("SX3",2,"E1_PREFIXO","X3_TITULO")
	Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
	Posicione("SX3",2,"E1_NUM","X3_TITULO")
	Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
	Posicione("SX3",2,"E1_PARCELA","X3_TITULO")
	Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
	Posicione("SX3",2,"E1_TIPO","X3_TITULO")
	Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
	Posicione("SX3",2,"E1_VALOR","X3_TITULO")
	Aadd( aCabRet, { SX3->(X3Titulo()), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL} )
	
	For nX:=1 To Len( aLinSE1 )
		If aLinSE1[nX][1]== 1 // Titulo selecionado
			If cPaisLoc $ "ARG|COS" .Or. (!Alltrim(aLinSE1[nX][nPosTipo]) $ MV_CRNEG .Or. Alltrim(aLinSE1[nX][nPosTipo])=="CC")
				Aadd( aLinTit, { aLinSE1[nX][nPosPref], aLinSE1[nX][nPosNum], aLinSE1[nX][nPosParc], ;
				aLinSE1[nX][nPosTipo], 0, "", "" } )   
			EndIf	   
		EndIf
	Next
	
	For nI:=1 To Len(aCols)
		lExRateio := .T. 
		If nPosTrans > 0 
			If aCols[nI][nPosTrans] != "2"
				lExRateio := .F.
			EndIf
		EndIf  
	
		If lExRateio .and. ((cPaisLoc $ "ARG|COS" .And. aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ (IIF(cPaisLoc == "ARG","RB|RS|RL|RI|RG|RM","RB|RS|RL|RI|RG"))	);
			.Or. (cPaisLoc == "PER" .And. ( aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RI' )) )
			If Len(aLinTit) > 0 .Or. (cPaisLoc $ "ARG|COS" .And.aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ (IIF(cPaisLoc == "ARG","RB|RI|RS|RG|RM","RB|RI|RS|RG")) )
				nNumRet++
				If Len( aLinRet ) >= nNumRet
					aRetTmp := aClone(aLinRet[nNumRet]) 
				Else      
				aRetTmp := aClone(aLinTit)          
				For nX := 1 to Len( aLinTit)
					aRetTmp[nX][6] := aCols[nI][AScan(aCposSEL,"EL_NUMERO")]  //numero da retencao (nrocert)
					aRetTmp[nX][7] := aCols[nI][AScan(aCposSEL,"EL_TIPODOC")]  //tipo da retencao
					If Len(aLinTit) == 1 .And. (cPaisLoc == "PER" .Or. (cPaisLoc $ "ARG|COS" .And. aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ 'RS|RL' ))
						aRetTmp[nX][5]:= aCols[nI][AScan(aCposSEL,"EL_VALOR")]
					EndIf			      	
				Next nX
			EndIf
			If cPaisLoc $ "ARG|COS"
				nPos := Ascan( aDesc, AllTrim(aCols[nI][AScan(aCposSEL,"EL_TIPO")])+'=' )
			Else
				nPos := Ascan( aDesc, AllTrim(aCols[nI][AScan(aCposSEL,"EL_TIPODOC")])+'=' )
			EndIf
			If Len(aLinTit)> 1  .Or. (cPaisLoc $ "ARG|COS" .And. ((aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ (IIF(cPaisLoc == "ARG","RB|RI|RS|RG|RM","RB|RI|RS|RG")) )))
				//Exibe a tela de rateio caso o parametro MV_RATIMP estiver configurado como "0"
				If cPaisLoc $ "ARG|COS"
					If (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ (IIF(cPaisLoc == "ARG","RB|RI|RS|RG|RM","RB|RI|RS|RG")))  
						lRet := MostraRets( Subs( aDesc[nPos], At('=', aDesc[nPos])+1 ), aCols[nI][AScan(aCposSEL,"EL_VALOR")], aCols[nI][AScan(aCposSEL,"EL_NUMERO")], aCabRet, @aRetTmp,aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] ,lRatImp)
					Else 
						lRet := .T.
					Endif
				Elseif cPaisLoc == "PER"
					If (aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] $ "RI")
						lRet := MostraRets( Subs( aDesc[nPos], At('=', aDesc[nPos])+1 ), aCols[nI][AScan(aCposSEL,"EL_VALOR")], aCols[nI][AScan(aCposSEL,"EL_NUMERO")], aCabRet, @aRetTmp,aCols[nI][AScan(aCposSEL,"EL_TIPODOC")] )
					Else 
						lRet := .T.
					Endif
	
				Endif
			Else
				lRet := .T.
			Endif
	
			If Len( aLinRet ) >= nNumRet
		    	aLinRet[nNumRet] := AClone(aRetTmp)
			Else
				Aadd( aLinRet, ACLone(aRetTmp)  )
			EndIf
	
			If ( ! lRet )
				Exit
			EndIf   
		Else
			If !lRotAuto
				Aviso(STR0149,STR0150,{STR0151}) // exibe mensagem que ha retencoes, porem nao foi selecionado nenhum item
			Else
				cTxtRotAut += STR0149 + " " + STR0150 + " " + STR0151  +" "+ CRLF // // exibe mensagem que ha retencoes, porem nao foi selecionado nenhum item
				lMsErroAuto := .T.
			EndIf
			lRet := .F.
			Exit
		EndIf
	EndIf
	Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MostraRets() ณAutor ณSabrina Passini SoaresณDataณ 18.06.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que mostra os panel para digitacao dos rateios das  ณฑฑ
ฑฑณ          ณ retencoes recebidos pelos titulos selecionados             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MostraRets( cRetText, nRetVal, cRetNum, aCab, aItRet,cRet ,lRatImp, lObj)
	
	Local lRet := .T.
	Local oDlgRet
	Local oPanel
	Local oPTop
	Local oPCenter
	Local oPBottom
	Local oGTop
	Local oGCenter
	Local oPBrw
	Local oGBottom
	Local oBtnok
	Local oBrw
	Local oBtncancel
	Local oRet
	Local oRetVal   
	Local oRetNum 
	Local oRetPre
	Local cPict := aCab[5][2]
	Local nI
	Local aHeaderRet	:=	{}
	Local aColsRet:=	{}
	Local nX
	Local nTipo
	Local aDms		:= {}
	Private oGetD 
	Default lObj	:= .T. 
	
	
	If lObj
		oDlgRecibo:readClientCoors(.T.)
		DEFINE MSDIALOG oDlgRet TITLE '' FROM (oDlgRecibo:nTop+195), (oDlgRecibo:nLeft+210) TO oDlgRecibo:nBottom-30, oDlgRecibo:nRight-11 OF oDlgRecibo STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
	Else
		aDms :=  FWGetDialogSize(oMainWnd)
		DEFINE MSDIALOG oDlgRet TITLE '' FROM (aDms[1]+195), (aDms[2]+210) TO aDms[3]-30, aDms[4]-11 OF oMainWnd /*STYLE nOR(WS_VISIBLE,WS_POPUP)*/ PIXEL
	EndIf
	DEFINE FONT oFnt NAME "Times New Roman" SIZE 7,15 
	DEFINE FONT oFntB NAME "Times New Roman" SIZE 7,15 BOLD
	
	oPanel:=TPanel():New(001,001,,oDlgRet,,,,,,232,162,.F.,.F.)
	oPanel:align:= CONTROL_ALIGN_ALLCLIENT
	oPanel:NCLRPANE:= RGB(233,233,233) //13165800
	
	oPTop:=TPanel():New(001,001,,oPanel,,,,,,200,040,.F.,.F.)
	oPTop:align:= CONTROL_ALIGN_TOP
	oPTop:NCLRPANE:= RGB(233,233,233) //13165800
	
	@ 003, 001 GROUP oGTop TO 113, 116 OF oPTop PIXEL 
	oGTop:align:= CONTROL_ALIGN_ALLCLIENT
	
	@ 010, 005 GET oRet VAR cRetText SIZE 080, 010 PIXEL OF oGTop READONLY 
	@ 010, 110 SAY STR0043 SIZE 080, 010 PIXEL OF oGTop   // Valor
	@ 010, 135 GET oRetVal VAR nRetVal SIZE 080, 010 PICTURE cPict PIXEL OF oGTop READONLY 
	@ 028, 005 SAY STR0137 FONT oFntB SIZE 080, 010 COLOR CLR_BLACK PIXEL OF oGTop   // Certificado Num
	@ 028, 065 SAY oRetNum VAR cRetNum FONT oFnt SIZE 080, 010 COLOR CLR_BLACK PIXEL OF oGTop   
	
	oPCenter:=TPanel():New(001,001,,oPanel,,,,,,200,050,.F.,.F.)
	oPCenter:align:= CONTROL_ALIGN_ALLCLIENT
	oPCenter:NCLRPANE:= RGB(233,233,233) //13165800
	
	@ 003, 001 GROUP oGCenter TO 113, 116 OF oPCenter PIXEL 
	oGCenter:align:= CONTROL_ALIGN_ALLCLIENT
	
	If (cPaisLoc $ "ARG|COS")
		If lRatImp
			If cRet $ "RB|RI"
				aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
			ElseIf	cRet $ "RM" .and. cPaisLoc $ "ARG" .and. SFE->(FieldPos("FE_RET_MUN"))>0
				aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_RET_MUN","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
			ElseIf	cRet $ "RG|RS"                                                                                               
				aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_CFO",Iif(cRet $ "RG","A2_AGREGAN","A2_CONCSUS"),"FE_VALBASE","FE_ALIQ","FE_RETENC"}
			EndIf	
		Else
			If cRet $ "RB|RI"
				aCamposGet	:=	{"FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
			ElseIf cRet == "RM" .and. cPaisLoc $ "ARG" .and. SFE->(FieldPos("FE_RET_MUN"))>0
				aCamposGet	:=	{"FE_EST","FE_RET_MUN","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
			ElseIf cRet $ "RS|RG" 
				aCamposGet	:=	{"FE_EST","FE_CFO",Iif(cRet $ "RG","A2_AGREGAN","A2_CONCSUS"),"FE_VALBASE","FE_ALIQ","FE_RETENC"}		
			EndIf
		Endif
		DbSelectArea("SX3")
		DbSetOrder(2)      
		For nX:=1 To Len(aCamposGet)
			DbSeek(aCamposGet[nX])
			AADD(aHeaderRet,{ TRIM(X3TITULO()), x3_campo, x3_picture,x3_tamanho, x3_decimal,x3_valid,x3_usado, x3_tipo, x3_F3, x3_context} )	
		Next
		If SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0 .and. cPaisLoc $ "ARG" 
			aAlterGDa := {"FE_VALBASE","FE_ALIQ","FE_CFO","FE_EST","FE_RETENC","A2_AGREGAN","A2_CONCSUS","FE_RET_MUN"}
		Else
			aAlterGDa := {"FE_VALBASE","FE_ALIQ","FE_CFO","FE_EST","FE_RETENC","A2_AGREGAN","A2_CONCSUS"}
		Endif
		nUsado	:=	Len(aCamposGet)
		aColsRet:={}
		If lRatImp
			For nX:= 1 To Len(aItRet)
				aadd(aColsRet,Array(nUsado+1))
				aColsRet[nX,nUsado+1]:=.F.
				aColsRet[nX,1]	:=	aItRet[nX,1]
				aColsRet[nX,2]	:=	aItRet[nX,2]
				aColsRet[nX,3]	:=	aItRet[nX,3]
				aColsRet[nX,4]	:=	aItRet[nX,4]
				For nI	:=	5 To Len(aHeaderRet)
					aColsRet[nX,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
				NExt
			Next
		Else
			aadd(aColsRet,Array(nUsado+1))
			aColsRet[1,nUsado+1]:=.F.
			For nI	:=	1 To Len(aHeaderRet)
				aColsRet[1,nI]	:=	Criavar(aHeaderRet[nI,2],.F.)
			NExt      
		Endif
		oGetD:= MsNewGetDados():New(0/*nSuperior*/,0/*nEsquerda*/,100/*nInferior*/,100/*nDireita*/, GD_UPDATE,;
		"AllwaysTrue()"/*cLinOk*/,"AllwaysTrue()"/*cTudoOk*/,/*cIniCpos*/,aAlterGDa,/*nFreeze*/,/*nMax*/,IIf(lRatImp,".F.",".T.")+IIF(cRet $ 'RM' .and. cPaisLoc == 'ARG','.Or. A840FillC(oGetd,"RM")','.Or. A840FillC(oGetd,"")') /*cFieldOk*/, /*cSuperDel*/,;
		/*cDelOk*/, oPCenter, aHeaderRet, aColsRet)
		oGetD:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT	 
		nTipo	:=	2
	Else     
		oBrw := TcBrowse():New(01,01,500,600,,,,oPCenter,,,,,,,,,,,,.F.,,.T.,,.F.,,)
		oBrw:Align 	:= CONTROL_ALIGN_ALLCLIENT	 
		oBrw:bLDblClick:= { || DblClickBrow(oBrw, aItRet,,, cPict) }
		oBrw:SetArray(aItRet)
		
		oBrw:AddColumn(TCColumn():New(aCab[1][1],{|| aItRet[oBrw:nAt,1] }      ,,,,"LEFT",CalcFieldSize('C',aCab[1,3],aCab[1,4],aCab[1,2],aCab[1,1]),.F.,.F.,,,,.F.,)) 
		oBrw:AddColumn(TCColumn():New(aCab[2][1],{|| aItRet[oBrw:nAt,2] }      ,,,,"LEFT",CalcFieldSize('C',aCab[2,3],aCab[2,4],aCab[2,2],aCab[2,1]),.F.,.F.,,,,.F.,))
		oBrw:AddColumn(TCColumn():New(aCab[3][1],{|| aItRet[oBrw:nAt,3] }      ,,,,"LEFT",CalcFieldSize('C',aCab[3,3],aCab[3,4],aCab[3,2],aCab[3,1]),.F.,.F.,,,,.F.,))  
		oBrw:AddColumn(TCColumn():New(aCab[4][1],{|| aItRet[oBrw:nAt,4] }      ,,,,"LEFT",CalcFieldSize('C',aCab[4,3],aCab[4,4],aCab[4,2],aCab[4,1]),.F.,.F.,,,,.F.,)) 
		oBrw:AddColumn(TCColumn():New(aCab[5][1],{|| Transform(aItRet[oBrw:nAt,5], cPict) },,,,"LEFT",CalcFieldSize('C',aCab[5,3],aCab[5,4],aCab[5,2],aCab[5,1]),.F.,.F.,,,,.F.,)) 
		nTipo	:=	1
	Endif
		
	oPBottom:=TPanel():New(001,001,,oPanel,,,,,,200,020,.F.,.F.)
	oPBottom:align:= CONTROL_ALIGN_BOTTOM
	oPBottom:NCLRPANE:= RGB(233,233,233) //13165800
	
	DEFINE SBUTTON oBtnOk 	  FROM 005,088 TYPE 1 ENABLE OF oPBottom ACTION ( If ( A87VldRet(aItRet, nRetVal,nTipo,oGetd, lRatImp), (lRet := .T.,If(cRet $(IIF(cPaisLoc == "ARG","RB|RI|RS|RG|RM","RB|RI|RS|RG")) , aItRet	:=	aClone(oGetD:aCols),Nil), oDlgRet:End()),.F.) )  
	DEFINE SBUTTON oBtnCancel FROM 005,121 TYPE 2 ENABLE OF oPBottom ACTION (lRet := .F., oDlgRet:End()) 
	
	ACTIVATE MSDIALOG oDlgRet
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDblClickBrow  บAutor  ณMicrosiga       บ Data ณ  03/24/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DblClickBrow(oBrw, aIt, nRow, nCol, cPict)
	If ( oBrw:ColPos() == 5 )
		lEditCell(aIt, oBrw, cPict, nCol)
	EndIf       
Return   

//----
Static Function A87VldRet( aItems, nRetVal,nTipo,oGetd,aCabRet,nMoeda,cTipo)

	Local lRet 		:= .T.
	Local nI   		:= 1
	Local nTotal	:= 0
	Local nPosRet	:= 0
	Local nPosCFO	:= 0
	Local nPosEst	:= 0
	Local nPosAlq	:= 0
	Local nPosBas	:= 0
	Local nPosTipo	:= 0
	Local nPosGan	:= 0
	
	Default aCabRet	:= {}
	Default nMoeda	:= 1
	Default cTipo	:= ""
	
	If nTipo == 1 .And. !lRotAuto
		For nI := 1 To Len(aItems)
			nTotal := nTotal + aItems[nI][5]
		Next
	Else
		If lRotAuto
			nPosRet	:=	Ascan(aCabRet,"FE_RETENC")
			nPosTipo:=	Ascan(aCabRet,"E1_TIPO")
			nPosCFO	:=	Ascan(aCabRet,"FE_CFO")
			nPosEst	:=	Ascan(aCabRet,"FE_EST")
			nPosAlq	:=	Ascan(aCabRet,"FE_ALIQ")
			nPosBas	:=	Ascan(aCabRet,"FE_VALBASE")
			nPosGan :=	Ascan(aCabRet,"A2_AGREGAN")
		Else
			nPosRet	:=	GdFieldPos("FE_RETENC",oGetd:aHeader)
			nPosTipo:=	GdFieldPos("E1_TIPO",oGetd:aHeader)
			nPosCFO	:=	GdFieldPos("FE_CFO",oGetd:aHeader)
			nPosEst	:=	GdFieldPos("FE_EST",oGetd:aHeader)
			nPosAlq	:=	GdFieldPos("FE_ALIQ",oGetd:aHeader)
			nPosBas	:=	GdFieldPos("FE_VALBASE",oGetd:aHeader)
			nPosGan :=	GdFieldPos("A2_AGREGAN",oGetd:aHeader)
		Endif
		For nI:= 1 To If(lRotAuto,Len(aItems),Len(oGetd:aCols))
			If lRotAuto
				nTotal := nTotal + aItems[nI,nPosRet] * IIf(nPosTipo>0 .And. aItems[nI,nPosTipo]$MV_CRNEG+"|"+MVRECANT,-1,1)
				If aItems[nI,nPosRet] <> 0 .And. (Empty(aItems[nI,nPosCFO]) .Or. Empty(aItems[nI,nPosEST]).Or. empty(aItems[nI,nPosBas]).Or.empty(aItems[nI,nPosAlq]))
					Help("",1,"OBRIGAT")
					lRet	:=	.F.
					Exit
				Endif
				//Valida็ใo do campo de conceito de Ganancias
				If cTipo == "RG"
					If nPosGan > 0 .And. Empty(aItems[nI,nPosGan])
						Help("",1,"OBRIGAT")
						lRet	:=	.F.
						Exit
					EndIf
				Endif
			Else
				If !oGetd:aCols[nI,Len(oGetd:aCols[nI])]
					nTotal := nTotal + oGetd:aCols[nI,nPosRet] * IIf(nPosTipo>0 .And. oGetd:aCols[nI,nPosTipo]$MV_CRNEG+"|"+MVRECANT,-1,1)
					If oGetd:aCols[nI,nPosRet] <> 0 .And. ;
						(Empty(oGetd:aCols[nI,nPosCFO]) .Or. Empty(oGetd:aCols[nI,nPosEST]).Or. empty(oGetd:aCols[nI,nPosBas]).Or.empty(oGetd:aCols[nI,nPosAlq]))
					Help("",1,"OBRIGAT")
					lRet	:=	.F.
					Exit
					Endif
					//Valida็ใo do campo de conceito de Ganancias
					If nPosGan > 0 .And. Empty(oGetd:aCols[nI,nPosGan])
						Help("",1,"OBRIGAT")
						lRet	:=	.F.
						Exit
					EndIf
				Endif
			Endif
		Next
	Endif
	
	If lRet
		If lRotAuto
			If ( nTotal > nRetVal )
				cTxtRotAut += cTipo + " - " + STR0152 +" "+ CRLF// 'El valor digitado es mayor que el valor de la retenci๓n'
				lRet	:=	.F.
			ElseIf ( nTotal < nRetVal )
				cTxtRotAut += cTipo + " - " + STR0153 +" "+ CRLF// 'El valor digitado es menor que el valor de la retenci๓n'
				lRet	:=	.F.
			EndIf
		Else
			If ( Round(nTotal,MsDecimais(oCBMOed:nAt)) > nRetVal )
				Aviso(STR0149,STR0152,{STR0151}) //'O valor digitado e maior que o valor da retencao'
				lRet	:=	.F.
			ElseIf ( Round(nTotal,MsDecimais(oCBMOed:nAt)) < nRetVal )
				Aviso(STR0149,STR0153,{STR0151})//'O valor digitado e menor que o valor da retencao'
				lRet	:=	.F.
			EndIf
		Endif
	Endif
	
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa840GrvIVA() ณ Autor ณ Paulo Augusto         ณ Data ณ 20/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Gravacao dos campos do Iva para o Mexico                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaXE   ณ Fa840GrvIVA()              								      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ UsO      ณ FINA87a		              								      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


Static Function Fa840GrvIVA()

	Local aArea      := GetArea()
	LOCAL aAreaSE1   := SE1->( GetArea() )
	LOCAL _ValorBx1  := 0
	Local _ValorBx2  := 0
	Local _ValorBx3  := 0
	Local _ValorBx4  := 0
	Local _ValorBx5  := 0
	Local _ValorBx6  := 0
	Local _PerBx     := 0
	Local _PerDesc   := 0
	Local _ValorDc1  := 0
	Local _ValorDc2  := 0
	Local _ValorDc3  := 0
	Local _ValorDc4  := 0
	Local _ValorDc5  := 0
	Local _ValorDc6  := 0   
	LOCAL _BaseBx1  := 0
	Local _BaseBx2  := 0
	Local _BaseBx3  := 0
	Local _BaseBx4  := 0
	Local _BaseBx5  := 0
	Local _BaseBx6  := 0
	LOCAL _AliqBx1  := 0
	Local _AliqBx2  := 0
	Local _AliqBx3  := 0
	Local _AliqBx4  := 0
	Local _AliqBx5  := 0
	Local _AliqBx6  := 0 

	Local aGrvSE   := {} //campos das tabelas SEL e SE5 a serem gravados.
	Local nX
	
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
	
	If Found()
	
		// Calcula el percentual de valor baixado
		_PerBx   := (SEL->EL_VALOR   * 100) / SE1->E1_VALOR
		
		// Calcula el percentual de valor de descuento 
		_PerDesc := (SEL->EL_DESCONT * 100) / SE1->E1_VALOR
		
		If SE1->E1_VALIMP1 > 0
			_ValorBx1 := SE1->E1_VALIMP1 * (_PerBx / 100)
			_AliqBx1 := SE1->E1_ALQIMP1
			_BaseBx1 := SE1->E1_BASIMP1 * (_PerBx / 100)
		EndIf
		If SE1->E1_VALIMP2 > 0
			_ValorBx2 := SE1->E1_VALIMP2 * (_PerBx / 100)
			_AliqBx2 := SE1->E1_ALQIMP2
			_BaseBx2 := SE1->E1_BASIMP2 * (_PerBx / 100)		
		EndIf
		If SE1->E1_VALIMP3 > 0
			_ValorBx3 := SE1->E1_VALIMP3 * (_PerBx / 100)
			_AliqBx3 := SE1->E1_ALQIMP3
			_BaseBx3 := SE1->E1_BASIMP3 * (_PerBx / 100)		
		EndIf
		If SE1->E1_VALIMP4 > 0
			_ValorBx4 := SE1->E1_VALIMP4 * (_PerBx / 100)
			_AliqBx4 := SE1->E1_ALQIMP4
			_BaseBx4 := SE1->E1_BASIMP4 * (_PerBx / 100)		
		EndIf
		If SE1->E1_VALIMP5 > 0
			_ValorBx5 := SE1->E1_VALIMP5 * (_PerBx / 100)
			_AliqBx5 := SE1->E1_ALQIMP5
			_BaseBx5 := SE1->E1_BASIMP5 * (_PerBx / 100)		
		EndIf
		If SE1->E1_VALIMP6 > 0
			_ValorBx6 := SE1->E1_VALIMP6 * (_PerBx / 100)
			_AliqBx6 := SE1->E1_ALQIMP6
			_BaseBx6 := SE1->E1_BASIMP6 * (_PerBx / 100)		
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP1 > 0
			_ValorDc1  := SE1->E1_VALIMP1 * (_PerDesc / 100)
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP2 > 0
			_ValorDc2  := SE1->E1_VALIMP2 * (_PerDesc / 100)
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP3 > 0
			_ValorDc3  := SE1->E1_VALIMP3 * (_PerDesc / 100)
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP4 > 0
			_ValorDc4  := SE1->E1_VALIMP4 * (_PerDesc / 100)
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP5 > 0
			_ValorDc5  := SE1->E1_VALIMP5 * (_PerDesc / 100)
		EndIf
		If SEL->EL_DESCONT > 0 .and. SE1->E1_VALIMP6 > 0
			_ValorDc6  := SE1->E1_VALIMP6 * (_PerDesc / 100)
		EndIf
		
		//Campos da tabela SEL
		//             Tab.      Campo        Valor
		Aadd(aGrvSE, {"SEL", "EL_VALIMP1", _ValorBx1})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP2", _ValorBx2})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP3", _ValorBx3})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP4", _ValorBx4})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP5", _ValorBx5})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP6", _ValorBx6})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP1", _BaseBx1})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP2", _BaseBx2})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP3", _BaseBx3})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP4", _BaseBx4})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP5", _BaseBx5})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP6", _BaseBx6})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP1", _AliqBx1})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP2", _AliqBx2})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP3", _AliqBx3})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP4", _AliqBx4})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP5", _AliqBx5})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP6", _AliqBx6})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES1", _ValorDc1})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES2", _ValorDc2})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES3", _ValorDc3})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES4", _ValorDc4})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES5", _ValorDc5})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES6", _ValorDc6})
		
		//Campos da tabela SE5 
		//             Tab.      Campo        Valor
		Aadd(aGrvSE, {"SE5", "E5_VALIMP1", _ValorBx1})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP2", _ValorBx2})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP3", _ValorBx3})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP4", _ValorBx4})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP5", _ValorBx5})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP6", _ValorBx6})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP1", _BaseBx1})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP2", _BaseBx2})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP3", _BaseBx3})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP4", _BaseBx4})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP5", _BaseBx5})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP6", _BaseBx6})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP1", _AliqBx1})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP2", _AliqBx2})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP3", _AliqBx3})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP4", _AliqBx4})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP5", _AliqBx5})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP6", _AliqBx6})
		
		//verifica se o campo existe e grava o valor na tabela
		For nX := 1 to Len(aGrvSE)
			//verifica se o campo existe.
			If (aGrvSE[nX,1])->(FieldPos(aGrvSE[nX,2]))> 0
				RecLock(aGrvSE[nX,1], .F.) 
				//atribui็ใo de valor no campo, caso o mesmo exista.
				(aGrvSE[nX,1])->&(aGrvSE[nX,2]) := aGrvSE[nX,3]
				MsUnlock()	
			Endif
		Next nX
	
	EndIf
	
	RestArea( aAreaSE1)
	RestArea( aArea )

RETURN ()


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFinA840T   ณ Autor ณ Marcelo Celi Marques ณ Data ณ 15.05.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada semi-automatica utilizado pelo gestor financeiro   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FinA840T(aParam)

	cRotinaExec := "FINA840"
	ReCreateBrow("SEL",FinWindow)      	
	FinA840()
	dbSelectArea("SEL")
	ReCreateBrow("SEL",FinWindow)      	
	dbSelectArea("SEL")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Fa840IGV()   ณAutor ณAna Paula             |    |03.11.09  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que verifica se ha retencoes recebidas e chama a    ณฑฑ
ฑฑณ          ณ montagem do panel correspondente para rateio dos valores   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa840IGV(cCliente,cLoja,cNumFatAut)
	
	Local lRet   	:= .T. 
	Local nI, nX	:= 1                       
	Local nPos	 	:= 0
	Local nNumRet	:= 0
	
	//Local aDesc  := StrTokArr(oGetsel:aInfo[AScan(aCposSEL,"EL_TIPODOC")][2], ';')
	Local nPosPref  := Ascan( aCposSE1, "E1_PREFIXO")
	Local nPosNum   := Ascan( aCposSE1, "E1_NUM")
	Local nPosParc  := Ascan( aCposSE1, "E1_PARCELA")
	Local nPosTipo  := Ascan( aCposSE1, "E1_TIPO")   
	Local nPosCli   := Ascan( aCposSE1, "E1_CLIENTE")   
	Local nPosLoja  := Ascan( aCposSE1, "E1_LOJA")   
	Local nPosValBx := Ascan( aCposSE1, "nBaixar")    
	Local nPosValTi := Ascan( aCposSE1, "E1_VALOR")
	Local nPosMoeda := AScan(aCposSE1,"E1_MOEDA")
	Local nPosVal	:= AScan(aCposSEL,"EL_VALOR") 
	Local lCalcPerc := .F.
	Local cAgente	:= GETMV("MV_AGENTE")
	Local aLinRet   := {}           
	Local aRetTmp   := {}  
	Local lPercRA	:= (GetNewPar("MV_PERRA","N") == "S")  
	Private aLinTit := {} 
	
	DEFAULT cNumFatAut := ""  
	
	If Subs(cAgente,1,1) == "N"  
		SA1->(DbSetOrder(1))
		If SA1->(MSSEEK(xFilial("SA1")+cCliente+cLoja)) .and. SA1->A1_AGENTE="2"
			lCalcPerc:=.T.
		EndIf
	EndIf
	
	For nX:=1 To Len( aLinSE1 )
		If aLinSE1[nX][1]== 1 // Titulo selecionado
			Aadd( aLinTit, { aLinSE1[nX][nPosPref], aLinSE1[nX][nPosNum], aLinSE1[nX][nPosCli], ;
			aLinSE1[nX][nPosTipo], aLinSE1[nX][nPosLoja], aLinSE1[nX][nPosValBx],aLinSE1[nX][nPosValTi],aLinSE1[nX][nPosMoeda] } ) 
		EndIf
	Next                      
	
	If Len(aLinTit)< 1 .And. lCalcPerc  .And. lPercRA .And. aCols[1][nPosVal]>0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?ฤฤฤฤฤฤฤฤฤฤฤฤฤ
		//ณ Montagem do PANEL de aliquotas para percep็ใoณ//
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
		oAPerc:=TPanel():New(84,00,,oDlgRecibo,,,,,,127,117,.F.,.T.)
		
		@ 003,001 GROUP oGrp6 TO 103, 123 LABEL OemToAnsi(STR0157) OF oAPerc  PIXEL  //"Percep็ใo IGV"
		
		
		@ 015,005 SAY OemToAnsi(STR0155) SIZE 60,07	OF oAPerc PIXEL //"Aliquota"
		@ 015,065 MSGET oAliqPerc Var nAliqPerc	SIZE 55,09 	OF oAPerc PIXEL Valid Fa840CalcPer(@nAliqPerc,.T.) Picture "@R 99.99" HASBUTTON
		
		@ 030,005 SAY OemToAnsi(STR0156) SIZE 60,07	OF oAPerc PIXEL //"Valor Percep็ใo"
		@ 030,065 MSGET oVarPer Var nValPerc SIZE 055,009 OF oAPerc READONLY PIXEL Picture PesqPict("SE1","E1_VALOR",18,nMoedDesc) HasButton	
		
		@ 045,005 SAY OemToAnsi( STR0045 ) SIZE 55, 07 OF oAPerc PIXEL  //"Valores expressos em "
		oCBMoed1:= TComboBox():New(045,065,bSEL,aNomeMoed,055,020,oAPerc, ,{|| nMoedDesc:=oCBMoed1:nAt,Fa840CalcPer(nAliqPerc,.T.)} , , , ,.T.,,,,)
		
		
		oAPerc:NCLRPANE:= RGB(233,233,233) ///13165800
		DEFINE SBUTTON FROM 104,063  TYPE 1  ACTION (F840PerOk(@cNumFatAut)) OF oAPerc When .T.
		DEFINE SBUTTON FROM 104,093  TYPE 2  ACTION (oAPerc:Hide(),oPanBut:lReadOnly:=.F.,oPanel[nPainel]:lReadOnly:=.F.) OF oAPerc When .T.
		
	Elseif lCalcPerc //Verifica percep็ใo de titulos gerados por faturamento
		Fa840CalcPer(nAliqPerc,.F.)
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ Fa840CalcPerบAutor  ณAna Paula           บ Data ณ  03/11/09 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณCalcula percep็ใo para RA e NFs geradas por faturamento(Peru)บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa840CalcPer(nAliqPerc,lPercAdi)

	Local nValRec:=0
	Local nX:=1
	Local nPosVal	:= AScan(aCposSEL,"EL_VALOR")
	Local nPosMoedTit	:= AScan(aCposSEL,"EL_MOEDA") 
	Local nBasePerc:=0 
	Local cNumTit
	Local cSerieTit
	Local cEmisTit
	Local cEspecie
	
	DEFAULT lPercAdi:= .F.
	
	aPerc:={}
	
	If lPercAdi    // Calcula percep็ใo para adiantamentos gerados direto por recibos  
		For nX:=1 to Len(aCols)
			nMoedaTit:=Val(aCols[nX][nPosMoedTit])
			nBasePerc:=nBasePerc+(aCols[nX][nPosVal]*(aTaxa[nMoedaTit]/aTaxa[nMoedDesc])*(1)) 
		Next 
		nValPerc := Round(nBasePerc*(nAliqPerc/100),MsDecimais(nMoedDesc))
		If nValPerc > 0 
			lTitAd := .T. // Determina que ้ adiantamento
			Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,,,,cDocCred,lTitAd})	
		EndIf
	Else    // Verifica a percep็ใo calculada na emissใo da nota
		aArea:=GetArea()
		nValPerc:=0
		For nX:=1 to Len(aLinTit)
			If !aLinTit[nX][4] $(MVRECANT+"/"+MV_CRNEG)
				// Verifica a percep็ใo calculada na emissใo de notas de // 
				// credito e proporcionaliza caso seja uma baixa parcial //
				dbSelectArea("SF2")
				dbSetOrder(1)
				If dbSeek(xFilial("SF2")+aLinTit[nX][2]+aLinTit[nX][1]+aLinTit[nX][3]+aLinTit[nX][5])
					IF SF2->F2_VALIMP4 > 0			
						nValRec:=Round(xMoeda(aLinTit[nX][6],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) //aLinTit[nX][6] 
						nValTit:=Round(xMoeda(aLinTit[nX][7],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))
						nVlPeOrig:= Round(xMoeda(SF2->F2_VALIMP4,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))// Valor da percep็ใo calculado na emissao da nota
						nValProp := Round(nValRec/nValTit,6) // Valor proporcional
						nValMerc := Round(xMoeda(SF2->F2_VALMERC+SF2->F2_VALIMP1,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) // Valor da mercadoria + VALOR DE IGV
						nAliqPerc := Round((nVlPeOrig/nValMerc),MsDecimais(oCBMOed:nAt))*100 // Aliquota percep็ใo SD2->D2_ALIQMP4 				
						nBasePerc := Round((nValProp * nValMerc),MsDecimais(oCBMOed:nAt)) // Base percep็ใo
						nValPerc:=Round(nBasePerc*(nAliqPerc/100),MsDecimais(oCBMOed:nAt))
						cNumTit:= SF2->F2_DOC
						cSerieTit:=SF2->F2_SERIE
						cEmisTit := SF2->F2_EMISSAO
						cEspecie:= SF2->F2_ESPECIE
						lTitAd := .F. // Determina que nao ้ um adiantamento
					EndIf
					If nValPerc > 0 			
						Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,cNumTit,cSerieTit,cEmisTit,cEspecie,lTitAd})	
					EndIf
				EndIf	
			Else
				// Verifica a percep็ใo calculada na emissใo de notas de // 
				// debito e proporcionaliza caso seja uma baixa parcial //
				dbSelectArea("SF1")
				dbSetOrder(1)
				If dbSeek(xFilial("SF1")+aLinTit[nX][2]+aLinTit[nX][1]+aLinTit[nX][3]+aLinTit[nX][5])
					IF SF1->F1_VALIMP4 > 0			
						nValRec:=Round(xMoeda(aLinTit[nX][6],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))//aLinTit[nX][6] 
						nValTit:=Round(xMoeda(aLinTit[nX][7],aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))//aLinTit[nX][7]  
						nVlPeOrig:= Round(xMoeda(SF1->F1_VALIMP4,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt))// Valor da percep็ใo calculado na emissao da nota //SF1->F1_VALIMP4 // Valor da percep็ใo calculado na emissao da nota
						nValProp := Round(nValRec/nValTit,6) // Valor proporcional
						nValMerc := Round(xMoeda(SF1->F1_VALMERC+SF1->F1_VALIMP1,aLinTit[nX][8],1,3,,aTaxa[aLinTit[nX][8]]),MsDecimais(oCBMOed:nAt)) // Valor da mercadoria + VALOR DE IGV //SF1->F1_VALMERC+SF1->F1_VALIMP1 // Valor da mercadoria 
						nAliqPerc := Round((nVlPeOrig/nValMerc),MsDecimais(oCBMOed:nAt))*100 // Aliquota percep็ใo SD1->D1_ALIQMP4 				
						nBasePerc := Round((nValProp * nValMerc),MsDecimais(oCBMOed:nAt)) // Base percep็ใo
						nValPerc:=Round(nBasePerc*(nAliqPerc/100),MsDecimais(oCBMOed:nAt))
						cNumTit:= SF1->F1_DOC
						cSerieTit:=SF1->F1_SERIE
						cEmisTit := SF1->F1_EMISSAO
						cEspecie:= SF1->F1_ESPECIE
						lTitAd := .F. // Determina que nao ้ um adiantamento
					EndIf
					If nValPerc > 0 			
						Aadd(aPerc,{nValPerc,nAliqPerc,nBasePerc,cNumTit,cSerieTit,cEmisTit,cEspecie,lTitAd})	
					EndIf
				EndIF	
			EndIf
		Next 
		RestArea(aArea)
	EndIf  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ F840Perok  บAutor  ณAna Paula           บ Data ณ  04 /11/09บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณvalida a inclusใo da aliquota de percep็ใo		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840Perok(cNumFatAut)
	
	DEFAULT cNumFatAut := ""
	
	oAPerc:Hide()   
	FaMoedas()
	oPanBut:lReadOnly:=.F.
	oPanel[nPanel]:lReadOnly:=.F.
	RefData(4,cNumFatAut)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FinCertPer    บAutor  ณMicrosiga        บ Data ณ    /  /   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPega os numeros de certificados de percep็ใo(Peru)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinCertPer(cImposto,cChave,lReUsa)
	
	Local cNroCert	:=	""
	Local nPosCert	:=	0  
	Local aCerts := {}
	
	DEFAULT lReUsa	:=	.T.
	
	If lReUsa
		nPosCert :=	Ascan(aCerts,{|x| X[1] == cChave } )
	Endif
	If nPosCert > 0 
		Return  aCerts[nPosCert][2] 
	Endif
	
	dbSelectArea("SX5")
	
	If ! MsSeek(xFilial("SX5")+"99"+cImposto,.F.)
		RecLock("SX5", .T.)
		SX5->X5_TABELA 	:= '99'
		SX5->X5_FILIAL 	:= xFilial("SX5")
		SX5->X5_CHAVE  	:= cImposto
		SX5->X5_DESCRI 	:= '00000001'
		SX5->X5_DESCSPA := '00000001'
		SX5->X5_DESCENG := '00000001'
		cNroCert       	:= '00000001'
		MsUnLock()
	Else
		cNroCert := StrZero(Val(X5DESCRI())+1,8)
		Reclock("SX5",.F.)
		SX5->X5_DESCRI 	:= StrZero(Val(cNroCert),8)
		SX5->X5_DESCSPA := StrZero(Val(cNroCert),8)
		SX5->X5_DESCENG := StrZero(Val(cNroCert),8)
		MsUnLock()
	EndIf                 
	
	AAdd(aCerts,{cChave,cNroCert})

Return cNroCert

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCkNaturezaบAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CkNatureza(cNatureza,lNatureza)

	If lFindITF .and. FinProcITF(,1,,,,,cNatureza)
		lNatureza:=.T.
	else
		lNatureza:=.F.
	Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlRetCkPG  บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lRetCkPG(n,cDebInm,cBanco,nPagar)
	
	Local lRetCx:=.T.
	
	If cPaisLoc="PER"
		If n==0
			If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. IsCaixaLoja(cBanco)
				If nPagar=2 //.and. cDebInm="TF"
					lRetCx:=.F.
					MsgAlert(STR0162+cBanco+STR0163)    //   "El Banco "          " no recibe asientos tipo TF."
				Endif
			Endif
		Elseif n==3
			If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
				lRetCx:=.F.
			Endif   
		Endif   
	Endif 
	  
Return(lRetCx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fa840FilTipo     บAutor  ณ Jos้ Lucas บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para cria็ใo de filtro no gatilho campo EL_TIPODOC. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa840FilTipo()

	Local lTipoCred := .F.
	
	If M->EL_TIPODOC $ (IIF(cPaisLoc == "ARG","RG|RB|RS|RI|RR|RM|","RG|RB|RS|RI|RR|"))
		lTipoCred := .T.
	EndIf
	If ! lTipoCred 
		If M->EL_TIPO $ cCredMed         
			lTipoCred := .T.
		EndIf
	EndIf
	If ! lTipoCred		
		If M->EL_TIPO $ cCredInM
			lTipoCred := .T.
		EndIf	
	EndIf

Return( lTipoCred )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fa840TipCred     บAutor  ณ Jos้ Lucas | Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para definir a regra do gatilho campo EL_TIPODOC.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa840TipCred()

	Local cTipoCred := ""        
	Local nPosTpDoc 	:=	Ascan(aHeader,{|x| x[2] == "EL_TIPODOC"})
	Local nPosTpCred	:=	Ascan(aHeader,{|x| Alltrim(x[2]) == "EL_TPCRED"})
	
	If M->EL_TIPODOC $ (IIF(cPaisLoc == "ARG","RG|RB|RS|RI|RR|RM|","RG|RB|RS|RI|RR|"))
		cTipoCred := "4"
	EndIf  
	If M->EL_TIPO $ cCredMed         
		cTipoCred := "3"
	EndIf
	If M->EL_TIPO $ cCredInM         
		cTipoCred := "1"
	EndIf              
	If !Empty(cTipoCred) .and. nPosTpCred > 0
		aCols[n][nPosTpCred] := cTipoCred
	EndIf	           
	oGetSEL:ForceRefresh()
	
Return( cTipoCred )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfa840ConceptบAutor  ณ Jos้ Lucas       บ Data ณ  01/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar o array Concepto com informa็๕es das reten็oes.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fa840Concept(cPrefixo,cNFiscal,cParcela,cTipo,cCliente,cLoja,cCodRet,aDadImp)
	
	Local aArea 	:= GetArea()
	Local aAreaFRN  := {}
	Local aAreaFRM  := {}
	Local aAreaCCR  := {}
	Local aConcepto := {}
	Local aIVA      := {}
	Local aRIR      := {}
	Local nBaseImp  := 0.00
	Local nImposto  := 0.00
	Local nAliquota := 0.00
	Local cCpoBase  := ""
	Local cCpoImp   := ""
	Local nCount    := 0
	
	Local nValCalc   	:= 0
	Local nAliq      	:= 0  
	Local cCarteira		:= ""
	Local cFatoGerador	:= ""
	Local cNatur		:= ""
	Local nValBase		:= 0
	
	Default aDadImp  := {}                           
	
	lConfImp := Len(aDadImp) >= 4
	
	If !lConfImp
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(xFilial("SF2")+cNFiscal+cPrefixo+cCliente+cLoja))
		
		SD2->(dbSetOrder(3))
		If SD2->(dbSeek(xFilial("SD2")+cNFiscal+cPrefixo+cCliente+cLoja))
			While !Eof() .and. SD2->D2_DOC == cNFiscal .and. SD2->D2_SERIE == cPrefixo .and.;
				SD2->D2_CLIENTE == cCliente .and. SD2->D2_LOJA == cLoja
				If cCodRet == "RI"      
					SFB->(dbSeek(xFilial("SFB")+"RV0"))
					cCpoBase  := "SD2->D2_BASIMP"+If(Empty(SFB->FB_CPOLVRO),"1",SFB->FB_CPOLVRO)
					cCpoImp   := "SD2->D2_VALIMP"+If(Empty(SFB->FB_CPOLVRO),"1",SFB->FB_CPOLVRO)
					nBaseImp  := &(cCpoBase)
					nImposto  := &(cCpoImp)
					nAliquota := If(Empty(SFB->FB_ALIQ),Round((nImposto/nBaseImp)*100,2),SFB->FB_ALIQ)
					AADD(aIVA,{SD2->D2_CONCEPT,"RV0",nBaseImp,nAliquota,nImposto,SD2->D2_TES})
				Else
					SFB->(dbSeek(xFilial("SFB")+"RIR"))
					cCpoBase  := "SD2->D2_BASIMP"+If(Empty(SFB->FB_CPOLVRO),"6",SFB->FB_CPOLVRO)
					cCpoImp   := "SD2->D2_VALIMP"+If(Empty(SFB->FB_CPOLVRO),"6",SFB->FB_CPOLVRO)
					nBaseImp  := &(cCpoBase)
					nImposto  := &(cCpoImp)
					nAliquota := If(Empty(SFB->FB_ALIQ),Round((nImposto/nBaseImp)*100,2),SFB->FB_ALIQ)
					If !Empty(SD2->D2_CONCEPT) .And. CCR->(dbSeek(xFilial("CCR")+SD2->D2_CONCEPT))
						nAliquota := CCR->CCR_ALIQ
					EndIf  
					AADD(aRIR,{SD2->D2_CONCEPT,"RIR",nBaseImp,nAliquota,nImposto,SD2->D2_TES})
				EndIf
				SD2->(dbSkip())
			EndDo	
		EndIf 
		If cCodRet == "RI"               
			For nCount := 1 To Len(aIVA)
				nPosConcept := Ascan(aConcepto,{|x| AllTrim(x[2]) == "RV0"})
				If nPosConcept == 0
					AADD(aConcepto,{aIVA[nCount][1],"RV0",aIVA[nCount][3],aIVA[nCount][4],aIVA[nCount][5],aIVA[nCount][6]})
				Else
					aConcepto[1][3] += aIVA[nCount][3]
					aConcepto[1][4] := aIVA[nCount][4]
					aConcepto[1][5] += aIVA[nCount][5]
					aConcepto[1][6] := aIva[nCount][6]
				EndIf
			Next nCount
		Else	
			For nCount := 1 To Len(aRIR)
				nPosConcept := Ascan(aConcepto,{|x,y| AllTrim(x[1]) == AllTrim(aRIR[nCount][1])})
				If nPosConcept == 0
					AADD(aConcepto,{AllTrim(aRIR[nCount][1]),"RIR",aRIR[nCount][3],aRIR[nCount][4],aRIR[nCount][5],aRIR[nCount][6]})
				Else
					aConcepto[1][3] += aRIR[nCount][3]
					aConcepto[1][4] += aRIR[nCount][4]
					aConcepto[1][5] += aRIR[nCount][5]
					aConcepto[1][6] := aRIR[nCount][6]
				EndIf
			Next nCount
		EndIf	
	Else
		cCarteira		:= aDadImp[1]
		cFatoGerador	:= aDadImp[2]
		cNatur			:= aDadImp[3]
		nValBase		:= aDadImp[4]
		
		aAreaFRN  := FRN->(GetArea())  
		aAreaFRM  := FRM->(GetArea())  
		aAreaCCR  := CCR->(GetArea())  
		
		Private aCerts	 := {} //-- Compatibiliza็ใo Configurador de Impostos Localizado - Rep.Dom.
		// Fato gerador => '2' (Baixa)
		FCalcImp(cCarteira,'2', cNatur, SE1->E1_VALOR, SE1->E1_PREFIXO, SE1->E1_NUM, cCliente,cLoja,"", .F. ,,, aConcepto)  
		
		RestArea(aAreaCCR)
		RestArea(aAreaFRM)
		RestArea(aAreaFRN)
	EndIf    
	RestArea(aArea)
	
Return aConcepto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GerNumCertณ Autor ณ marcos Kato          ณ Data ณ30/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica o proximo numero do certificado do imposto        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Retorno  ณ Retorna o numero de certificado e o Numero de Autorizacao  ณฑฑ
ฑฑณ          ณ aArray[1] -> Numero Certificado                            ณฑฑ
ฑฑณ          ณ aArray[2] -> Numero Autorizacao                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Equador                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GerNumCert(cImp,lSoma)

	Local lCertOK	:=.F.
	Local cImpX5 	:=""
	Local aCertRet	:={}
	
	Default cImp:=""
	
	If cPaisLoc != "COS" .And. !Empty(cImp)
		aCertRet:={}
		//Pega o proximo Numero do Certificado de IR e verifica se a numeracao esta dentro do controle de folios tipo RIR		
		DbSelectArea("SX5")
		If dbSeek(xFilial("SX5")+"99"+cImp)
			cImpX5 := (X5Descri())
			cImpX5 := Alltrim(StrZero(VAL(cImpX5)+1,TamSx3("FE_NROCERT")[1]))
			
			DbSelectArea("SFP")
			SFP->(dbGoTop())
			SFP->(DbSetOrder(6))
			If DbSeek(xFilial("SFP")+cFilAnt+"6")
				Do While SFP->FP_FILIAL==xFilial("SFP") .And. SFP->FP_FILUSO==cFilAnt .And. Alltrim(SFP->FP_ESPECIE)=="6" 
					If SFP->FP_NUMINI <= cImpX5 .and. SFP->FP_NUMFIM >= cImpX5
						If SFP->FP_ATIVO == "1"
							If dDataBase <= SFP->FP_DTAVAL
								aAdd(aCertRet,cImpX5)
								aAdd(aCertRet,SFP->FP_NUMAUT)							
								lCertOk:=.T.
								Exit
							EndIf 
						EndIf	
					EndIf
					SFP->(dbSkip())
				EndDo
			Endif
			If lCertOk
				If lSoma 	
					RecLock("SX5",.F.)
					Replace X5_DESCRI	WITH cImpX5
					Replace X5_DESCSPA	WITH cImpX5
					Replace X5_DESCENG	WITH cImpX5
					SX5->(MsUnLock())
				EndIf
			Endif
		Endif 				
	ElseIf cPaisLoc == "COS"
		aAdd(aCertRet,Space(TamSx3("FE_NROCERT")[1]))
		aAdd(aCertRet,Space(TamSx3("FP_NUMAUT")[1]))							
	Endif

Return aCertRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ A840FillC  บAutor  ณBruno               บ Data ณ  22/09/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para recplicar os dados que devem ser iguais no acoolบฑฑ
ฑฑบ          ณdo detalhe das retencoes. (Argentina)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A840FillC(oGetd)

	Local xCont	:=	Nil            
	Local nX

	IF "FE_CFO"$ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,6]	:=	xCont
		Next nX
	ElseIf "FE_RET_MUN"$ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,6]	:=	xCont
		Next nX
	ElseIf "FE_EST"$ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,5]	:=	xCont
		Next nX
	ElseIf "FE_ALIQ" $ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,Len(aCols[nx])-2]	:=	xCont
			oGetD:aCols[nX,Len(aCols[nx])-1]	:=	oGetD:aCols[nX,Len(aCols[nx])-3] * oGetD:aCols[nX,Len(aCols[nx])-2] /100
		Next nX
	ElseIf "FE_RETENC" $ ReadVar()   // Chamado THCEY1 
		xCont	:=	&(ReadVar())
		For nX := 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,Len(aCols[nx])-1] :=	 xCont
			If oGetD:aCols[nX,Len(aCols[nx])-3] > 0
			// Aliquota = Retencao * 100 / Valor Base
			oGetD:aCols[nX,Len(aCols[nx])-2]	:=	oGetD:aCols[nX,Len(aCols[nx])-1] * 100 / oGetD:aCols[nX,Len(aCols[nx])-3]
			Endif
		Next nX
	ElseIf "A2_AGREGAN"$ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,7]	:=	xCont
		Next nX
	ElseIf "A2_CONCSUS"$ ReadVar() 
		xCont	:=	  &(ReadVar())
		For nX:= 1 To Len(oGetd:aCols)
			oGetD:aCols[nX,7]	:=	xCont
		Next nX
	Endif                          
	oGetD:oBrowse:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840RetVldบAutor ณRenan Guedes        บ Data ณ  03/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo da altera็ใo do campo VALOR do quadro de reten็๕esบฑฑ
ฑฑบ          ณdo painel 5. Esta fun็ใo chama as fun็๕es executadas nos    บฑฑ
ฑฑบ          ณpain้is anteriores.                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA840RetVld()

	Local lRet	  		:= .T.
	Local lOk			:= .T.
	Local nX			:= 0
	Local nY			:= 0
	Local cCampo		:= AllTrim(ReadVar())
	Local nPosVal1		:= 0
	Local nPosVal2		:= 0
	Local nPosTpDoc1	:= 0
	Local nPosTpDoc2	:= 0
	Local nPosPref1		:= 0
	Local nPosPref2		:= 0
	Local nPosNum1		:= 0
	Local nPosNum2		:= 0
	Local nPosPar1		:= 0
	Local nPosPar2		:= 0
	Local nPosEmis1		:= 0
	Local nPosEmis2		:= 0
	Local nPosVenc1		:= 0
	Local nPosVenc2		:= 0
	Local aColsRet		:= {}
	
	aColsRet := ACLONE(aColsSEL)
	
	If cCampo == "M->EL_VALOR"
		//Posi็๕es dos campos no cabe็alho
		nPosVal1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR"		})
		nPosVal2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR"		})
		nPosTpDoc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" 	})
		nPosTpDoc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" 	})
		nPosPref1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PREFIXO" 	})
		nPosPref2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_PREFIXO" 	})
		nPosNum1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_NUMERO"		})
		nPosNum2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_NUMERO" 	})
		nPosPar1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PARCELA" 	})
		nPosPar2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_PARCELA" 	})
		nPosEmis1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_EMISSAO"	})
		nPosEmis2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_EMISSAO" 	})
		nPosVenc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_DTVCTO" 	})
		nPosVenc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) == "EL_DTVCTO" 	})
		
		//Captura o novo valor
		nNewVal := &(ReadVar())
		
		//Atualiza a linha da reten็ใo com o novo valor
		oRetTit:aCols[oRetTit:nAt][nPosVal2] := nNewVal
		
		//Zera os valores do quadro de resumo de reten็๕es
		For nX := 1 To Len(oRetRes:aArray)
			oRetRes:aArray[nX,2] := 0
		Next nX
		
		For nX := 1 To Len(oRetTit:aCols)
			//Soma as reten็๕es e atualiza os valores do quadro de resumo de reten็๕es
			If cPaisLoc $ "URU|BOL"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IRIC
						oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IR
						oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]	
			ElseIf cPaisLoc == "PTG"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IVA
						oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IRC
						oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]	
			ElseIf cPaisLoc == "ANG"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//RIE
						oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
				EndCase
				oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]	
			ElseIf cPaisLoc == "PER"
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IGV
						oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//IR
						oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]
				EndCase			
				oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]	
			Else
				Do Case
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 1		//IVA
						oRetRes:aArray[1,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 2		//Ganancias
						oRetRes:aArray[2,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 3		//Ingressos Brutos
						oRetRes:aArray[3,2] += oRetTit:aCols[nX,nPosVal2]
					Case oRetTit:aCols[nX,Len(oRetTit:aHeader)] == 4		//SUSS
						oRetRes:aArray[4,2] += oRetTit:aCols[nX,nPosVal2]
				EndCase			
				oRetRes:aArray[5,2] += oRetTit:aCols[nX,nPosVal2]
			EndIf
		Next nX
		
		//Atualiza o quadro de resumo de reten็๕es
		oRetRes:Refresh()
		
		For nX := 1 To Len(aColsRet)
			If !(aColsRet[nX,Len(aHeaderSEL)+1])
				For nY := 1 To Len(oRetTit:aCols)
					//Procura a linha da aCols onde a reten็ใo se localiza
					If !(aColsRet[nX,Len(aHeaderSEL)+1])	 							.And.;
					(aColsRet[nX,nPosTpDoc1]	== oRetTit:aCols[nY][nPosTpDoc2])	.And.;
					(aColsRet[nX,nPosPref1]		== oRetTit:aCols[nY][nPosPref2])	.And.;
					(aColsRet[nX,nPosNum1]		== oRetTit:aCols[nY][nPosNum2])		.And.;
					(aColsRet[nX,nPosPar1]		== oRetTit:aCols[nY][nPosPar2])		.And.;
					(aColsRet[nX,nPosEmis1]		== oRetTit:aCols[nY][nPosEmis2])	.And.;
					(aColsRet[nX,nPosVenc1]		== oRetTit:aCols[nY][nPosVenc2])
					
					//Atualiza o valor da reten็ใo para possibilitar as valida็๕es  
					aColsRet[nX,nPosVal1] := oRetTit:aCols[nY][nPosVal2]									
					EndIf
				Next nY
			EndIf
		Next nX
		
		//Atribui a aCols o array aCSEL e atualiza o objeto da GetDados de reten็๕es (Painel 1)
		aCols	:= ACLONE(aColsRet)
		aHeader	:= ACLONE(aHeaderSEL)
		oGetSEL:ForceRefresh()	
		
		//Atualiza taxas das moedas				
		FaMoedas()
		
		//Valida a aCols inteira
		If Fa840TudoOk()
			Fa840BaixaOK()
		EndIf
		
		//Seta o aCols para o objeto do browse de reten็๕es
		aCols 		:= ACLONE(oRetTit:aCols)
		aHeader		:= ACLONE(oRetTit:aHeader)
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840RetOkบAutor  ณRenan Guedes        บ Data ณ  03/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo ao confirmar a opera็ใo de recebimentos diversos. บฑฑ
ฑฑบ          ณFaz a atualiza็ใo dos quadros de reten็๕es a partir das     บฑฑ
ฑฑบ          ณaltera็๕es nos valores dos impostos retidos.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณnPanAtu	= N๚mero do painel em exibi็ใo                    บฑฑ
ฑฑบ          ณnUltPan	= N๚mero do ๚ltimo painel						  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840RetOk(nPanAtu,nUltPan)

	Local lRet			:= .T.
	Local nPosVal1		:= 0
	Local nPosVal2		:= 0
	Local nPosTpDoc1	:= 0
	Local nPosTpDoc2	:= 0
	Local nPosPref1		:= 0
	Local nPosPref2		:= 0
	Local nPosNum1		:= 0
	Local nPosNum2		:= 0
	Local nPosPar1		:= 0
	Local nPosPar2		:= 0
	Local nPosEmis1		:= 0
	Local nPosEmis2		:= 0
	Local nPosVenc1		:= 0
	Local nPosVenc2		:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nTotBx		:= 0
	Local nTotRec		:= 0
	
	//Verifica se estแ no ๚ltimo painel
	If nPanAtu == nUltPan
		//Fecha os arquivos temporแrios e restaura os alias originais
		FA840aCtbA(2)
		//Valida a aCols inteira
		If !Fa840TudoOk()
			lRet := .F.
		ElseIf !Fa840BaixaOK()
			lRet := .F.
		EndIf
		If lRet
			//Posi็๕es dos campos no cabe็alho
			nPosVal1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_VALOR"		})
			nPosTpDoc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_TIPODOC" 	})
			nPosPref1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PREFIXO" 	})
			nPosNum1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_NUMERO"		})
			nPosPar1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_PARCELA" 	})
			nPosEmis1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_EMISSAO"	})
			nPosVenc1	:= ASCAN(aHeaderSEL,		{|aCpo| AllTrim(aCpo[2]) == "EL_DTVCTO" 	})
			If cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG'
				nPosVal2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2])	== "EL_VALOR"	})
				nPosTpDoc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_TIPODOC"	})
				nPosPref2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PREFIXO"	})
				nPosNum2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_NUMERO" 	})
				nPosPar2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PARCELA"	})
				nPosEmis2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_EMISSAO"	})
				nPosVenc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_DTVCTO" 	})
				//Atualiza cada linha do quadro de reten็๕es (Painel 1) a partir das altera็๕es do painel 5
				For nX := 1 To Len(oRetTit:aCols)
					If !(oRetTit:aCols[nX,Len(oRetTit:aHeader)+1])
						For nY := 1 To Len(aColsSEL)
							If !(aColsSEL[nX,Len(aHeaderSEL)+1])								.And.;
							(oRetTit:aCols[nX,nPosTpDoc2]	== aColsSEL[nY][nPosTpDoc1])	.And.;
							(oRetTit:aCols[nX,nPosPref2]	== aColsSEL[nY][nPosPref1])		.And.;
							(oRetTit:aCols[nX,nPosNum2]		== aColsSEL[nY][nPosNum1])		.And.;
							(oRetTit:aCols[nX,nPosPar2]		== aColsSEL[nY][nPosPar1])		.And.;
							(oRetTit:aCols[nX,nPosEmis2]	== aColsSEL[nY][nPosEmis1])		.And.;
							(oRetTit:aCols[nX,nPosVenc2]	== aColsSEL[nY][nPosVenc1])							
							
							//Atualiza linhas do quadro de reten็๕es
							aColsSEL[nY][nPosVal1] := oRetTit:aCols[nX][nPosVal2]
							EndIf
						Next nY
					EndIf
				Next nX
			EndIf
			//Atualiza os arrays e objeto do quadro de reten็๕es do painel 1
			aCols	:= ACLONE(aColsSEL)
			aHeader	:= ACLONE(aHeaderSEL)
			oGetSEL:ForceRefresh()									
		
			//Atualiza taxas das moedas
			FaMoedas()
		EndIf
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFA840AValPanบAutor  ณRenan Guedes        บ Data ณ  03/31/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValida o refresh do painel 4 - Resumo                       บฑฑ
ฑฑบ          ณEsta fun็ใo forca a atualiza็ใo do painel 4 quando o		  บฑฑ
ฑฑบ          ณusuแrio estแ num painel posterior e volta para este.        บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑบ          ณFecha e apaga os arquivos temporแrios da simula็ใo da 	  บฑฑ
ฑฑบ          ณcontabiliza็ใo, caso tenham sido criados					  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณnPan = N๚mero do painel a ser exibido                       บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840AValPan(nPan,nLPan)

	Local aColsCtb	:= {}
	Local nX		:= 0
	
	If !cPaisLoc $ "COS"
		If (nPan == (nLPan - 1)) .Or. (nPan == 4)
			//Atualiza os arrays e objeto do quadro de reten็๕es do painel 1
			aCols	:= ACLONE(aColsSEL)
			aHeader	:= ACLONE(aHeaderSEL)
			oGetSEL:ForceRefresh()
			
			//Refaz o browse da simula็ใo da contabiliza็ใo
			aColsCtb := Array(1,Len(oSimCtb:aHeader)+1)
			For nX := 1 To Len(oSimCtb:aHeader)
				aColsCtb[1,nX] := CriaVar(oSimCtb:aHeader[nX,2])
			Next nX
			aColsCtb[1,Len(oSimCtb:aHeader)+1] := .T.
			oSimCtb:SetArray(aColsCtb)
			oSimCtb:Refresh()
			
			dDtCtb := ""
			cLtCtb := ""
			
			oDtCtb:CtrlRefresh()
			oLtCtb:CtrlRefresh()
			
			nCtbDeb := 0
			nCtbCre := 0
			
			oCtbDeb:CtrlRefresh()
			oCtbCre:CtrlRefresh()
			
			FA840aCtbA(2)
		EndIf
	
		If nPan == 4
			RefData(nPan)
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA840   บAutor  ณMicrosiga           บ Data ณ  03/31/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840aCtbA(nOpcX)

	Local aSimCtbSEL	:= {}
	Local aStru			:= {}
	Local cTabSEL		:= ""
	Local cTabSE1		:= ""
	Local cTabSEA		:= ""
	Local cTabSA1		:= ""
	Local cTabSFE		:= ""
	Local cTabCTK		:= ""
	Local cTabCT2		:= ""
	Local cTabSE5		:= ""
	Local cTabCV3		:= ""
	Local cIndSEL		:= ""
	Local cIndSE1		:= ""
	Local cIndSEA		:= ""
	Local cIndSA1		:= ""
	Local cIndSFE		:= ""
	Local cIndCTK		:= ""
	Local cIndCT2		:= ""
	Local cIndSE5		:= ""
	Local cIndCV3		:= ""
	Local cChave		:= ""
	Local cFil			:= ""
	Local aClonSE1		:= {}
	Local aClonSEL		:= {}
	Local aClonRet		:= {}
	Local aBxTotal		:= {}
	Local nValMinRa 	:= SuperGetMv("MV_VLMINRA",,0)
	Local nX			:= 0
	Local nY			:= 0
	Local nI			:= 0
	Local nValMoed		:= 1
	Local cDriver		:= ""
	Local lCreate		:= .T.
	Local cErro			:= ""
	Local nPosSE1		:= 0
	Local nPosSA1		:= 0
	//Posi็๕es dos campos nos cabe็alhos
	Local nPosVal1		:= 0
	Local nPosVal2		:= 0
	Local nPosVal3		:= 0
	Local nPosTpDoc1	:= 0
	Local nPosTpDoc2	:= 0
	Local nPosTpDoc3	:= 0
	Local nPosPref1		:= 0
	Local nPosPref2		:= 0
	Local nPosPref3		:= 0
	Local nPosNum1		:= 0
	Local nPosNum2		:= 0
	Local nPosNum3		:= 0
	Local nPosPar1		:= 0
	Local nPosPar2		:= 0
	Local nPosPar3		:= 0
	Local nPosEmis1		:= 0
	Local nPosEmis2		:= 0
	Local nPosEmis3		:= 0
	Local nPosVenc1		:= 0
	Local nPosVenc2		:= 0
	Local nPosVenc3		:= 0
	Local nPosMotBx3	:= 0
	Local nPosValBx3	:= 0
	Local nPosMoed3		:= 0
	Local nPosCred1		:= 0
	Local nPosMun 	 := 0
	Local nPosEst    := 0
	Local nPosCodFis := 0
	Local nPosRetGan := 0
	Local nPosRetSUS := 0
	Local nPosBaseR  := 0
	Local nPosAliqR  := 0
	Local nPosValR   := 0
	Local aCpoHdSEL		:= {}
	Local nPosDados		:= 0
	Local nDesc			:= 0
	Local nDescRat		:= 0
	Local nTot			:= 0
	Local nDias			:= 0
	Local dBase			:= ""
	Local aFeriados		:= {}
	Local lRatImp		:= GetMv("MV_RATIMP",.F.,"0") == "0" 
	Local nVlrTit		:= 0
	Local lGerNCC		:= .T.
	Local aAreaSE1_		:= {}
	Local nHdlPrv		:= 0
	Local cKeyImp 		:= ""
	Local cAlias		:= ""
	Local aFlagCTB 		:= {}
	Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
	Local nTotalLanc	:= 0
	Local cArquivo		:= ""
	Local nLinha 		:= 1
	Local lLancPad70 	:= .F.
	Local lDigita		:= .F.
	Local cLoteCom		:= ""
	Local nPosAlias		:= 0
	Local aDiario		:= {}
	Local lCtbInUse		:= CtbinUse()
	Local lSimula		:= .T.
	Local aIndices		:= {}
	Local cChaveSEL		:= ""
	Local cChaveSE1		:= ""
	Local cChaveSEA		:= ""
	Local cPadrao		:= ""
	Local nPosSIRES1 	:= 0
	Local nPosCERT1  	:=0
	Local cInd	:= "1"
	Local aChave := {}
	local aValRep := {}
	local aValOk := {}
	Local nJ	:= 0
	
	Local nULin := 0
	Local nZ := 0
	Local nColT := 0
	Local nDecC := 0
	Local nVant := 0
	Local nLimit := 0
	Local lVan:= .F.
	Local cTmpTable := ""
	Local lGetDB   := AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. - Oracle, .F. - Otros manejadores
	
	If !lCtbInUse
		Help(" ",1,"CTBINUSE",,STR0182,1,0)		//"A simula็ใo da contabiliza็ใo estแ disponํvel apenas para ambientes CTB."
		Return
	EndIf
	
	nTotalBx := IIf(Type("nTotalBx") == "U",0,nTotalBx)		//Valor total dos titulos selecionados para baixa
	
	If nOpcX == 1
		//Posi็๕es dos campos no cabe็alho
		nPosVal1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_VALOR"	})
		nPosVal2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2])	== "EL_VALOR"	})
		nPosVal3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_VALOR"	})	
		nPosTpDoc1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_TIPODOC"	})
		nPosTipo   := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2])	== "EL_TIPO"	})
		nPosTpDoc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_TIPODOC"	})
		nPosTpDoc3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_TIPO"	})	
		nPosPref1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PREFIXO"	})
		nPosPref2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PREFIXO"	})
		nPosPref3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_PREFIXO"	})
		nPosNum1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_NUMERO"	})
		nPosNum2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_NUMERO" 	})
		nPosNum3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_NUM" 	})
		nPosPar1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PARCELA"	})
		nPosPar2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PARCELA"	})
		nPosPar3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_PARCELA"	})
		nPosEmis1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_EMISSAO"	})
		nPosEmis2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_EMISSAO"	})
		nPosEmis3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_EMISSAO"	})
		nPosVenc1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_DTVCTO" 	})
		nPosVenc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_DTVCTO" 	})
		nPosVenc3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_VENCTO" 	})
		nPosMotBx3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "cMotBxSE1" 	})
		nPosValBx3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "nBaixar" 	})
		nPosMoed3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "E1_MOEDA" 	})
		nPosDesc3	:= ASCAN(aCposSE1,	{|aCpo| AllTrim(aCpo) 	== "nDescSE1" 	})
		nPosCred1	:= ASCAN(aHeader,  	{|aCpo| Alltrim(aCpo[2])	== "EL_TPCRED"	})
		nPosTrans	:= ASCAN(aHeader,	   {|aCpo| AllTrim(aCpo[2])	== "EL_TRANSIT"	})

		If cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG|MEX'
			If  cPaisLoc == "ARG"     
				nPosSIRES1	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_SIRESEG"	}) 
				nPosCERT1   := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_SIRECER"	})  
				If SFE->(FieldPos("FE_RET_MUN"))>0 .And. SEL->(FieldPos("EL_RET_MUN"))>0
					nPosMun 	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_RET_MUN"	})
				EndIf 
				nPosEst     := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "FE_EST"	}) 
				nPosCodFis  := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "FE_CFO"	}) 
				nPosRetGan  := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "A2_AGREGAN"	}) 
				nPosRetSUS  := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "A2_CONCSUS"	}) 
				nPosBaseR   := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "FE_VALBASE"	}) 
				nPosAliqR   := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "FE_ALIQ"	}) 
				nPosValR    := ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_VALOR"	}) 
			ELSE
				nPosVal2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2])	== "EL_VALOR"	})
				nPosTpDoc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_TIPODOC"	})
				nPosPref2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PREFIXO"	})
				nPosNum2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_NUMERO" 	})
				nPosPar2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_PARCELA"	})
				nPosEmis2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_EMISSAO"	})
				nPosVenc2	:= ASCAN(oRetTit:aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_DTVCTO" 	})
			EndIF
		EndIf
		nPosTrans	:= ASCAN(aHeader,	{|aCpo| AllTrim(aCpo[2]) 	== "EL_TRANSIT"	})
	
		AADD(aCpoHdSEL,{"EL_FILIAL"	,xFilial("SEL")	})
		AADD(aCpoHdSEL,{"EL_SERIE"	,cSerie			})
		AADD(aCpoHdSEL,{"EL_RECIBO"	,cRecibo		})
		AADD(aCpoHdSEL,{"EL_DTDIGIT",dDataBase		})
		AADD(aCpoHdSEL,{"EL_CANCEL"	,.F.			})
		AADD(aCpoHdSEL,{"EL_CLIENTE",cCliente		})
		AADD(aCpoHdSEL,{"EL_LOJA"	,cLoja			})
		AADD(aCpoHdSEL,{"EL_COBRAD"	,cCobrador		})
		AADD(aCpoHdSEL,{"EL_RECPROV",cRecProv		})
		AADD(aCpoHdSEL,{"EL_CLIORIG",cCliOri		})
		AADD(aCpoHdSEL,{"EL_LOJORIG",cLojOri		})	
	
		//Clona os arrays utilizados na confirma็ใo do recebimento
		aClonSEL	:= ACLONE(aCols)
		aClonSE1	:= ACLONE(aLinSE1)

		If cPaisloc == "EUA"
			aClonRet := {} 
		Else
			aClonRet := ACLONE(oRetTit:aCols)
		EndIf
	
		For nX := 1 To Len(aClonSEL)
			If !(aClonSEL[nX][Len(aHeader)+1])
				//Adiciona a reten็ใo ao array que serแ utilizado na simula็ใo da contabiliza็ใo
				AADD(aSimCtbSEL,aClonSEL[nX])
				
				For nY := 1 To Len(aClonRet)
					If	(aClonRet[nY][nPosTpDoc2]	== aClonSEL[nX][nPosTpDoc1])	.And.;
						(aClonRet[nY][nPosPref2]	== aClonSEL[nX][nPosPref1])		.And.;
						(aClonRet[nY][nPosNum2]		== aClonSEL[nX][nPosNum1]) 		.And.;
						(aClonRet[nY][nPosPar2]		== aClonSEL[nX][nPosPar1]) 		.And.;
						(aClonRet[nY][nPosEmis2]	== aClonSEL[nX][nPosEmis1]) 	.And.;
						(aClonRet[nY][nPosVenc2]	== aClonSEL[nX][nPosVenc1])
					
						//Altera o valor para o do quadro de resumo de reten็๕es
						aSimCtbSEL[Len(aSimCtbSEL)][nPosVal1] := aClonRet[nY][nPosVal2]
					
					EndIf
				Next nY			
			EndIf
		Next nX
	
		If nDescGer > 0
			nDesc		:= (nDescGer * nMoedDesc)
			nDescRat	:= 0
			//Totaliza valor das baixas em moeda 1
			aBxTotal := SomaTitBaixa()
			AEVAL(aBxTotal,{|x,y| nTot += (x * aTaxa[y]) })
			//Faz rateio do desconto geral, por item.
			AEVAL(aLinSE1, {|x| nDescRat := IIF (x[1]==1 .And. !(x[nPosTpDoc3]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx3]=="DAC"),((x[nPosValBx3]/(nTot/aTaxa[x[nPosMoed3]]))*(nDescGer*(aTaxa[nMoedDesc]/aTaxa[x[nPosMoed3]]))),0),x[nPosDesc3] += nDescRat, nDesc -= nDescRat*(aTaxa[x[nPosMoed3]]/aTaxa[nMoedDesc])})
		Endif
	
		If nPercGer > 0
			nDescRat := 0
			//Faz rateio do desconto por item.
			AEVAL(aLinSE1, {|x| nDescRat := IIF (x[1]==1 .And. !(x[nPosTpDoc3]$MVRECANT+"/"+MV_CRNEG) .And. !(x[nPosMotBx3]=="DAC"),(nPercGer*x[nPosValBx3]*0.01),0),x[nPosDesc3] += nDescRat})
		Endif
	
		aCtbTmp := {}
		//Estrutura do array aCtbTmp:
		//1 - Alias original
		//2 - Estrutura da tabela (dbStruct)
		//3 - Alias temporแrio para a tabela original
		//4 - Arquivo de trabalho
		//5 - อndice do arquivo de trabalho
		//6 - Chave do ํndice do arquivo de trabalho
		//7 - Filtro do arquivo de trabalho
		//8 - GetArea da tabela
	
		dbSelectArea("SIX")
		SIX->(dbSetOrder(1))		
		
		#IFDEF TOP
			cDriver := "TOPCONN"
		#ELSE
			cDriver := "DBFCDX"
		#ENDIF
	
		//SA1
		aStru := SA1->(dbStruct())
		cTabSA1	:= FINNextAlias()
		#IFDEF TOP
			cIndSA1 := ""
		#ELSE
			cIndSA1	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SA1")
		cFil := ""
		If Select("SA1") > 0
			aAreaTmp := SA1->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SA1",aStru,"__SA1",cTabSA1,cIndSA1,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//SE1
		aStru := SE1->(dbStruct())
		cTabSE1	:= FINNextAlias()
		#IFDEF TOP
			cIndSE1 := ""
		#ELSE
			cIndSE1	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SE1")
		cFil := ""
		If Select("SE1") > 0
			aAreaTmp := SE1->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SE1",aStru,"___SE1",cTabSE1,cIndSE1,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//SE5
		aStru := SE5->(dbStruct())
		cTabSE5	:= FINNextAlias()
		#IFDEF TOP
			cIndSE5 := ""
		#ELSE
			cIndSE5	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SE5")
		cFil := ""
		If Select("SE5") > 0
			aAreaTmp := SE5->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SE5",aStru,"__SE5",cTabSE5,cIndSE5,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//SEA
		aStru := SEA->(dbStruct())
		cTabSEA	:= FINNextAlias()
		#IFDEF TOP
			cIndSEA := ""
		#ELSE
			cIndSEA	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SEA")
		cFil := ""
		If Select("SEA") > 0
			aAreaTmp := SEA->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SEA",aStru,"__SEA",cTabSEA,cIndSEA,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//SEL
		aStru := SEL->(dbStruct())
		cTabSEL	:= FINNextAlias()
		#IFDEF TOP
			cIndSEL := ""
		#ELSE
			cIndSEL	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SEL")
		cFil := ""
		If Select("SEL") > 0
			aAreaTmp := SEL->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SEL",aStru,"__SEL",cTabSEL,cIndSEL,aIndices,cFil,aAreaTmp,cFilter,cDriver})				
	
		//SFE
		aStru := SFE->(dbStruct())
		cTabSFE	:= FINNextAlias()
		#IFDEF TOP
			cIndSFE := ""
		#ELSE		                                      
			cIndSFE	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("SFE")
		cFil := ""
		If Select("SFE") > 0
			aAreaTmp := SFE->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"SFE",aStru,"__SFE",cTabSFE,cIndSFE,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//CT2
		aStru := CT2->(dbStruct())
		cTabCT2	:= FINNextAlias()
		#IFDEF TOP
			cIndCT2	:= ""
		#ELSE
			cIndCT2	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("CT2")
		cFil := ""
		If Select("CT2") > 0
			aAreaTmp := CT2->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"CT2",aStru,"__CT2",cTabCT2,cIndCT2,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//CTK
		aStru := CTK->(dbStruct())
		cTabCTK	:= FINNextAlias()
		#IFDEF TOP
			cIndCTK	:= ""
		#ELSE
			cIndCTK	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("CTK")
		cFil := ""
		If Select("CTK") > 0
			aAreaTmp := CTK->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"CTK",aStru,"__CTK",cTabCTK,cIndCTK,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//CV3
		aStru := CV3->(dbStruct())
		cTabCV3	:= FINNextAlias()
		#IFDEF TOP
			cIndCV3	:= ""
		#ELSE
			cIndCV3	:= CriaTrab(Nil,.F.)
		#ENDIF
		SIX->(dbGoTop())
		aIndices := GetIndices("CV3")
		cFil := ""
		If Select("CV3") > 0
			aAreaTmp := CV3->(GetArea())
			cFilter := dbFilter()
		Else
			aAreaTmp := Nil
			cFilter := Nil
		EndIf		
		AADD(aCtbTmp,{"CV3",aStru,"__CV3",cTabCV3,cIndCV3,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	
		//Abre o alias original com outro nome e o fecha para tabelas temporแrias DBFCDX
		For nX := 1 To Len(aCtbTmp)
			If Select(aCtbTmp[nX,3]) > 0
				dbSelectArea(aCtbTmp[nX,3])
				dbCloseArea()									
			EndIf
			
			ChkFile(aCtbTmp[nX,1], .F. , aCtbTmp[nX,3])
			dbSelectArea(aCtbTmp[nX,1])
			dbCloseArea()
		Next nX
	
		//Crea tablas temporales 
		For nX := 1 To Len(aCtbTmp)
			cTmpTable :=  cNomObjT + alltrim(str(nX)) // nombre de variable temporal dinแmica declarada en func Fina840
			cInd := "1"
			&(cTmpTable ):= FWTemporaryTable():New(aCtbTmp[nX,1]) //nombre de archivo
			&(cTmpTable ):SetFields( aCtbTmp[nX,2] ) //estructura de archivo
			
			//Obtiene ํndices 
			aIndices := aClone(aCtbTmp[nX,6])
			
			//Recorre el ํndice y excluye las funciones de conversi๓n de datos que pueda contener el campo
			For nY := 1 to Len(aIndices)				
				aChave := STRTOKARR ( ALLTRIM(aIndices[nY]) , "+" )	
				For nJ := 1 to Len(aChave)
					IF SUBSTR(ALLTRIM (UPPER(aChave[nJ])),0,5) == "DTOS("
						aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),"DTOS(","")
						aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),")","")
					ELSEIF SUBSTR(ALLTRIM (UPPER(aChave[nJ])),0,4) == "STR("
						aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),"STR(","")
						aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),",3)","")
					EndIf
				Next nJ
				
				AADD(aValRep, aChave)
				//Valida que ํndice no est้ repetido en su secuencia	
				nULin := Len(aValRep)  
				For nZ := 1 To nULin
					IF nULin > 1 .and. nULin != nZ
						nColT:= Len(aValRep[nULin])
						nVant:= Len(aValRep[nZ])
				
						If nColT >= nVant
							nLimit := nVant
						Else
							nLimit := nColT
						EndIf
				
						for nI := 1 To nLimit
							If aValRep[nZ ,nI] == aValRep[nULin ,nI] 
								AADD(aValOk,.T.)
							Else
								AADD(aValOk,.F.)
							EndIf
						NexT nI	
				
						If ascan(aValOk,{|x| x = .F. }) == 0
							lVan:= .T. 
						EndIF
						aValOk := {}  
					EndIf		
				Next nZ
				//si es el primero indice procesado o no hubo repetidos agtrega addindex
				//If (!lVan .OR. nULin == 1 ).AND. !lGetDB
			   		//&(cTmpTable):AddIndex( aCtbTmp[nX,4] + cInd, aChave)
					//cInd := Soma1(cInd,5)
				If (!lVan .OR. nULin == 1) //.AND. lGetDB
					&(cTmpTable):AddIndex( cInd, aChave)
					cInd := Soma1(cInd,5)
				EndIf
				lVan:= .F.
			Next nY 
			aValRep := {}
			//Crea la tabla 
			&(cTmpTable):Create()
			If aCtbTmp[nX,1] == "CTK"
				cTabCTK := &(cTmpTable):GetRealName()
			ElseIf aCtbTmp[nX,1] == "CT2"
				cTabCT2 := &(cTmpTable):GetRealName()
			EndIf 
		Next nX
	
		nPosSE1 := ASCAN(aCtbTmp, {|aX| aX[1] == "SE1"})
		nPosSA1 := ASCAN(aCtbTmp, {|aX| aX[1] == "SA1"})
		
		//Adiciona o registro da tabela SE1 na tabela temporแria		
		dbSelectArea(aCtbTmp[nPosSE1,3])
		dbSetOrder(1)		//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		
		For nY := 1 To Len(aLinSE1)
			If (aLinSE1[nY,1] == 1) .And. (aCtbTmp[nPosSE1,3])->(MsSeek(xFilial("SE1")+aLinSE1[nY,nPosPref3]+aLinSE1[nY,nPosNum3]+aLinSE1[nY,nPosPar3]+aLinSE1[nY,nPosTpDoc3]))
				RecLock("SE1",.T.)
				For nX := 1 To Len(aCtbTmp[nPosSE1,2])
					SE1->&(aCtbTmp[nPosSE1,2,nX,1]) := (aCtbTmp[nPosSE1,3])->&(aCtbTmp[nPosSE1,2,nX,1])
				Next nX
				MsUnlock()
			EndIf
		Next nY
	
		//Adiciona o registro da tabela SA1 na tabela temporแria		
		dbSelectArea(aCtbTmp[nPosSA1,3])
		If MsSeek(xFilial("SA1")+cCliente+cLoja)		//A1_FILIAL+A1_COD+A1_LOJA		
			RecLock("SA1",.T.)
			For nX := 1 To Len(aCtbTmp[nPosSA1,2])
				SA1->&(aCtbTmp[nPosSA1,2,nX,1]) := (aCtbTmp[nPosSA1,3])->&(aCtbTmp[nPosSA1,2,nX,1])
			Next nX
			MsUnlock()
		EndIf
	
		//Grava os dados da simula็ใo da contabiliza็ใo			
		For nX := 1 To Len(aSimCtbSEL)
			//Grava os dados da tabela SEL
			RecLock("SEL",.T.)
			//nI:=1
			AEVAL(aCpoHdSEL,{|x,y| IIF(FieldPos(x[1]) > 0, FieldPut(FieldPos(ALLTRIM(x[1])) , x[2]),)			})
			AEVAL(aCposSEL,	{|x,y| IIF(FieldPos(x) > 0, FieldPut(FieldPos(ALLTRIM(x)) , aSimCtbSEL[nX][y]),)	})
			If aSimCtbSEL[nX][nPosTpDoc1] $ cTiposAdm
				nPosDados := ASCAN(aDadosAdm, {|x| x[5] == nX})
				SEL->EL_CLIENTE := aDadosAdm[nPosDados][01]
				SEL->EL_LOJA    := aDadosAdm[nPosDados][02]				
				SEL->EL_TIPODOC := aDadosAdm[nPosDados][04]
			EndIf
			SEL->EL_VLMOED1	:= Round( SEL->EL_VALOR * aTaxa[Val(SEL->EL_MOEDA)] ,MsDecimais(1) )
			SEL->EL_TIPO		:= SEL->EL_TIPODOC      
			SEL->EL_RECIBO	:= cRecibo
			SEL->EL_VERSAO := cRevisao
			//Grava as taxas das moedas
			For nY := 2 To Len(aTaxa)
				If (SEL->(FieldPos("EL_TXMOE"+StrZero(nY,2))) > 0)
					SEL->&("EL_TXMOE"+StrZero(nY,2)) := aTaxa[nY]
				EndIf
			Next nY	
			MsUnlock()
			
			//Grava os dados da tabela SE1
			If aSimCtbSEL[nX][nPosTipo] $ cCredMed
				RecLock("SE1",.T.)
				SE1->E1_FILIAL 	:= xFilial("SE1")
				SE1->E1_FILORIG := cFilant								
				SE1->E1_SERREC 	:= SEL->EL_SERIE
				SE1->E1_RECIBO 	:= SEL->EL_RECIBO
				SE1->E1_PREFIXO	:= SEL->EL_PREFIXO
				SE1->E1_NUM    	:= SEL->EL_NUMERO
				SE1->E1_PARCELA	:= SEL->EL_PARCELA
				SE1->E1_TIPO   	:= SEL->EL_TIPODOC    
				SE1->E1_PORTADO	:= SEL->EL_BANCO
				SE1->E1_AGEDEP 	:= SEL->EL_AGENCIA
				SE1->E1_CONTA  	:= SEL->EL_CONTA
				SE1->E1_BCOCHQ 	:= SEL->EL_BCOCHQ
				SE1->E1_AGECHQ 	:= SEL->EL_AGECHQ
				SE1->E1_CTACHQ 	:= SEL->EL_CTACHQ
				SE1->E1_EMISSAO	:= SEL->EL_EMISSAO   //dDataRef
				SE1->E1_EMIS1  	:= CtoD("")
				SE1->E1_VENCREA	:= DATAVALIDA(SEL->EL_DTVCTO)
				SE1->E1_VENCTO 	:= SEL->EL_DTVCTO
				SE1->E1_VENCORI	:= SEL->EL_DTVCTO
				SE1->E1_NATUREZ	:= SEL->EL_NATUREZ
				SE1->E1_MOEDA  	:= Val(SEL->EL_MOEDA)
				SE1->E1_CLIENTE	:= SEL->EL_CLIENTE
				SE1->E1_LOJA   	:= SEL->EL_LOJA
				SE1->E1_VALOR  	:= SEL->EL_VALOR
				SE1->E1_SALDO  	:= SEL->EL_VALOR
				SE1->E1_VLCRUZ 	:= SEL->EL_VALOR * aTaxa[SE1->E1_MOEDA]
				SE1->E1_NOMCLI 	:= SA1->A1_NOME
				SE1->E1_EMIS1  	:= dDataBase
				SE1->E1_TXMOEDA	:= aTaxa[SE1->E1_MOEDA]
			
				If (Empty(SEL->EL_BANCO) .And. Empty(SEL->EL_CONTA) .And. Empty(SEL->EL_AGENCIA)) .Or.;
					(SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","") + "/" + Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
					
					SE1->E1_SITUACA := "0"
				ElseIf SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","") + "/" + Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1]))
					SE1->E1_SITUACA := "0"
				Else
					SE1->E1_SITUACA := "0"
				EndIf
			
				nDias := Val(SEL->EL_ACREBAN)
				dBase := SE1->E1_VENCREA
				If nDias > 5
					dBase += 3650
				Else
				aFeriados := RetFeriados()
				While nDias > 0
					dBase++
					If ASCAN(aFeriados,DtoS(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
						nDias--
					EndIf
				EndDo
			EndIf
			SE1->E1_DTACRED := dBase
			
			SE1->E1_ORIGEM 	:= "FINA840"
			SE1->E1_VLCRUZ 	:= SEL->EL_VLMOED1
			SE1->E1_LA     	:= "S"
			SE1->E1_STATUS 	:= IIF(SE1->E1_SALDO <= 0, "B", "A")
			SE1->E1_MOVIMEN	:= SE1->E1_DTACRED	
			MsUnLock()
			
			If SE1->E1_SITUACA == "1"
				SEA->(dbSetOrder(1))
				SEA->(dbGoTop())
				If SEA->(MsSeek(xFilial("SEA")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA))
					RecLock("SEA",.F.)
					SEA->EA_DATABOR 	:= SEL->EL_DTVCTO
					SEA->EA_PORTADO 	:= SEL->EL_BANCO
					SEA->EA_AGEDEP  	:= SEL->EL_AGENCIA
					SEA->EA_NUMCON  	:= SEL->EL_CONTA
					SEA->EA_TIPO    	:= SEL->EL_TIPODOC
					SEA->EA_CART    	:= "R"
					SEA->EA_SITUACA 	:= "1"
					SEA->EA_FILORIG 	:= SE1->E1_FILIAL
					MsUnlock()
				Else			
					If !Empty(SEL->EL_BANCO)
						RecLock("SEA",.T.)
						SEA->EA_FILIAL  	:= xFilial("SEA")
						SEA->EA_DATABOR 	:= SEL->EL_DTVCTO
						SEA->EA_PORTADO 	:= SEL->EL_BANCO
						SEA->EA_AGEDEP  	:= SEL->EL_AGENCIA
						SEA->EA_NUMCON  	:= SEL->EL_CONTA
						SEA->EA_NUM     	:= SEL->EL_NUMERO
						SEA->EA_PARCELA 	:= SEL->EL_PARCELA
						SEA->EA_PREFIXO 	:= SEL->EL_PREFIXO
						SEA->EA_TIPO    	:= SEL->EL_TIPODOC
						SEA->EA_CART    	:= "R"
						SEA->EA_SITUACA 	:= "1"
						SEA->EA_FILORIG 	:= SE1->E1_FILIAL
						MsUnlock()
					EndIf
				EndIf
			EndIf
			
			FA840aAtSdDp("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[SE1->E1_MOEDA],SE1->E1_EMISSAO)
			Endif
		
		Next nX
	
		dbSelectArea("SE1")
		SE1->(dbGoTop())
		ASORT(aClonSE1,,,{|x,y| x[1] > y[1] })		// Organiza aLinSE1 para que os marcados venham primeiro.
		For nX := 1 to Len(aClonSE1)
			If aClonSE1[nX][1] != 1
				Exit
			EndIf
			If SE1->(MsSeek(xFilial("SE1")+aClonSE1[nX,nPosPref3]+aClonSE1[nX,nPosNum3]+aClonSE1[nX,nPosPar3]+aClonSE1[nX,nPosTpDoc3]))
				//SE1->(MsGoto(aClonSE1[nX][Len(aClonSE1[nX])-1]))
				RecLock("SE1",.F.)
				SE1->E1_BAIXA		:= dDataRef
				SE1->E1_LA			:= 'S'
				SE1->E1_MOTIVO		:= aClonSE1[nX][nPosMotBx]
				SE1->E1_MOVIMEN		:= dDataRef
				SE1->E1_SALDO		:= (SE1->E1_SALDO - aClonSE1[nX][nPosValBx3])
				nDescoSlv			:= SE1->E1_DESCONT
				nMultaSlv			:= SE1->E1_MULTA
				nJurosSlv			:= SE1->E1_JUROS
				nVlLiqSlv			:= SE1->E1_VALLIQ
				SE1->E1_DESCONT		:= aClonSE1[nX][nPosDesc]
				SE1->E1_MULTA		:= aClonSE1[nX][nPosMulta]
				SE1->E1_JUROS		:= aClonSE1[nX][nPosJuros]
				SE1->E1_VALLIQ		:= (aClonSE1[nX][nPosValBx3] - aClonSE1[nX][nPosDesc] + aClonSE1[nX][nPosJuros] + aClonSE1[nX][nPosMulta])
				SE1->E1_SERREC   	:= cSerie
				SE1->E1_RECIBO		:= cRecibo
				SE1->E1_DTACRED		:= dDataRef
				SE1->E1_STATUS		:= IIF(SE1->E1_SALDO <=0 , "B", "A")
				//+--------------------------------------------------------------+
				//ฆ Baixar titulos de abatimento se for baixa total              ฆ
				//+--------------------------------------------------------------+
				IF (SE1->E1_SALDO > 0 .And. SE1->E1_SALDO == nTotAbat .And. !(SE1->E1_TIPO $ MV_CPNEG))
					SE1->E1_SALDO		:= 0
					SE1->E1_STATUS 		:= "B"
					cTitulo  	:= xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
					aAreaSE1_ 	:= SE1->(GetArea())
					SE1->(dbSetOrder(1))
					If MsSeek(cTitulo)
						While !SE1->(EOF()) .And. xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA == cTitulo
							If SE1->E1_TIPO $ MVABATIM
								RecLock("SE1",.F.)
								Replace E1_SALDO    With 0
								Replace E1_BAIXA    With dDataBase
								Replace E1_MOVIMEN  With dDataBase
								SE1->(MsUnLock())
							EndIf
							dbSkip()
						EndDo
					EndIf
					RestArea(aAreaSE1_)
				EndIf
				MsUnlock()
	
				dbSelectArea("SEL")
				RecLock("SEL",.T.)
				SEL->EL_FILIAL   	:= xFilial("SEL")
				SEL->EL_TIPODOC  	:= "TB"            // para registros que representam o titulo SE1 baixado 
				SEL->EL_PREFIXO  	:= SE1->E1_PREFIXO
				SEL->EL_NUMERO   	:= SE1->E1_NUM
				SEL->EL_PARCELA  	:= SE1->E1_PARCELA
				SEL->EL_TIPO   	:= SE1->E1_TIPO   
				SEL->EL_BCOCHQ 	:= SE1->E1_BCOCHQ
				SEL->EL_AGECHQ   	:= SE1->E1_AGECHQ
				SEL->EL_CTACHQ   	:= SE1->E1_CTACHQ
				SEL->EL_EMISSAO  	:= SE1->E1_EMISSAO
				SEL->EL_DTDIGIT  	:= dDataBase
				SEL->EL_DTVCTO   	:= SE1->E1_VENCREA
				SEL->EL_NATUREZ  	:= SE1->E1_NATUREZ
				SEL->EL_MOEDA    	:= STRZERO(SE1->E1_MOEDA,2)
				SEL->EL_VLMOED1		:= Round((SE1->E1_VALLIQ) * aTaxa[Max(1,SE1->E1_MOEDA)], MsDecimais(1))
				SEL->EL_DESCONT  	:= SE1->E1_DESCONT
				SEL->EL_MULTA	:= SE1->E1_MULTA
				SEL->EL_JUROS	:= SE1->E1_JUROS
				SEL->EL_VALOR    	:= SE1->E1_VALLIQ
				SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
				SEL->EL_LOJA		:= SE1->E1_LOJA
				SEL->EL_SERIE    	:= cSerie
				SEL->EL_RECIBO 		:= cRecibo
				SEL->EL_VERSAO		:= cRevisao
				SEL->EL_COBRAD		:= cCobrador
				SEL->EL_RECPROV		:= cRecProv
				SEL->EL_CLIORIG		:= cCliOri
				SEL->EL_LOJORIG		:= cLojOri
	
				For nY := 2 To Len(aTaxa)
					If (SEL->(FieldPos("EL_TXMOE"+StrZero(nY,2))) > 0)
						SEL->&("EL_TXMOE"+StrZero(nY,2)) := aTaxa[nY]
					EndIf
				Next nY	
				
				MsUnlock()
	
				If SE1->(MsSeek(xFilial("SE1")+aClonSE1[nX,nPosPref3]+aClonSE1[nX,nPosNum3]+aClonSE1[nX,nPosPar3]+aClonSE1[nX,nPosTpDoc3]))
					RecLock("SE1",.F.)	
					SE1->E1_DESCONT		+= nDescoSlv
					SE1->E1_MULTA		+= nMultaSlv
					SE1->E1_JUROS		+= nJurosSlv
					SE1->E1_VALLIQ		+= nVlLiqSlv
					MsUnlock()
				EndIf
			EndIf
		Next nX
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz as gravacoes dos titulos que tem retencoes no SFE		 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cPaisLoc != "ARG"   
		
			If Len(aSimCtbSEL) > 0
				dbSelectArea("SFE")
				//Rateia os impostos nos titulos informados
				nX:=0
				For nI := 1 To Len(aSimCtbSEL) // linhas do Recibo
					If aSimCtbSEL[nI][nPosTpDoc1] $ "RS|RL|RB|RI|RG|RM"
						SE1->(dbSetOrder(1))
						nX++ // Linhas das reten็๕es
						For nY := 1 To Len(aLinRet[nX])  // Linhas dos Titulos de cada Reten็ใo
							If aSimCtbSEL[nI][nPosTpDoc1] == "RB"
								If !aLinRet[nX][nY][Len(aLinRet[nX,nY])] .And. (aLinRet[nX][nY][Len(aLinRet[nX,nY])-1] > 0) .And. ;
								(!lRatImp .Or.(SE1->(MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) )))	
								
									RecLock("SFE",.T.)
									SFE->FE_FILIAL   	:= xFilial("SFE")
									SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
									SFE->FE_CLIENTE  	:= cCliente
									SFE->FE_LOJCLI 		:= cLoja
									If lRatImp
										SFE->FE_NFISCAL  	:= SE1->E1_NUM
										SFE->FE_SERIE    	:= SE1->E1_SERIE
										SFE->FE_EST 		:= aLinRet[nX][nY][5]
										SFE->FE_CFO	 		:= aLinRet[nX][nY][6]
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][7]
										SFE->FE_ALIQ		:= aLinret[nX][nY][8]
										SFE->FE_RETENC 		:= aLinRet[nX][nY][9]
									Else
										SFE->FE_EST 		:= aLinRet[nX][nY][1]
										SFE->FE_CFO	 		:= aLinRet[nX][nY][2]
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][3]
										SFE->FE_ALIQ		:= aLinret[nX][nY][4]
										SFE->FE_RETENC 		:= aLinRet[nX][nY][5]
									Endif
									SFE->FE_RECIBO		:= cRecibo
									SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
									SFE->FE_TIPO   		:= "B"
									MsUnlock()
								EndIf
							ElseIf aSimCtbSEL[nI][nPosTpDoc1] $ "RM" .and. SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0 
								If !aLinRet[nX][nY][Len(aLinRet[nX,nY])] .And. (aLinRet[nX][nY][Len(aLinRet[nX,nY])-1] > 0) .And. ;
								(!lRatImp .Or.(SE1->(MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) )))
								
									RecLock("SFE",.T.)    
									SFE->FE_FILIAL   	:= xFilial("SFE")   
									SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
									SFE->FE_CLIENTE  	:= cCliente
									SFE->FE_LOJCLI 	:= cLoja       
									If lRatImp // Prorateo MV_RATIMP
										cMunp := aLinRet[nX][nY][6]
										SFE->FE_NFISCAL  	:= SE1->E1_NUM
										SFE->FE_SERIE    	:= SE1->E1_SERIE
										SFE->FE_EST 		:= aLinRet[nX][nY][5]
										SFE->FE_RET_MUN	:= aLinRet[nX][nY][6]   
										SFE->FE_CFO	 	:= aLinRet[nX][nY][7]   
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][8]   
										SFE->FE_ALIQ		:= aLinret[nX][nY][9]   
										SFE->FE_RETENC 	:= aLinRet[nX][nY][10]   
									Else
										cMunp := aLinRet[nX][nY][2]
										SFE->FE_EST 		:= aLinRet[nX][nY][1]
										SFE->FE_RET_MUN	:= aLinRet[nX][nY][2]
										SFE->FE_CFO	 	:= aLinRet[nX][nY][3]   
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][4]   
										SFE->FE_ALIQ		:= aLinret[nX][nY][5]   
										SFE->FE_RETENC 	:= aLinRet[nX][nY][6] 
									Endif
									SFE->FE_RECIBO		:= cRecibo       
									SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1] 
									SFE->FE_TIPO   		:= "M"
									MsUnlock() 
								EndIf 
							ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RI"
								If !aLinRet[nX][nY][Len(aLinRet[nX,nY])] .And. (aLinRet[nX][nY][Len(aLinRet[nX,nY])-1] > 0) .And. ;
									(!lRatImp .Or.(SE1->(MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) )))
									
									RecLock("SFE",.T.)
									SFE->FE_FILIAL	:= xFilial("SFE")
									SFE->FE_EMISSAO	:= aCols[nI][nPosEmis1]
									SFE->FE_CLIENTE	:= cCliente
									SFE->FE_LOJCLI 	:= cLoja
									If lRatImp
										SFE->FE_NFISCAL		:= SE1->E1_NUM
										SFE->FE_SERIE		:= SE1->E1_SERIE
										SFE->FE_EST 		:= aLinRet[nX][nY][5]
										SFE->FE_CFO	 		:= aLinRet[nX][nY][6]
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][7]
										SFE->FE_ALIQ		:= aLinret[nX][nY][8]
										SFE->FE_RETENC 		:= aLinRet[nX][nY][9]
									Else	
										SFE->FE_EST 		:= aLinRet[nX][nY][1]
										SFE->FE_CFO	 		:= aLinRet[nX][nY][2]
										SFE->FE_VALBASE 	:= aLinRet[nX][nY][3]
										SFE->FE_ALIQ		:= aLinret[nX][nY][4]
										SFE->FE_RETENC 		:= aLinRet[nX][nY][5]
									Endif
									SFE->FE_RECIBO		:= cRecibo
									SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
									SFE->FE_TIPO   		:= "I"
									MsUnlock()
								EndIf
							ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RG"
								If !aLinRet[nX][nY][Len(aLinRet[nX,nY])] .And. (aLinRet[nX][nY][Len(aLinRet[nX,nY])-1] > 0) .And. ;
									(!lRatImp .Or.(SE1->( MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) )))
								
									RecLock("SFE",.T.)
									FE_FILIAL   := xFilial('SFE')
									FE_EMISSAO  := aCols[nI][nPosEmis1]
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLoja
									If lRatImp
										FE_NFISCAL  := SE1->E1_NUM
										FE_SERIE    := SE1->E1_SERIE
										FE_EST 		:= aLinRet[nX][nY][5]
										FE_CFO	 	:= aLinRet[nX][nY][6]
										FE_CONCEPT 	:= aLinRet[nX][nY][7]
										FE_VALBASE 	:= aLinRet[nX][nY][8]
										FE_ALIQ		:=	aLinret[nX][nY][9]
										FE_RETENC 	:= aLinRet[nX][nY][10]
									Else
										FE_EST 		:= aLinRet[nX][nY][1]
										FE_CFO	 	:= aLinRet[nX][nY][2]
										FE_CONCEPT 	:= aLinRet[nX][nY][3]
										FE_VALBASE 	:= aLinRet[nX][nY][4]
										FE_ALIQ		:=	aLinret[nX][nY][5]
										FE_RETENC 	:= aLinRet[nX][nY][6]
									Endif
									FE_RECIBO   := cRecibo
									FE_NROCERT	:= aSimCtbSEL[nI][nPosNum1]
									FE_TIPO   	:= "G"
									MsUnlock()
								EndIf
							ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RS"
								If !aLinRet[nX][nY][Len(aLinRet[nX,nY])] .And. (aLinRet[nX][nY][Len(aLinRet[nX,nY])-1] > 0) .And. ;
									(!lRatImp .Or.(SE1->( MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) )))
								
									RecLock("SFE",.T.)
									FE_FILIAL   := xFilial('SFE')
									FE_EMISSAO  := aCols[nI][nPosEmis1]
									FE_CLIENTE  := cCliente
									FE_LOJCLI 	:= cLoja
									If lRatImp
										FE_NFISCAL  := SE1->E1_NUM
										FE_SERIE    := SE1->E1_SERIE
										FE_EST 		:= aLinRet[nX][nY][5]
										FE_CFO	 	:= aLinRet[nX][nY][6]
										FE_CONCEPT 	:= aLinRet[nX][nY][7]
										FE_VALBASE 	:= aLinRet[nX][nY][8]
										FE_ALIQ		:=	aLinret[nX][nY][9]
										FE_RETENC 	:= aLinRet[nX][nY][10]
									Else
										FE_EST 		:= aLinRet[nX][nY][1]
										FE_CFO	 	:= aLinRet[nX][nY][2]
										FE_CONCEPT 	:= aLinRet[nX][nY][3]
										FE_VALBASE 	:= aLinRet[nX][nY][4]
										FE_ALIQ		:=	aLinret[nX][nY][5]
										FE_RETENC 	:= aLinRet[nX][nY][6]
									Endif
									FE_RECIBO   := cRecibo
									FE_NROCERT	:= aSimCtbSEL[nI][nPosNum1]
									FE_TIPO   	:= "S"
									If SFE->(FieldPos("FE_SIRECER")) > 0
										FE_SIRECER := aSimCtbSEL[nI][nPosCERT1]
									EndIf
									If SFE->(FieldPos("FE_SIRESEG")) > 0
										FE_SIRESEG := aSimCtbSEL[nI][nPosSIRES1]
									EndIf
									MsUnlock()
								EndIf
							Else
								If aLinRet[nX][nY][7] == aSimCtbSEL[nI][nPosTpDoc1]
									If (aLinRet[nX][nY][5] > 0) .And. ;
										(SE1->(MsSeek(xFilial("SE1")+aLinRet[nX][nY][1]+aLinRet[nX][nY][2]+aLinRet[nX][nY][3]+aLinRet[nX][nY][4]) ))
										RecLock("SFE",.T.)
										SFE->FE_FILIAL   	:= xFilial("SFE")
										SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
										SFE->FE_CLIENTE  	:= cCliente
										SFE->FE_LOJCLI 		:= cLoja
										SFE->FE_NFISCAL  	:= SE1->E1_NUM
										SFE->FE_SERIE    	:= SE1->E1_SERIE
										SFE->FE_RECIBO   	:= cRecibo
										SFE->FE_NROCERT		:= aLinRet[nX][nY][6]
										SFE->FE_TIPO   		:= Subs(aLinRet[nX][nY][7] ,2 ,1) // I-B-S-L
										SFE->FE_RETENC 		:= aLinRet[nX][nY][5]
										MsUnlock()
									EndIf
								EndIf
							EndIf
						Next nY 
					Else
						If (aSimCtbSEL[nI][nPosVal1] > 0) .And. (aSimCtbSEL[nI][nPosTpDoc1] $ "RI")
							RecLock("SFE",.T.)
							SFE->FE_FILIAL   	:= xFilial("SFE")
							SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
							SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
							SFE->FE_CLIENTE  	:= cCliente
							SFE->FE_LOJCLI 		:= cLoja
							SFE->FE_TIPO   		:= Subs(aSimCtbSEL[nI][nPosTpDoc1] ,2 ,1) // I-B   // VERIFICAR O QUE GRAVA QUANDO USA RETENCAO
							SFE->FE_RECIBO   	:= cRecibo
							SFE->FE_RETENC 		:= aSimCtbSEL[nI][nPosVal1]
							MsUnlock()
						EndIf
					Endif
				Next nI
			EndIf	
		ElseIf cPaisLoc == "ARG"
			
			If Len(aSimCtbSEL) > 0
				dbSelectArea("SFE")
				//Rateia os impostos nos titulos informados
				nX:=0
				For nI := 1 To Len(aSimCtbSEL) // linhas do Recibo
					If aSimCtbSEL[nI][nPosTpDoc1] $ "RS|RL|RB|RI|RG|RM"
						SE1->(dbSetOrder(1))
						nX++ // Linhas das reten็๕es
						If aSimCtbSEL[nI][nPosTpDoc1] == "RB"
							If !aSimCtbSEL[nI][Len(aSimCtbSEL[nI])] .And. ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
							(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))	
								
								RecLock("SFE",.T.)
								SFE->FE_FILIAL   	:= xFilial("SFE")
								SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
								SFE->FE_CLIENTE  	:= cCliente
								SFE->FE_LOJCLI 		:= cLojCli
								SFE->FE_EST 		:= aSimCtbSEL[nI][nPosEst]
								SFE->FE_CFO	 		:= aSimCtbSEL[nI][nPosCodFis]
								SFE->FE_VALBASE 	:= aSimCtbSEL[nI][nPosBaseR]
								SFE->FE_ALIQ		:= aSimCtbSEL[nI][nPosAliqR]
								SFE->FE_RETENC 		:= aSimCtbSEL[nI][nPosValR]
								SFE->FE_RECIBO		:= cRecibo
								SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
								SFE->FE_TIPO   		:= "B"
								MsUnlock()
							EndIf
						ElseIf aSimCtbSEL[nI][nPosTpDoc1] $ "RM" .and. SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0 
							If !aSimCtbSEL[nI][Len(aSimCtbSEL[nI])] .And. ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))
								
								RecLock("SFE",.T.)    
								SFE->FE_FILIAL   	:= xFilial("SFE")   
								SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
								SFE->FE_CLIENTE  	:= cCliente
								SFE->FE_LOJCLI 	:= cLojCli       
								cMunp := aSimCtbSEL[nI][nPosMun]
								SFE->FE_EST 		:= aSimCtbSEL[nI][nPosEst]
								SFE->FE_RET_MUN	    := aSimCtbSEL[nI][nPosMun]
								SFE->FE_CFO	 	    := aSimCtbSEL[nI][nPosCodFis]
								SFE->FE_VALBASE 	:= aSimCtbSEL[nI][nPosBaseR]
								SFE->FE_ALIQ		:= aSimCtbSEL[nI][nPosAliqR]   
								SFE->FE_RETENC 	    := aSimCtbSEL[nI][nPosValR]
								SFE->FE_RECIBO		:= cRecibo       
								SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1] 
								SFE->FE_TIPO   		:= "M"
								MsUnlock() 
							EndIf 
						ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RI"
							If !aSimCtbSEL[nI][Len(aSimCtbSEL[nI])] .And. ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))
								
								RecLock("SFE",.T.)
								SFE->FE_FILIAL	:= xFilial("SFE")
								SFE->FE_EMISSAO	:= aCols[nI][nPosEmis1]
								SFE->FE_CLIENTE	:= cCliente
								SFE->FE_LOJCLI 	:= cLojCli
								SFE->FE_EST 		:= aSimCtbSEL[nI][nPosEst]
								SFE->FE_CFO	 		:= aSimCtbSEL[nI][nPosCodFis]
								SFE->FE_VALBASE 	:= aSimCtbSEL[nI][nPosBaseR]
								SFE->FE_ALIQ		:= aSimCtbSEL[nI][nPosAliqR]
								SFE->FE_RETENC 		:= aSimCtbSEL[nI][nPosValR]
								SFE->FE_RECIBO		:= cRecibo
								SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
								SFE->FE_TIPO   		:= "I"
								MsUnlock()
							EndIf
						ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RG"
							If !aSimCtbSEL[nI][Len(aSimCtbSEL[nI])] .And. ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))
		
								RecLock("SFE",.T.)
								FE_FILIAL   := xFilial('SFE')
								FE_EMISSAO  := aCols[nI][nPosEmis1]
								FE_CLIENTE  := cCliente
								FE_LOJCLI 	:= cLojCli
								FE_EST 		:= aSimCtbSEL[nI][nPosEst]
								FE_CFO	 	:= aSimCtbSEL[nI][nPosCodFis]
								FE_CONCEPT 	:= aSimCtbSEL[nI][nPosRetGan]
								FE_VALBASE 	:= aSimCtbSEL[nI][nPosBaseR]
								FE_ALIQ		:= aSimCtbSEL[nI][nPosAliqR]
								FE_RETENC 	:= aSimCtbSEL[nI][nPosValR]
								FE_RECIBO   := cRecibo
								FE_NROCERT	:= aSimCtbSEL[nI][nPosNum1]
								FE_TIPO   	:= "G"
								MsUnlock()
							EndIf
						ElseIf aSimCtbSEL[nI][nPosTpDoc1] == "RS"
							If !aSimCtbSEL[nI][Len(aSimCtbSEL[nI])] .And. ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. !lRatImp .Or. ;
								(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))
								
								RecLock("SFE",.T.)
								FE_FILIAL   := xFilial('SFE')
								FE_EMISSAO  := aCols[nI][nPosEmis1]
								FE_CLIENTE  := cCliente
								FE_LOJCLI 	:= cLojCli
								FE_EST 		:= aSimCtbSEL[nI][nPosEst]
								FE_CFO	 	:= aSimCtbSEL[nI][nPosCodFis]
								FE_CONCEPT 	:= aSimCtbSEL[nI][nPosRetSUS]
								FE_VALBASE 	:= aSimCtbSEL[nI][nPosBaseR]
								FE_ALIQ		:= aSimCtbSEL[nI][nPosAliqR]
								FE_RETENC 	:= aSimCtbSEL[nI][nPosValR]
								FE_RECIBO   := cRecibo
								FE_NROCERT	:= aSimCtbSEL[nI][nPosNum1]
								FE_TIPO   	:= "S"
								If SFE->(FieldPos("FE_SIRECER")) > 0
									FE_SIRECER := aSimCtbSEL[nI][nPosCERT1]
								EndIf
								If SFE->(FieldPos("FE_SIRESEG")) > 0
									FE_SIRESEG := aSimCtbSEL[nI][nPosSIRES1]
								EndIf
								MsUnlock()
							EndIf
						Else
							If ( aSimCtbSEL[nI][nPosValR] > 0 ) .And. ;
								(SE1->(MsSeek(xFilial("SE1") + aSimCtbSEL[nI][nPosEst] + aSimCtbSEL[nI][nPosCodFis] + STR(aSimCtbSEL[nI][nPosBaseR]) + STR(aSimCtbSEL[nI][nPosAliqR]) )))
		
								RecLock("SFE",.T.)
								SFE->FE_FILIAL   	:= xFilial("SFE")
								SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
								SFE->FE_CLIENTE  	:= cCliente
								SFE->FE_LOJCLI 		:= cLojCli
								SFE->FE_NFISCAL  	:= SE1->E1_NUM
								SFE->FE_SERIE    	:= SE1->E1_SERIE
								SFE->FE_RECIBO   	:= cRecibo
								SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
								SFE->FE_TIPO   		:= Subs(aSimCtbSEL[nI][nPosTpDoc1] ,2 ,1) // I-B-S-L
								SFE->FE_RETENC 		:= aSimCtbSEL[nI][nPosValR]
								MsUnlock()
							EndIf
						EndIf
					Else
						If (aSimCtbSEL[nI][nPosVal1] > 0) .And. (aSimCtbSEL[nI][nPosTpDoc1] $ "RI")
							RecLock("SFE",.T.)
							SFE->FE_FILIAL   	:= xFilial("SFE")
							SFE->FE_NROCERT		:= aSimCtbSEL[nI][nPosNum1]
							SFE->FE_EMISSAO  	:= aCols[nI][nPosEmis1]
							SFE->FE_CLIENTE  	:= cCliente
							SFE->FE_LOJCLI 		:= cLojCli
							SFE->FE_TIPO   		:= Subs(aSimCtbSEL[nI][nPosTpDoc1] ,2 ,1) // I-B   // VERIFICAR O QUE GRAVA QUANDO USA RETENCAO
							SFE->FE_RECIBO   	:= cRecibo
							SFE->FE_RETENC 		:= aSimCtbSEL[nI][nPosVal1]
							MsUnlock()
						EndIf
					Endif
				Next nI
			EndIf			
		EndIf
	
		If lGerNCC
			lGerNCC	:= .F.
			cParc	:= " "
			
			SE1->(dbGoTop())
			While SE1->(MsSeek(xFilial("SE1")+"REC"+Padr(cRecibo,TamSx3("E1_NUM")[1]," ")+Padr(cParc,TamSx3("E1_PARCELA")[1]," ")+cDocCred))
				cParc := Soma1(cParc)
			Enddo
			
			For nValMoed := 1 To Len(aLinMoed)
				nVlrTit	:= aLinMoed[nValMoed,4]
				If nVlrTit > 0
				//-- Registro no SEL
				RecLock("SEL",.T.)
				SEL->EL_FILIAL		:= xFilial("SEL") 
				SEL->EL_TIPODOC 	:= "RA"
				SEL->EL_PREFIXO  	:= "REC"
				SEL->EL_NUMERO   	:= cRecibo
				SEL->EL_PARCELA  	:= cParc
				SEL->EL_TIPO   	:= cDocCred
				SEL->EL_EMISSAO  	:= dDataRef
				SEL->EL_DTDIGIT  	:= dDataBase
				SEL->EL_DTVCTO   	:= dDataRef
				SEL->EL_MOEDA    	:= StrZero(nValMoed,2)//Aqui representa qual e a moeda
				SEL->EL_VLMOED1  	:= Round( nVlrTit * aTaxa[nValMoed], MsDecimais(1) )
				SEL->EL_VALOR    	:= nVlrTit
				SEL->EL_CLIENTE  	:= cCliente
				SEL->EL_LOJA	 	:= cLoja
				SEL->EL_SERIE  		:= cSerie
				SEL->EL_RECIBO 		:= cRecibo
				SEL->EL_VERSAO := cRevisao
				SEL->EL_COBRAD		:= cCobrador
				SEL->EL_RECPROV		:= cRecProv
				SEL->EL_CLIORIG		:= cCliOri
				SEL->EL_LOJORIG		:= cLojOri   
			
				For nY := 2 To Len(aTaxa)
					If (SEL->(FieldPos("EL_TXMOE"+StrZero(nY,2))) > 0)
						SEL->&("EL_TXMOE"+StrZero(nY,2)) := aTaxa[nY]
					EndIf
				Next nY
				
				MsUnlock()
	
				//-- Registro no SE1
				RecLock("SE1",.T.)
				SE1->E1_FILIAL   	:= xFilial("SE1")
				SE1->E1_FILORIG     := cFilant					
				SE1->E1_PREFIXO  	:= "REC"
				SE1->E1_NUM			:= cRecibo
				SE1->E1_PARCELA		:= cParc
				SE1->E1_TIPO     	:= cDocCred   // gravando o titulo ncc com o tipo original. ok correto 
				SE1->E1_EMISSAO  	:= dDataRef
				SE1->E1_EMIS1    	:= dDataBase
				SE1->E1_VENCTO  	:= dDataRef
				SE1->E1_VENCREA 	:= DataValida(dDataRef)
				SE1->E1_NATUREZ  	:= SEL->EL_NATUREZ
				SE1->E1_MOEDA   	:= nValMoed
				SE1->E1_VLCRUZ		:= nVlrTit * aTaxa[nValMoed]
				SE1->E1_VALOR   	:= nVlrTit
				SE1->E1_SALDO   	:= nVlrTit
				SE1->E1_CLIENTE 	:= cCliente
				SE1->E1_LOJA    	:= cLOJA
				SE1->E1_SERREC    	:= cSerie
				SE1->E1_RECIBO  	:= cRecibo
				SE1->E1_NOMCLI   	:= SA1->A1_NOME
				SE1->E1_SITUACA  	:= "0"
				SE1->E1_ORIGEM   	:= "FINA840"
				SE1->E1_LA       	:= "S"
				SE1->E1_STATUS   	:= "A"
				SE1->E1_TXMOEDA		:= aTaxa[nValMoed]
				If cPaisLoc == "CHI"
				SE1->E1_CGC 		:= SA1->A1_CGC
				Endif
				MsUnlock()
				
				FA840aAtSdDp("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTaxa[SE1->E1_MOEDA],SE1->E1_EMISSAO)
				cParc := Soma1(cParc)		//Atualiza a proxima parcela		
				EndIf
			Next nValMoed
		EndIf			
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Simula็ใo da contabiliza็ใo                                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lGeraLanc
			//+--------------------------------------------------------------+
			//ฆ Posiciona numero do Lote para Lancamentos do Financeiro      ฆ
			//+--------------------------------------------------------------+
			dbSelectArea("SX5")
			MsSeek(xFilial()+"09FIN")
			cLoteCom := IIF(Found(),AllTrim(X5DESCRI()),"FIN")
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Inicializa Lancamento Contabil                                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nHdlPrv := HeadProva(cLoteCom,;
			"FINA840",;
			Substr(cUsuario, 7, 6),;
			@cArquivo)
			
			If nHdlPrv <= 0
				Help(" ",1,"A100NOPROV")
			EndIf
		Else
			Return
		EndIf
	
		If nHdlPrv > 0 .and. lGeraLanc
			//+--------------------------------------------------+
			//ฆ Gera Lancamento Contab. para RECIBO.             ฆ
			//+--------------------------------------------------+
			If lGeraLanc
				dbSelectArea("SEL")
				SEL->(dbSetOrder(8))
				SEL->(MsSeek(xFilial("SEL")+cSerie+cRECIBO,.F.))
		
				While !SEL->(EOF()) .And. SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRECIBO
		
					Do Case 
						Case SEL->(EL_TIPODOC) == "TB" .And. SEL->(EL_TIPO) $ MV_CRNEG+"/"+MVRECANT .And. VerPadrao("5BN")
							lLancPad70 := .T. 
							cPadrao := "5BN" 
						Case SEL->(EL_TIPODOC) == "TB" .And. !(SEL->(EL_TIPO) $ MV_CRNEG+"/"+MVRECANT) .And. VerPadrao("5BO")
							lLancPad70 := .T.
							cPadrao := "5BO"			
						Case SEL->(EL_TIPODOC) == "RA" .And. VerPadrao("5BP")
							lLancPad70 := .T. 
							cPadrao := "5BP"
						Case SEL->(EL_TIPODOC) == "CH" .And. VerPadrao("5BQ")
							lLancPad70 := .T.  
							cPadrao := "5BQ"
						Case SEL->(EL_TIPODOC) == "DC" .And. VerPadrao("5BR")
							lLancPad70 := .T.
							cPadrao := "5BR"
						Case SEL->(EL_TIPODOC) == "EF" .And. VerPadrao("5BS")
							lLancPad70 := .T. 
							cPadrao := "5BS"
						Case SEL->(EL_TIPODOC) == "TF" .And. VerPadrao("5BT")
							lLancPad70 := .T.
							cPadrao := "5BT"
						Case SEL->(EL_TIPODOC) $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5BU")
							lLancPad70 := .T.
							cPadrao := "5BU"
						Otherwise
							lLancPad70 := VerPadrao("575")
							cPadrao := "575"   
					EndCase
					
					If 	lLancPad70			
						SA6->(dbSetOrder(1))
						SA6->(MsSeek(xFilial("SA6")+SEL->(EL_BANCO+EL_AGENCIA+EL_CONTA),.F.))
						
						dbSelectArea("SE1")
						SE1->(dbSetOrder(2))
						SE1->(MsSeek(xFilial("SE1")+SEL->(EL_CLIORIG+EL_LOJORIG+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),.F.))
			
						Do Case
							Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
								cAlias := "SF1"
							Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
								cAlias := "SF1"         
							Otherwise
								cAlias := "SF2"    
						EndCase
						cKeyImp := 	xFilial(cAlias)			+;
						SE1->E1_NUM		+;
						SE1->E1_PREFIXO	+;
						SE1->E1_CLIENTE	+;
						SE1->E1_LOJA			
						If ( cAlias == "SF1" )
							cKeyImp += SE1->E1_TIPO   
						Endif
						Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
		
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Prepara Lancamento Contabil                                      ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
						aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
						Endif
						nTotalLanc := nTotalLanc + DetProva(nHdlPrv,;
						cPadrao,;
						"FINA840" /*cPrograma*/,;
						cLoteCom,;
						@nLinha,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						@aFlagCTB,;
						/*aTabRecOri*/,;
						/*aDadosProva*/,;
						lSimula,;
						cTabCTK,;
						cTabCT2,;
						cTabCV3)
	
						If UsaSeqCor()
							AAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
						EndIf
					EndIf
					SEL->(dbSkip())
				EndDo
			Endif
	
			//+-----------------------------------------------------+
			//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
			//+-----------------------------------------------------+
			//ํndice continua sendo 8, por้m como ordem 1
			SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Efetiva Lanamento Contabil                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RodaProva(nHdlPrv,nTotalLanc)
			
			lLanctOk := cA100Incl(	cArquivo,;
			nHdlPrv,;
			3 /*nOpcx*/,;
			cLoteCom,;
			lDigita,;
			lAglutina,;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			aDiario,;
			/*aTpSaldo*/,;
			lSimula,;
			cTabCTK,;
			cTabCT2)
			
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			
			If lLanctOk
				// ํndice continua sendo 8, por้m como ordem 1
				If SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo))
					While SEL->EL_SERIE==cSerie .And. SEL->EL_RECIBO==cRecibo
						RecLock("SEL",.F.)
						Replace EL_LA With "S"
						MsUnLock()
						SEL->(dbSkip())
					Enddo
				EndIf
			Endif
		EndIf				
	EndIf
	
	If nOpcX == 2
		If (aCtbTmp != Nil) .And. (ValType(aCtbTmp) == "A")
			//Se for 2, fecha e exclui os arquivos temporแrios e restaura os alias originais
			For nX := 1 To Len(aCtbTmp)
				//Elimina las tablas temporales
				//nombre de variable temporal dinแmica declarada en func Fina840
				If &(cNomObjT + alltrim(str(nX))) <> Nil  
					&(cNomObjT + alltrim(str(nX))):Delete() 
					&(cNomObjT + alltrim(str(nX))) := Nil 
				Endif
				//Restaura o alias original
				If Select(aCtbTmp[nX,3]) > 0
					ChkFile(aCtbTmp[nX,3], .F. , aCtbTmp[nX,1])
					dbSelectArea(aCtbTmp[nX,3])
					dbCloseArea()
					dbSelectAreA(aCtbTmp[nX,1])
					If (aCtbTmp[nX,8] != Nil) .And. (ValType(aCtbTmp[nX,8]) == "A")
						RestArea(aCtbTmp[nX,8])
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA840   บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescricao ณFuncao que grava os campos no SA1 para avalia็ao de credito ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณcOper = Operando para calcular os campos de avlia็ao do 	  ณฑฑ
ฑฑบ          ณ        credito 											  ณฑฑ
ฑฑณ          ณnValor = Valor do campo que serแ calculado                  ณฑฑ
ฑฑณ          ณnMoeda = Moeda Forte do Cliente                             ณฑฑ
ฑฑณ          ณcTipoDoc = Tipo de Titulo(Docto)                            ณฑฑ
ฑฑณ          ณnTaxa  = Taxa de conversใo do Valor do campo para a Moeda   ณฑฑ
ฑฑบ          ณ         Forte 											  ณฑฑ
ฑฑณ          ณdData  = Data de conversใo do Valor do cmapo para a Moeda   ณฑฑ
ฑฑบ          ณ         Forte 											  ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบATENวรO   ณ ESTE PROGRAMA ษ UMA CำPIA E ADAPTAวรO DO AtuSalDup         บฑฑ
ฑฑบ          ณ CONTIDO NO FONTE MATXATU                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840aAtSdDp(cOper,nValor,nMoeda,cTipoDoc,nTaxa,dData,nCm)

	Local cCampo		:= ""									// Campo que terแ o saldo atualizado
	Local cCampo1		:= ""									// Campo que terแ o saldo atualizado
	Local cTpNaoAtu		:= Nil									// Tipos que nao atualizam saldo algum no cadastro de clientes
	Local lE1MsFil		:= SE1->(FieldPos("E1_MSFIL") > 0)		// Se existe o campo E1_MSFIL
	Local aAreaSA1		:= SA1->(GetArea()) 					// Salva a area do SA1
	Local cTiposLC		:= Nil
	Local nMCusto
	Local nMoedaF		:= 0
	Local nValorMoe1	:= 0
	Local nValorMoeF	:= 0
	
	nTaxa	:=  If(nTaxa	==	Nil,0,nTaxa)
	nMoeda	:=	If(nMoeda	==	Nil,1,nMoeda)
	dData	:=	If(dData	==	Nil,dDataBase,dData)
	
	Default nCm := 0
	
	If !cOper $ "+-="
		MsgAlert(STR0044)  //"Operando incorreto, Verifique se ้ uma atribui็ใo, soma ou subtra็ใo"
		Return
	Endif
	
	If cTiposLC == Nil
		cTiposLC := ""
		cTiposLC := FA840aSESTp({ || ES_SALDUP == "2"},"1")
		nMCusto  :=	Val(GetMV("MV_MCUSTO"))
	Endif
	
	// Tipos que nao atualizam nenhum dos saldos
	If cTpNaoAtu == Nil
		cTpNaoAtu := ""
		cTpNaoAtu := FA840aSESTp({ || ES_SALDUP == "3"},"1")
	Endif
	
	If !(cTipoDoc $ cTpNaoAtu)
		If cTipoDoc $ cTiposLC
			cCampo	:=	"SA1->A1_SALFIN"
			cCampo1	:=	"SA1->A1_SALFINM"
		Else
			cCampo	:=	"SA1->A1_SALDUP"
			cCampo1	:=	"SA1->A1_SALDUPM"
		Endif
	Else
		Return
	Endif
	
	nMoedaF		:= If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,nMCusto)
	
	nValorMoe1	:= Round(xMoeda(nValor-nCm,nMoeda,1,dData,MsDecimais(1)+1),MsDecimais(1))
	nValorMoeF  := Round(xMoeda(nValor,nMoeda,nMoedaF,dData,MsDecimais(nMoedaF)+1,,nTaxa),MsDecimais(nMoedaF))
	
	RecLock("SA1",.F.)
	If cOper == "+"
		&cCampo. 	+= nValorMoe1
		&cCampo1. 	+= nValorMoeF
	ElseIf cOper == "-"
		&cCampo. 	-= nValorMoe1
		&cCampo1. 	-= nValorMoeF
	ElseIf cOper == "="
		&cCampo. 	:= nValorMoe1
		&cCampo1.	:= nValorMoeF
	EndIf
	MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFA840aSESTpบAutor  ณ Renan Guedes       บ Data ณ  04/05/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a os tipos de acordo com o bloco de codigo.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ bProps    = Bloco de codigo com as propriedades a consultarบฑฑ
ฑฑบ          ณ cCarteira = Carteira a consultar (Default  ambas).        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบATENวรO   ณ ESTE PROGRAMA ษ UMA CำPIA E ADAPTAวรO DO GetSESTipos       บฑฑ
ฑฑบ          ณ CONTIDO NO FONTE MATXFUNC                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840aSESTp(bProps,cCarteira)

	Local aArea	:= {}
	Local cRet
	
	Default cCarteira 	:=	"3"
	
	cRet	:=	Space(0)
	aArea	:=	GetArea()
	
	If AliasInDic("SES") //Select("SES") > 0
		dbSelectArea("SES")
		dbSetOrder(1)
		dbSeek(xFilial())
		While !EOF() .And. xFilial() == ES_FILIAL
			If EVAL(bProps) .And. ( cCarteira $ "3" .Or. ES_CARTEIR $ "3" ;
			.Or. ES_CARTEIR $ cCarteira)
				cRet +=	ES_TIPO + "|"
			Endif
		dbSkip()
		EndDo
	EndIf
	
	cRet :=	IIF(!Empty(cRet), Substr(cRet,1,Len(cRet)-1), cRet)
	
	RestArea(aArea)

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFINNextAliasบAutor  ณAlvaro Camillo Netoบ Data ณ  15/04/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FINNextAlias()

	Local cNextAlias := ""
	Local aArea := GetArea()
	
	While .T.
		cNextAlias := GetNextAlias()
		If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
			Exit
		EndIf
	EndDo
	
	RestArea(aArea)

Return cNextAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ F840ValCli บAutor  ณAna Paula           บ Data ณ  18/05/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo de clientes bloqueados							  บฑฑ
ฑฑบ          ณ										                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA840                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840ValCli(cCliente,cLoja,cNumFatAut)      
	
	Local aArea:= GetArea()  
	Local lRet:= .T.
	
	DEFAULT cCliente:= ""
	DEFAULT cLoja:= ""
	DEFAULT cNumFatAut:=""
	
	If SA1->(DbSeek(xFilial("SA1")+cCliente))
		If cLoja <> "" .And. SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja)) .And. SA1->A1_MSBLQL == "1"  
			HELP(" ",1,"REGBLOQ")
			lRet:= .F.
		Else
			FA840AtuCli(cNumFatAut)	
		Endif
	Else
		lRet:= .F.
	EndIf	
	RestArea(aArea)
	
Return lRet  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840TpTitบAutor  ณJair Ribeiro        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna combo para EL_TIPO                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAFIN                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA840TpTit()
	
	Local aArea 	:= {}
	Local cCombo	:= ""
	
	If AliasInDic("FJS")
		aArea:= FJS->(GetArea())	
		DbSelectArea("FJS")
		FJS->(DbSetOrder(1))
		FJS->(DbGotop())
		While FJS->(!EOF())
			If ((ALLTRIM(FJS->FJS_BLOQ) == "2") .and. (ALLTRIM(FJS->FJS_CARTE) $ "1|3")) 
				cCombo += ALLTRIM(FJS->FJS_TIPO) +"="+ ALLTRIM(FJS->FJS_DESC)+";"
			EndIf
			FJS->(DbSkip())
		EndDo
		If !Empty(cCombo)
			cCombo:= SubStr(cCombo,1,Len(cCombo)-1)
		EndIf
		FJS->(RestArea(aArea))
	EndIf
	
Return cCombo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840ValTpบAutor  ณJair Ribeiro        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o uso do tipo de documento                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA840ValTp()

	Local aArea 	:= {}
	Local lRet		:= .T.
	Local nPosTran	:= 0
	Local nPosCpo	:= 0
	Local cConteudo	:= &(ReadVar())
	Local lUsaCmc7	:= SuperGetMv("MV_CMC7FIN") == "S"
	Local aCheque	:= {}
	
	If AliasInDic("FJS") 
		aArea := FJS->(GetArea())
		DbSelectArea("FJS")
		FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
		If FJS->(DbSeek(xFilial("FJS")+PadR(cConteudo,TamSx3("FJS_TIPO")[1])))  
			If !((ALLTRIM(FJS->FJS_BLOQ) == "2") .and. (ALLTRIM(FJS->FJS_CARTE) $ "1|3")) 
				lRet := .F.
				Help( " ", 1, "FANOTOPODOC",,STR0191,1,0)//"Nใo ้ possํvel utilizar este tipo de documento"
			EndIf
		Else
			lRet := .F.
			Help( " ", 1, "FANOTOPODOC",,STR0191,1,0)//"Nใo ้ possํvel utilizar este tipo de documento"	
		EndIf
		If lRet .and. lUsaCmc7 .and. FJS->FJS_TIPOIN $ "CH "
			aCheque := FinCmc7Tc()
			If Len(aCheque) > 0
				//Verifica e cadastra as entidades bancแrias se for ao caso
				FINEntBc(aCheque[1],aCheque[2],aCheque[3])
		
				//Repassa os valores a tela do recibo
				If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_BCOCHQ"})) > 0
					aCols[n,nPosCpo] := aCheque[1]
				Endif
				If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_AGECHQ"})) > 0
					aCols[n,nPosCpo] := aCheque[2]
				Endif
				If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_POSTAL"})) > 0
					aCols[n,nPosCpo] := aCheque[3]
				Endif
				If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_NUMERO"})) > 0
					aCols[n,nPosCpo] := aCheque[4]
				Endif
				If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_CTACHQ"})) > 0
					aCols[n,nPosCpo] := aCheque[5]
				Endif
			Endif
		EndIf 
	
		If lRet
			If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_ENDOSSA"})) > 0
				If FJS->FJS_CARTE $ "13"
					aCols[n,nPosCpo] := "2"
				EndIf
			Endif
			If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_TERCEIR"})) > 0
				If FJS->FJS_CARTE $ "13" 
					aCols[n,nPosCpo] := "1"
				EndIf
			EndIf
			If (nPosCpo := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "EL_TRANSIT"})) > 0
				aCols[n,nPosCpo] := FJS->FJS_TRANS
			Endif                                                                
		Endif
		FJS->(RestArea(aArea))
	EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinGetTipoบAutor  ณJair Ribeiro        บ Data ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao retorna tipos de acordo com alias e filtro          บฑฑ
ฑฑบ          ณ semelhante ao GetSESTipos                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN 		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinGetTipo(bFiltro,cAlias,cChave,cCampo,nOrder)

	Local cRet		:= ""
	Local xValor	:= ""
	Local cType		:= ""
	Local aArea		:= {}
	
	If AliasInDic(cAlias)
		aArea	:= (cAlias)->(GetArea())
		
		(cAlias)->(DbSetOrder(nOrder))
		(cAlias)->(DbSeek(cChave))
		
		While (cAlias)->(!EOF())	
			If Eval(bFiltro)
				xValor	:=(cAlias)->&(cCampo)
				
				If (cType := ValType(xValor)) != "C"
					If cType == "N"
						xValor := ALLTRIM(STR(xValor))	
					ElseIf cType == "D"
						xValor := ALLTRIM(DTOS(xValor))
					ElseIf cType == "L"
						If xValor
							xValor := "T"
						Else
							xValor := "F"
						EndIf
					EndIf			
				EndIf
				cRet	+= xValor + "|"
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		If !Empty(cRet)
			cRet:= SubStr(cRet,1,Len(cRet)-1)
		EndIf 
		(cAlias)->(RestArea(aArea))
	EndIf
	
Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin840SE1 บAutor  ณJair Ribeiro        บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar registro no SE1 se sao cheques ou pagtos sem         บฑฑ
ฑฑบ          ณ movimenta็ใo imediata                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fin840SE1(cClienteSE1,cLojaSE1,aTxMoed,cTipoCred,cSerieSE1,cReciboSE1,_cCredInm) 

	Local nDias	:= 0
	Local dBase
	Local aFeriados := {}
	
	Default _cCredInm := ""
	
	SE1->(DbSetOrder(2))
	If SE1->(DbSeek(xFilial("SE1")+cClienteSE1+cLojaSE1+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
		RecLock("SE1",.F.)
	Else
		RecLock("SE1",.T.)
	EndIf
	
	SE1->E1_FILIAL := xFilial("SE1")
	SE1->E1_FILORIG:= cFilant
	SE1->E1_SERREC := SEL->EL_SERIE
	SE1->E1_RECIBO := SEL->EL_RECIBO
	SE1->E1_PREFIXO:= SEL->EL_PREFIXO
	SE1->E1_NUM    := SEL->EL_NUMERO
	SE1->E1_PARCELA:= SEL->EL_PARCELA
	SE1->E1_TIPO   := SEL->EL_TIPODOC          // ALTERADO SEL->EL_TIPODOC (conteudo do FJS_TIPOIN  
	SE1->E1_PORTADO:= SEL->EL_BANCO
	SE1->E1_AGEDEP := SEL->EL_AGENCIA
	SE1->E1_CONTA  := SEL->EL_CONTA
	SE1->E1_BCOCHQ := SEL->EL_BCOCHQ
	SE1->E1_AGECHQ := SEL->EL_AGECHQ
	SE1->E1_CTACHQ := SEL->EL_CTACHQ
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Requisito de Controle de Entidades Bancarias ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( cPaisLoc == "ARG" ) 
		SE1->E1_POSTAL := SEL->EL_POSTAL
	EndIf
	
	SE1->E1_EMISSAO:= SEL->EL_EMISSAO   //dDataRef
	SE1->E1_EMIS1  := CtoD("")
	SE1->E1_VENCREA:= DATAVALIDA(SEL->EL_DTVCTO)
	SE1->E1_VENCTO := SEL->EL_DTVCTO
	SE1->E1_VENCORI:= SEL->EL_DTVCTO
	SE1->E1_NATUREZ:= SEL->EL_NATUREZ
	SE1->E1_MOEDA  := Val(SEL->EL_MOEDA)
	SE1->E1_CLIENTE:= SEL->EL_CLIENTE
	SE1->E1_LOJA   := SEL->EL_LOJA
	SE1->E1_VALOR  := SEL->EL_VALOR
	SE1->E1_SALDO  := SEL->EL_VALOR
	
	If ( cPaisLoc == "CHI" )
		SE1->E1_VLCRUZ := Round(SEL->EL_VALOR*aTxMoed[SE1->E1_MOEDA], MsDecimais(1))
	Else
		SE1->E1_VLCRUZ := SEL->EL_VALOR*aTxMoed[SE1->E1_MOEDA]
	EndIf
	
	SE1->E1_NOMCLI := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+PadR(SEL->EL_CLIENTE,TamSx3("A1_COD")[1])+PadR(SEL->EL_LOJA,TamSx3("A1_LOJA")[1]),1,"")
	SE1->E1_EMIS1  := dDataBase
	SE1->E1_TXMOEDA:= aTxMoed[SE1->E1_MOEDA]
	
	If cTipoCred $ "1|2" .Or. SEL->EL_TIPO $ IIf(Type("cCredInm") == "U",_cCredInm,cCredInm) //Cheques vindos de credito imediato devem entrar como baixados
		SE1->E1_BAIXA		:=If(cTipoCred == "1",dDatabase,DataValida(SEL->EL_DTVCTO))
		SE1->E1_LA			:='S'
		SE1->E1_MOTIVO  	:=""
		SE1->E1_MOVIMEN     :=SE1->E1_BAIXA
		SE1->E1_SALDO       :=0
		SE1->E1_DESCONT     :=0
		SE1->E1_MULTA       :=0
		SE1->E1_JUROS       :=0
		SE1->E1_VALLIQ      :=SEL->EL_VALOR
		SE1->E1_SERREC      :=cSerieSE1
		SE1->E1_RECIBO      :=cReciboSE1
		SE1->E1_DTACRED     :=SE1->E1_BAIXA
	EndIf
	
	//+--------------------------------------------------------------------------------+
	//ฆSi no se ingreso el banco o se ingreso en una caja, SITUACA es 0 (en cartera)   ฆ
	//+--------------------------------------------------------------------------------+
	If (Empty(SEL->EL_BANCO).And.Empty(SEL->EL_CONTA).And.Empty(SEL->EL_AGENCIA)).Or.;
		(SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1])))
		SE1->E1_SITUACA:= "0"
	ElseIf SEL->EL_BANCO $ (GetNewPar("MV_CARTEIR","")+"/"+Left(GetNewPar("MV_CXFIN",""),TamSX3("A6_COD")[1]))
		SE1->E1_SITUACA:= "0"
	Else
		SE1->E1_SITUACA:= "0"
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo para o tempo de Clearing, o tempo de Clearing estaณ
	//ณsendo calculado somente com dias uteis corridos.          ณ
	//ณSe o Tempo for de mais de uma semana, coloco uma data de  ณ
	//ณaqui a dez anos assim tem que ser acreditado manualmente. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If cTipoCred == "1"
		SE1->E1_DTACRED:=dDatabase
	ElseIf cTipoCred == "2"
		SE1->E1_DTACRED:=DataValida(SEL->EL_DTVCTO)
	ElseIf cTipoCred == "3"
		nDias:=Val(SEL->EL_ACREBAN)
		dBase:=  SE1->E1_VENCREA
		If nDias > 5
			dBase += 3650
		Else
			aFeriados:=RetFeriados()
			While nDias > 0
				dBase++
				If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
					nDias--
				EndIf
			EndDo
		Endif
		SE1->E1_DTACRED:= dBase
	EndIf
	
	SE1->E1_ORIGEM := "FINA840"
	
	If (cPaisLoc == "CHI")
		SE1->E1_VLCRUZ := Round( SEL->EL_VLMOED1, MsDecimais(1) )
	Else
		SE1->E1_VLCRUZ := SEL->EL_VLMOED1
	EndIf
	
	SE1->E1_LA     := "S"
	SE1->E1_STATUS := IF(SE1->E1_SALDO<=0,"B","A")
	SE1->E1_MOVIMEN:= SE1->E1_DTACRED
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIntegracao com SigaLoja que grava o numero da NF no campo ณ
	//ณE1_NUM. Apos a emissao da NF, a referencia passa a ser o  ณ
	//ณnumero do cheque - Loc. Paraguai                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	If cPaisLoc == "PAR"
		If AllTrim(SEL->EL_TIPODOC) == "CH"
			SE1->E1_NUMCHQ := SE1->E1_NUM
		EndIf
	EndIf		      
	MsUnLock()
	If ExistBlock('F840SE1')
		ExecBLock('F840SE1',.F.,.F.)
	Endif	
	FKCOMMIT()
	If SE1->E1_SITUACA=="1"
		SEA->(DbSetOrder(1))
		// PEL Verificar este seek!!! Duplicate Key toda vez..
		If SEA->(DbSeek(xFilial("SEA")+Space(Len(SEA->EA_NUMBOR))+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPODOC))
			RecLock("SEA",.F.)
			SEA->EA_DATABOR := SEL->EL_DTVCTO
			SEA->EA_PORTADO := SEL->EL_BANCO
			SEA->EA_AGEDEP  := SEL->EL_AGENCIA
			SEA->EA_NUMCON  := SEL->EL_CONTA
			SEA->EA_TIPO    := SEL->EL_TIPODOC
			SEA->EA_CART    := "R"
			SEA->EA_SITUACA := "1"
			SEA->EA_FILORIG := SE1->E1_FILIAL
			MsUnlock()
			FKCOMMIT()
		Else
			If ! Empty(SEL->EL_BANCO)
				RecLock("SEA",.T.)
				SEA->EA_FILIAL  := xFilial("SEA")
				SEA->EA_DATABOR := SEL->EL_DTVCTO
				SEA->EA_PORTADO := SEL->EL_BANCO
				SEA->EA_AGEDEP  := SEL->EL_AGENCIA
				SEA->EA_NUMCON  := SEL->EL_CONTA
				SEA->EA_NUM     := SEL->EL_NUMERO
				SEA->EA_PARCELA := SEL->EL_PARCELA
				SEA->EA_PREFIXO := SEL->EL_PREFIXO
				SEA->EA_TIPO    := SEL->EL_TIPODOC
				SEA->EA_CART    := "R"
				SEA->EA_SITUACA := "1"
				SEA->EA_FILORIG := SE1->E1_FILIAL
				MsUnlock()
				FKCOMMIT()
			EndIf
		EndIf		
	EndIf     
	If !cTipoCred $ "1|2"		
		AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTxMoed[SE1->E1_MOEDA],SE1->E1_EMISSAO)
	EndIf
	  
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin840RtTpบAutor  ณMicrosiga           บ Data ณ  08/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho do campo EL_TIPODOC                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAFIN                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fin840RtTp(cTipoFJS,cCampo)

	Local cRet		:= ""
	Local cTipo		:= ""
	Local aSaveArea	:= GetArea()
	
	If AliasInDic("FJS")
		If cCampo == "EL_TIPODOC"
			cRet := GetAdvFVal("FJS","FJS_TIPOIN",xFilial("FJS")+PadR(cTipoFJS,TamSx3("FJS_TIPOIN")[1]),1,"")		
		ElseIf cCampo == "EL_PREFIXO"
			cTipo := Posicione("FJS",1,xFilial("FJS")+cTipoFJS,"FJS_TIPOIN")
			If cTipo == "DC" //Pagar้ 
				cRet := "PGR"
			Else
				cRet := CRIAVAR("EL_PREFIXO",.F.)
			EndIf
		EndIf
	EndIf
	
	RestArea(aSaveArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin840SEF บAutor  ณJair Ribeiro        บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar registro no SEF para cheques						  บฑฑ
ฑฑบ          ณ 							                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fin840SEF(_cCredInm)

	Local nDias		:= Val(SEL->EL_ACREBAN)
	Local dBase		:= SEL->EL_DTVCTO
	Local aFeriados	:= RetFeriados() 
	Default _cCredInm := ""
	
	While nDias > 0
		dBase++
		If Ascan(aFeriados,Dtos(dBase)) == 0 .And. Dow(dBase) <> 1 .And. Dow(dBase) <> 7
			nDias--
		EndIf
	EndDo
	If AliasInDic("SEF")
		SEF->(RecLock("SEF", .T.))
		Replace SEF->EF_FILIAL		WITH xFilial("SEF")
		Replace SEF->EF_BANCO		WITH SEL->EL_BCOCHQ
		Replace SEF->EF_AGENCIA		WITH SEL->EL_AGECHQ
		Replace SEF->EF_CONTA		WITH SEL->EL_CTACHQ
		Replace SEF->EF_NUM			WITH SEL->EL_NUMERO
		Replace SEF->EF_VALOR		WITH SEL->EL_VALOR
		If cPaisLoc == "ARG"
			Replace SEF->EF_DATA	WITH Iif(SEL->EL_EMISSAO < dDatabase,SEL->EL_EMISSAO,dDatabase)
			Replace SEF->EF_VENCTO	WITH DATAVALIDA(SEL->EL_DTVCTO)
		Else
			Replace SEF->EF_DATA	WITH dDatabase
			Replace SEF->EF_VENCTO	WITH dBase
		EndIf	
		Replace SEF->EF_BENEF		WITH SM0->M0_NOMECOM
		Replace SEF->EF_CART		WITH "R"  
		Replace SEF->EF_LA			WITH "S"  
		Replace SEF->EF_LIBER		WITH "S"
		Replace SEF->EF_SEQUENC		WITH "01"
		Replace SEF->EF_TEL			WITH GetAdvFVal("SA1","A1_TEL",xFilial("SA1")+PadR(SEL->EL_CLIENTE,TamSx3("A1_COD")[1])+PadR(SEL->EL_LOJA,TamSx3("A1_LOJA")[1]),1,"")
		Replace SEF->EF_PREFIXO		WITH SEL->EL_PREFIXO
		Replace SEF->EF_TITULO		WITH SEL->EL_RECIBO
		Replace SEF->EF_TIPO		WITH SEL->EL_TIPODOC
		Replace SEF->EF_PARCELA		WITH SEL->EL_PARCELA
		Replace SEF->EF_CLIENTE		WITH SEL->EL_CLIENTE
		Replace SEF->EF_LOJACLI		WITH SEL->EL_LOJA
		Replace SEF->EF_TERCEIR		WITH .F.
		Replace SEF->EF_EMITENT		WITH GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+PadR(SEL->EL_CLIENTE,TamSx3("A1_COD")[1])+PadR(SEL->EL_LOJA,TamSx3("A1_LOJA")[1]),1,"")
		Replace SEF->EF_CPFCNPJ		WITH GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+PadR(SEL->EL_CLIENTE,TamSx3("A1_COD")[1])+PadR(SEL->EL_LOJA,TamSx3("A1_LOJA")[1]),1,"")
		Replace SEF->EF_HIST   		WITH "Recibo "+SEL->EL_RECIBO
		Replace SEF->EF_ORIGEM		WITH "FINA840"  
		Replace SEF->EF_IDSEF 		WITH FWUUIDV4() //Identificador Unico do Titulo
		If SEL->EL_TIPO $ IIf(Type("cCredInm") == "U",_cCredInm,cCredInm)
			Replace SEF->EF_STATUS  WITH "04"
		Else
			Replace SEF->EF_STATUS  WITH "01"
		Endif 
		Replace SEF->EF_NATUR		WITH SEL->EL_NATUREZ
		Replace SEF->EF_PORTADO		WITH SEL->EL_BANCO 
		Replace SEF->EF_ENDOSSA		WITH SEL->EL_ENDOSSA
		Replace SEF->EF_TERCEIR		WITH Iif(SEL->EL_TERCEIR == "2",.T.,.F.)
		If SEF->EF_ENDOSSA=="1"
			Replace SEF->EF_CPFCNPJ	WITH SEL->EL_CGC
		Endif
		//---- Gravacao de ENTIDADES BANCARIAS (Junho/2012)
		If cPaisLoc == "ARG"  
			Replace SEF->EF_POSTAL	WITH SEL->EL_POSTAL
		EndIf
		//---- FIM da Gravacao de ENTIDADES BANCARIAS 
		SEF->(MSUnlock())
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF840RelPGRบAutor  ณMarcos R. Pires     บ Data ณ  17/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a rela็ใo de Pagar้s gerados para o cliente          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840RelPGR(aRecibPGR)

	Local aSaveArea	:= GetArea()
	Local aSaveSA1	:= SA1->(GetArea())
	Local cTitulo	:= STR0192 //"Rela็ใo de documentos gerados"
	Local cNomeCli	:= ""
	Local nX		:= 0
	Local oLbPGR         
	
	Default aRecibPGR := {}
	
	Private oDlgPGR
	
	cNomeCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
	
	DEFINE MSDIALOG oDlgPGR TITLE cTitulo FROM 0,0 TO 400,700 OF oMainWnd PIXEL
	
	//Label
	@ 005, 005 TO 45, 348 LABEL STR0018 OF oDlgPGR PIXEL //"Cliente"
	
	//Titulos dos campos
	@ 017, 010 SAY OemToAnsi(STR0193)	SIZE 140, 007 OF oDlgPGR PIXEL //"C๓digo"
	@ 017, 095 SAY OemToAnsi(STR0194)	SIZE 140, 007 OF oDlgPGR PIXEL //"Razใo social"
	
	//Campos
	@ 026, 010 MSGet cCliente					SIZE 045, 008 OF oDlgPGR WHEN .F. PIXEL
	@ 026, 055 MSGet cLoja						SIZE 027, 008 OF oDlgPGR WHEN .F. PIXEL
	@ 026, 095 MSGet cNomeCli					SIZE 248, 008 OF oDlgPGR WHEN .F. PIXEL
	
	//ListBox
	@ 055,005 LISTBOX oLbPGR FIELDS HEADER	OemToAnsi(STR0195)/*Tipo Tit.*/,;
	OemToAnsi(STR0196)/*Prefixo*/,;
	OemToAnsi(STR0197)/*Numero*/,;
	OemToAnsi(STR0198)/*Vencimento*/,;
	OemToAnsi(STR0176)/*Valor*/,;
	OemToAnsi(STR0199)/*Moeda*/;
	SIZE 343,123 OF oDlgPGR PIXEL
	
	oLbPGR:SetArray(aRecibPGR)
	oLbPGR:bLine := { || {	aRecibPGR[oLbPGR:nAt,1],;
	aRecibPGR[oLbPGR:nAt,2],;
	aRecibPGR[oLbPGR:nAt,3],;
	aRecibPGR[oLbPGR:nAt,4],;
	aRecibPGR[oLbPGR:nAt,5],;
	aRecibPGR[oLbPGR:nAt,6]}}
	
	DEFINE SBUTTON FROM 183,322 TYPE 1 ACTION oDlgPGR:End() ENABLE OF oDlgPGR
	ACTIVATE MSDIALOG oDlgPGR CENTERED
	
	RestArea(aSaveSA1)
	RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetIndicesบAutor  ณ Marylly A. Silva   บ Data ณ  30/12/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ OBTEM OS INDICES DAS TABELAS                               บฑฑ
ฑฑบ          ณ UTILIZADA PARA SIMULACAO DE LANCOS CONTABEIS (ARGENTTINA)  บฑฑ
ฑฑบ          ณ (Corre็ใo do Problema de Restaura็ใo de อndices da simula- บฑฑ
ฑฑบ          ณ ็ใo da contabiliza็ใo na rotina de recibos de cobran็a)	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetIndices(cAlias)

	Local aIndices	:= {}
	
	SIX->(dbSetOrder(1))
	If SIX->(MsSeek(cAlias+"1"))
		aIndices := {}
		While !(SIX->(EOF())) .AND.  SIX->INDICE == cAlias
			AADD(aIndices, SIX->CHAVE)
			SIX->(DBSkip())
		Enddo
	EndIf

Return(aIndices)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA840   บAutor  ณMicrosiga           บ Data ณ  04/13/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F840VldNat(cNatur,cCalcITF,lNatureza)

	Local lRet := .T.
	Local lVazio := .T.
	
	DEFAULT cNatur := ""
	DEFAULT cCalcITF := ""
	DEFAULT lNatureza := .F.
	
	//Define se a natureza pode ou nao ser vazia
	lVazio := IIf(cPaisLoc=="PER" .AND. AllTrim(cCalcITF) == "1", .F.,.T.)
	
	//Verifica se a natureza calcula ITF
	If cPaisLoc=="PER" .AND. AllTrim(cCalcITF) == "1"
		CkNatureza(cNatur,@lNatureza)
	Endif
	
	//294 - Natureza sintetica/Analitica
	If !(FinVldNat( lVazio, cNatur ))
		lRet := .F.
	Endif

	If lRet .and. !(ExistCpo("SED",cNatur)) 
		lRet := .F.
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinTipoIntบAutor  ณMicrosiga           บ Data ณ  08/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna combo para tipo interno de movimentacao do         บฑฑ
ฑฑบ          ณ financeiro - Usado para o cadastro de MODO DE PAGO         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinTipoInt()

	Local cCombo := ""       
	
	cCombo := FinTipInt()

Return cCombo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ A840TWhen  ณ Autor ณ Carlos Eduardo Chigres      ณ Data ณ 15/06/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Pre Validacao do campo EL_AGECHQ e E5_AGECHQ.                      ณฑฑ
ฑฑณ          ณ Objetivo: desabilitar a Edicao na Localizacao ARGENTINA, para      ณฑฑ
ฑฑณ          ณ que o preenchimento seja realizado pela Consulta Padrao FJN.       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                       						              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Programador  ณ Data   ณ BOPS ณ          Manutencoes efetuadas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A840TWhen()

	Local l840Twhen := .T.  
	//--- Por default, sempre permite a edicao
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ 29/08/2012: O campo Agencia cheque eh comum para 3 rotinas ณ
	//ณ                                                            ณ
	//ณ Fina087a -> NAO deve efetuar a validacao chamado a tabela  ณ
	//ณ             de Entidades bancarias                         ณ
	//ณ Fina840 -> sim, deve chamar a tabela Entidades bancarias   ณ
	//ณ Fina100 -> sim, deve chamar a tabela Entidades bancarias   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local lNoValid := IsInCallStack( "FINA840" ) .OR. IsInCallStack( "FINA100" )	
	
	If lNoValid .And. ( cPaisLoc == "ARG" ) .And. AliasInDic( "FJN" ) // Implementacao depende da Criacao da tabela FJN - Entidades Bancarias de Terceiros
		l840Twhen := .F.  
	EndIf

Return (l840Twhen)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ fa840Bco   ณ Autor ณ Carlos Eduardo Chigres      ณ Data ณ 12/07/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao do campo EL_BCOCHQ                                       ณฑฑ
ฑฑณ          ณ Objetivo: desabilitar a Edicao na Localizacao ARGENTINA, para      ณฑฑ
ฑฑณ          ณ que o preenchimento seja realizado pela Consulta Padrao FJN.       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA840                       						              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Programador  ณ Data   ณ BOPS ณ          Manutencoes efetuadas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function fa840Bco()

	//--- Retorno
	Local lReto := .T.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ 29/08/2012 : O campo Banco cheque eh comum para 2 rotinas, ณ
	//ณ                                                            ณ
	//ณ Fina087a -> NAO deve efetuar a validacao chamado a tabela  ณ
	//ณ             de Entidades bancarias                         ณ
	//ณ Fina840 -> sim, deve chamar a tabela Entidades bancarias   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local lNoValid := IsInCallStack( "FINA840" )	
	
	//--- Genericas
	Local nPosAgeChq := AScan( aHeader, {|x|Alltrim( x[2] ) == "EL_AGECHQ" } )
	Local nPosPostal := 0
	
	Local xConten := &(ReadVar())
	
	If lNoValid .And. ( cPaisLoc == "ARG" )
		nPosPostal := AScan( aHeader, {|x|Alltrim( x[2] ) == "EL_POSTAL" } )
		//--- Se existir conteudo informado manualmente no campo EL_BCOCHQ
		If !Empty( xConten )
		aArea:=GetArea()       
       		If Empty( aCols[ n ][ nPosAgeChq ] ) .OR. Empty( aCols[ n ][ nPosPostal ] ) .OR. acols[n][nPosAgeChq] <> FJN->FJN_AGENCI .OR. acols[n][nPosPostal] <> FJN->FJN_POSTAL
        		lReto := .F.
				ApMsgAlert( OemToAnsi( STR0209 ) )   // "Por favor, use a consulta padrใo, de forma a preencher os campos de <Agencia> e <Codigo Postal>." 
			EndIf
		RestArea(aArea)
		EndIf
	EndIf

Return( lReto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsFi840  บAutor  ณJandir Deodato      บFecha ณ 04/09/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Caso a integra็ใo com o Totvs Obras e Projetos esteja      บฑฑ
ฑฑบ              ligada chama a tela de rateio do projeto.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsFi840()
	
	Local aSave
	Local bPMSDlg84 :={||PmsDlgRC(3,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_ORIGEM)}//integra็ใo com Totvs obras e projetos
	
	aSave:=GetArea()
	
	M->E1_NUM 		:=SE1->E1_NUM
	M->E1_PREFIXO :=SE1->E1_PREFIXO
	M->E1_FORNECE :=SE1->E1_FORNECE
	M->E1_LOJA		:=SE1->E1_LOJA
	M->E1_ORIGEM	:=SE1->E1_ORIGEM
	M->E1_VALOR	:=SE1->E1_VALOR
	M->E1_MOEDA	:=SE1->E1_MOEDA
	M->E1_TXMOEDA	:=SE1->E1_TXMOEDA
	Eval (bPMSDlg84)
	PMSWriteRC(1,"SE1")
	RestArea(aSave)
	
Return

/*/{Protheus.doc} F840VldVct()
Fun็ใo para valida็ใo das datas de vencimento contra a configura็ใo do tipo de valor
informado no Modo de Pago

@author    Marcos Berto
@version   11.7
@since     30/10/2012	

@param dDtVcto		Data de Vencimento
@param dDtEmiss	Data de Emissao
@param cModoPago	Modo de Pago

@return lRet		Valida็ใo da Data de Vencimento

/*/
Function F840VldVct(dDtVcto,dDtEmiss,cModoPago,aresp,aServMod)

	Local aAreaFJS 	:= {}
	Local lRet 		:= .T.
	
	DEFAULT dDtVcto	:= dDataBase
	DEFAULT dDtEmiss	:= dDataBase
	DEFAULT cModoPago	:= ""
	
	dbSelectArea("FJS")
	
	aAreaFJS := FJS->(GetArea())
	FJS->(dbSetOrder(1))
	
	If FJS->(dbSeek(xFilial("FJS")+cModoPago))
		Do Case
			//Cheques diferidos
			Case FJS->FJS_TIPOIN $ MVCHEQUE .And. FJS->FJS_TPVAL == "2" .And. (dDtVcto <= dDtEmiss .Or. dDtVcto > (dDtEmiss+360))
				lRet := .F.
			//Cheques comuns
			Case FJS->FJS_TIPOIN $ MVCHEQUE .And. FJS->FJS_TPVAL == "1" .And. dDtVcto <> dDtEmiss 
				lRet := .F.
			//Outros pagamentos diferidos
			Case !(FJS->FJS_TIPOIN $ MVCHEQUE) .And. FJS->FJS_TPVAL == "2" .And. dDtVcto <= dDtEmiss 
				lRet := .F.
			//Outros pagamentos comuns
			Case !(FJS->FJS_TIPOIN $ MVCHEQUE) .And. FJS->FJS_TPVAL == "1" .And. dDtVcto <> dDtEmiss 
				lRet := .F.
			Case dDtVcto < dDtEmiss
				lRet := .F.	
		EndCase
	EndIf
	
	If !lRet
		//Control de error para TOTVS Recibo
		IF FUNNAME() == 'FINA998'
			AADD (aresp, STR0214 )	//"A data de vencimento informada nใo ้ vแlida ou nใo ้ aceita para o Modo de Pago utilizado."
			AADD (aresp, lRet)
		ELSE
			MsgAlert(STR0214) //"A data de vencimento informada nใo ้ vแlida ou nใo ้ aceita para o Modo de Pago utilizado."
		ENDIF
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA840TpBcoบAutor  ณMicrosiga           บ Data ณ  05/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o tipo de banco do modo de pago (FJS)e do banco(SA6)บฑฑ
ฑฑบ          ณ Projeto: M11.7CTR01 Requisito: 1421.5                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA840TpBco(cTipModPag,cCodBanco,cCodAgenc,cCodConta)
	
	Local lRet			:= .T.
	Local aSaveArea 	:= GetArea()
	Local cFJSTipBco	:= ""
	Local cSA6TipBco	:= ""
	
	Default cTipModPag	:= CriaVar("FJS_TIPO"	,.F.)
	Default cCodBanco	:= CriaVar("A6_COD"		,.F.)
	Default cCodAgenc	:= CriaVar("A6_AGENCIA"	,.F.)
	Default cCodConta	:= CriaVar("A6_NUMCON"	,.F.)


If cPaisLoc $ "ANG|ARG|AUS|BOL|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|TRI|URU|VEN"
	
	//Verifica se os campos existem na base
	//Verifica se todos campos estao preenchidos
	If !Empty(cTipModPag) .And. !Empty(cCodBanco) .And. !Empty(cCodAgenc) .And. !Empty(cCodConta)
		cFJSTipBco := GetAdvFVal("FJS","FJS_TIPBCO"	,XFilial("FJS")+cTipModPag						,1,"")
		cSA6TipBco := GetAdvFVal("SA6","A6_TIPBCO"	,XFilial("SA6")+cCodBanco+cCodAgenc+cCodConta	,1,"")
			If !Empty(cFJSTipBco) .And. (cFJSTipBco <> cSA6TipBco)
			lRet := .F.
			Help(" ",1,"SA6TIPBCO")
		EndIf
	EndIf

EndIf
	
RestArea(aSaveArea)


Return(lRet)


/*/{Protheus.doc}F840GETDESC
Retorna descri็ใo do campo posicionado na SX3.

@author Lucas de Oliveiva
@since  02/12/2013
@version 11.90
/*/
Static Function F840GETDESC(cCampo)
	Local aArea := SX3->(GetArea())
	Local cDescric := ""
	
	SX3->(dbsetorder(2))
	SX3->(MsSeek(cCampo))
	cDescric := ALLTRIM(SX3->(X3DESCRIC()))
	
	RestArea(aArea)

Return(cDescric)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ                                                                         ฑฑ
ฑฑ            Funcoes retiradas do arquivo FINXFUN.PRX                     ฑฑ
ฑฑ                                                                         ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinTipoIntบAutor  ณMicrosiga           บ Data ณ  08/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna combo para tipo interno de movimentacao do         บฑฑ
ฑฑบ          ณ financeiro                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinTipInt()
	
Local cCombo  := ""                
Local cRotina := FunName()
	
If cPaisLoc == "ARG"
	cCombo += OemToAnsi(STR0264) //CH=Cheque;RI=Retencion IVA;RG=Retencion Ganancias;RB=Retencion Ing.Brutos;RS=SUSS;EF=Valores;TF=Deposito;GR=Granos

	If cRotina $ "FINA025|FINA840|FINA087A|FINA846|FINA998|FINA887" .and. SFE->(FieldPos("FE_RET_MUN"))>0 .and. SEL->(FieldPos("EL_RET_MUN"))>0
		cCombo += OemToAnsi(STR0265) //;RM=Retencion Municipal
	EndIf
		//A rotina FINA087a NAO devera ser incluida nessa validacao, pois nao possui implementacao do Pagare
	If cRotina $ "FINA025|FINA840|FINA846|FINA998|FINA887"
		cCombo += OemToAnsi(STR0266) //;DC=Documento
	EndIf
	
ElseIf cPaisLoc == "PAR"
	cCombo += OemToAnsi(STR0267) //EF=Efectivo;TF=Transferencia;CH=Cheque;RI=Retencion IVA;RR=Retencion Imp Renta
ElseIf cPaisLoc $ "COS|MEX|CHI|"
	cCombo += OemToAnsi(STR0252) //"CH=Cheque;TF=Deposito;EF=En Efectivo"
	If cPaisLoc $ "MEX"
		cCombo += OemToAnsi(STR0277) //";CO=Compensaci๓n"
	EndIf
ElseIf cPaisLoc == "PER"
	If MVCHEQUE <> Nil
		cCombo += OemToAnsi(AllTrim(MVCHEQUE)+"="+STR0258+";"+STR0259) //"Cheque" - "EF=Efectivo;TF=Transferencia;RI=Retencion IGV"
	Else
		cCombo += OemToAnsi(STR0259) //"EF=Efectivo;TF=Transferencia;RI=Retencion IGV"
	EndIf
ElseIf cPaisLoc == "COL"
	If MVCHEQUE <> Nil
	 	cCombo += OemToAnsi(AllTrim(MVCHEQUE)+"="+SubStr( STR0236,4)) //"Cheque" -"EF=Valores;TF=Dep๓sito;DC=Documento;CC=Tarjeta cr้dito;CD=Tarjeta d้bito"
	Else
		cCombo += OemToAnsi(SubStr(STR0236, 11)) //"EF=Valores;TF=Dep๓sito;DC=Documento;CC=Tarjeta cr้dito;CD=Tarjeta d้bito"
	EndIf	
Else
	If cPaisLoc == "BOL" 
		cCombo += OemToAnsi(STR0261) //"CH=Cheque;TF=Deposito;EF=En Efectivo;CC=Cartao"
	Else
		cCombo += OemToAnsi(STR0236) //"EF=Valores;TF=Dep๓sito;DC=Documento;CC=Cartใo cr้dito;CD=Cartใo d้bito"
	EndIF	
EndIf	
	
If ExistBlock("F840TPI")	
	cCombo:=ExecBlock("F840TPI",.F.,.F.,{cCombo})
EndIf
		
Return cCombo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetValRet บAutor  ณMicrosiga           บ Data ณ  08/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna el Valor de Retenciones.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetValRet()

	Local cCampo := Alltrim(ReadVar())
	Local nPosBaseR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_VALBASE"})
	Local nPosAliqR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "FE_ALIQ"})
	Local nPosValR	:= AScan(aHeader,{|x|Alltrim(x[2]) == "EL_VALOR"})
	Local lRet := .T.
	
	If "M->EL_VALOR" $ cCampo 
		If ( aCols[n][nPosBaseR] > 0 )
			aCols[n][nPosAliqR] := ( M->EL_VALOR / aCols[n][nPosBaseR] ) * 100
		ElseIf aCols[n][nPosBaseR] > 0
			aCols[n][nPosBaseR] := ( M->EL_VALOR / aCols[n][nPosAliqR] ) * 100
		EndIf 	
	ElseIf "M->FE_VALBASE" $ cCampo
		If ( aCols[n][nPosValR] > 0 )
			aCols[n][nPosAliqR] := ( aCols[n][nPosValR] / M->FE_VALBASE ) * 100
		ElseIF ( aCols[n][nPosAliqR] > 0 )
			aCols[n][nPosValR] := ( M->FE_VALBASE * aCols[n][nPosAliqR]  )	/ 100	
		EndIf
	ElseIf "M->FE_ALIQ" $ cCampo
		If ( aCols[n][nPosBaseR] > 0 )
			aCols[n][nPosValR] := ( aCols[n][nPosBaseR] * M->FE_ALIQ  )	/ 100	
		ElseIf( aCols[n][nPosValR] > 0 )
			aCols[n][nPosBaseR] := ( aCols[n][nPosValR] / M->FE_ALIQ ) * 100	
		EndIf	
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldCerSUSSบAutor  ณLaura Medina        บ Data ณ  02/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcion para validar el certificado (25 posiciones) y que  บฑฑ
ฑฑบ          ณ cotenga el CGC del cliente.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCerSUSS()

	Local nPosTpDoc := 0
	Local nPosNum   := 0
	Local nPosSIRES := 0
	Local lRet      := .T.

	nPosTpDoc 	:= AScan(aHeader, {|x| Alltrim(x[2]) == "EL_TIPODOC"})
	nPosSIRES	:= AScan(aHeader, {|x| Alltrim(x[2]) == "EL_SIRESEG"})  //Cod. Seg. SIRE
	nPosNum	    := AScan(aHeader, {|x| Alltrim(x[2]) == "EL_SIRECER"})  //Nro. Certificado SIRE
	
	If Alltrim(aCols[n][nPosTpDoc]) == "RS"
		If  Len(Alltrim(aCols[n][nPosNum])) < 25
			Help("", 1, "CERTSUSSVAZIO")
			lRet := .F.
		ElseIf Empty(Alltrim(aCols[n][nPosSIRES]))
			Help("", 1, "SEGSUSSVAZIO")
			lRet := .F.	
		Else
			If !(Alltrim(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CGC")) $ Alltrim(aCols[n][nPosNum]))           
				Help("", 1, "CERTSUSSVALID")
				lRet := .F.
			EndIf 
		EndIf	
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณfIvaPosdatado  บAutor  ณAdrian Perez H. บ Data ณ  01/22/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Asignacion de valor del tipo de  IvaPosdatado       .      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros utilizados en la funcion                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ cNum	- N๚mero de documento                         ณ
//ณ cPrex	- Prefijo de documento                        ณ
//ณ cCliente- Cliente infromado en documento              ณ
//ณ cLoja	- Tienda  informada en documento              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna cDato, tipo de Iva posdatado 			.	  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

Static Function fIvaPosdatado(cNum,cPrex,cCliente,cLoja,lRaGR)
Local cDato:="0"
Default lRaGR := .F. 

aSF2area:=SF2->(GetArea()) 
DbSelectArea("SF2")
SF2->(dbSetOrder(1))
If Alltrim(SE1->E1_TIPO) <> "RA" .And. SF2->(dbSeek(xFilial("SF2")+cNum+cPrex+cCliente+cLoja)) // +SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA
	If ALLTRIM(SF2->F2_CANJE) == "1" .And. (SE1->E1_SALDO == SE1->E1_VALOR)
		
		If ALLTRIM(aCols[1][1])=="GR" .or. lRaGR
		 	cDato:="1"
		Else
		 	cDato:="2"
		EndIf
		
	Else
		
		If ALLTRIM(aCols[1][1])=="GR" .or. lRaGR
		 	cDato:="3"
		Else
		 	cDato:="0"
		EndIf
			
	EndIf
EndIf

SF2->(RestArea(aSF2area))
 
Return cDato
/*/{Protheus.doc} Fna840LibM
Funci๓n utilizada para validar la fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     alejandro.parrales
@since      2021
@version    1.0v
@return     _lMetric, l๓gico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function Fna840LibM()
	If _lMetric == Nil 
		_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	EndIf
Return _lMetric
