#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETPGTOS  ºAutor  ³Marcello            ºFecha ³ 31/10/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor efetivamente pago das notas fiscais com baseº±±
±±º          ³nas parcelas pagas                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³            Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³11/05/11³  SCOEU7  ³Modificacion para que considere el IVA Exen-³±±
±±³            ³        ³  SCVKRH  ³y la tasa cero.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³16/05/11³  SDKSD6  ³Se hizo un cambio para que calcule correcta-³±±
±±³            ³        ³          ³mente la Base e IVA retenido cuando se utili³±±
±±³            ³        ³          ³documentos NDP (si en el mismo pago se inclu³±±
±±³            ³        ³          ³ye este documento).                         ³±±
±±³Laura Medina³17/05/11³  SDKTAD  ³Cambio para que considere los descuentos en ³±±
±±³            ³        ³          ³productos para la base del DIOT.            ³±±
±±³Laura Medina³15/06/11³  SDPXVZ  ³Cambio para que tome correctamente la base  ³±±
±±³            ³        ³          ³cuando se genera la OP en dll y se paga en  ³±±
±±³            ³        ³          ³banco en moneda1.                           ³±±
±±³Laura Medina³27/06/11³  SDKF67  ³Cambio para que imprima el IVA exento en la ³±±
±±³            ³        ³          ³columna del resumen.                        ³±±
±±³Laura Medina³04/07/11³  SDSQS9  ³Correcion de un detalle que salio como conse³±±
±±³            ³        ³          ³cuencia de la correcion del llamado SDPXVZ. ³±±
±±³Laura Medina³07/07/11³  SDSLHQ  ³Cambio para omitir del proceso los casos de ³±±
±±³            ³        ³          ³IVA NO AFECTO (dependiendo de un campo -SFB)³±±
±±³            ³07/07/11³  SDSLHQ  ³Se modifico el programa para que agrupe co- ³±±
±±³            ³        ³          ³rrectamente las bases e IVA 0 y Exento.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³04/08/11³  TDL482  ³ Cambio para que t.ome en cuenta la TC de   ³±±
±±³            ³        ³          ³ la orden de pago cuando se pacta una TC    ³±±
±±³            ³        ³          ³ y se debita en el momento.                 ³±±
±±³A. Rodriguez³19/08/11³  TDL482  ³-Si la tabla SA6 tiene el campo A6_NUMCH    ³±±
±±³            ³        ³          ³ SE5 y SEK graba no.cheque en vez de no.OP  ³±±
±±³A. Rodriguez³22/08/11³  TDNCNR  ³-EF/TF: Si monedas diferentes y pago en MN;	³±±
±±³            ³        ³          ³ aplica con tc pactada.						³±±  
±±³A. Rodriguez³05/09/11³  TDPAJR  ³-Debitación cheque posterior en proveedores	³±±
±±³            ³        ³          ³ con doctos de mismo número.				³±±
±±³Laura Medina³13/10/11³  TDNCNU  ³ Cambio para que t.ome en cuenta el IVA RET ³±±
±±³            ³        ³          ³ en una NCP (como negativo).                ³±±
±±³Laura Medina³18/10/11³  TDVCCY  ³ Se agrego validacion para que considere la ³±±
±±³            ³        ³          ³ TC cuando se genera OP con transferencia.  ³±±  
±±³A. Rodriguez³25/10/11³  TDNCNR  ³-Error: Variable does not exist EK_TXMOE01	³±±
±±³            ³        ³          ³ EK_MOEDA -> cMoeda, E5_MOEDA -> EK_TXMOE## ³±±
±±³Laura Medina³28/10/11³  TDWSTY  ³ Cambio para que tome correcta la base cuan-³±±
±±³            ³        ³          ³ do en un documento existe mas de producto  ³±±
±±³            ³        ³          ³ con IVA 0%.                                ³±±
±±³Laura Medina³31/10/11³  TDWTM9  ³ Modificación para que calcule correctamente³±±
±±³            ³        ³          ³ la base del DIOT cuando se hace una compen-³±±  
±±³            ³        ³          ³ sación y se aplica la reversión.           ³±±
±±³Laura Medina³11/11/11³  TDWS17  ³ Cambio para que cuando exista un NF con IVA³±±
±±³            ³        ³          ³ NO AFECTO y cuando se salde de la NF y se  ³±±
±±³            ³        ³          ³ hagan 2 pagos, calculo correctamente la ba-³±±
±±³            ³        ³          ³ se excluyendo el IVA NO AFECTO.            ³±±
±±³Laura Medina³14/11/11³  TDWYKK  ³ Cambio para procesar mov fuera del periodo ³±±
±±³            ³        ³          ³ pero que fueron debitados dentro, y se im- ³±±
±±³            ³        ³          ³ priman dichos mov con fecha del débito.    ³±±
±±³            ³22/11/11³          ³ Modificacion para que considere en las com-³±±
±±³            ³        ³          ³ pensaciones la TC del débito y no la de la ³±±
±±³            ³        ³          ³ compensacion.                              ³±±
±±³Laura Medina³09/02/12³  TEMRY3  ³ Modificacion para que se tome la TC pactada³±±
±±³            ³        ³          ³ al momento de hacer una compensacion y no  ³±±
±±³            ³        ³          ³ la del día de la compensacion.             ³±±
±±³A. Rodriguez³10/04/12³  TERH02  ³-P11: Manejo de filiales					³±±
±±³            ³        ³          ³-Paridad en Facturas USD y ordenes de pago  ³±±
±±³            ³        ³          ³ misma fecha con cualquier forma de pago    ³±±
±±³Laura Medina³17/04/12³  TEUWMT  ³ Modificacion para que no convierta a moneda³±±
±±³            ³        ³          ³ 02 cuando es una compensacion porque el va-³±±
±±³            ³        ³          ³ lor ya viene en moneda 1.                  ³±±
±±³Laura Medina³18/04/12³  TEVNVV  ³ Modificacion para que convierta con la tasa³±±
±±³            ³        ³          ³ de cambio pactada, en caso de que exista.  ³±±
±±³Laura Medina³27/11/12³  TGDBV6  ³ Filtrar empresa.                           ³±±
±±³Laura Medina³30/01/13³  TGOC72  ³ Agregar PE en Pagos, si no se encuentra el ³±±
±±³            ³        ³  P10     ³ movimiento en la tabla SF1, validara si    ³±±
±±³            ³        ³          ³ existe el PE y se ejecutara.               ³±±
±±³Laura Medina³17/04/13³  THAKVY  ³ Agrupar los registros deproveedores Globa- ³±±
±±³            ³        ³          ³ les por tipo de Operacion y mostrar solo 1 ³±±
±±³            ³        ³          ³ registro de cada uno.                      ³±±
±±³Laura Medina³07/05/13³  THAKXZ  ³ Se modifico para que cuando sea TF o EF no ³±±
±±³            ³        ³          ³ tome fecha de la TC pactada.               ³±±
±±³Laura Medina³29/08/13³  THTDDW  ³ Se modifico para que tome la TC pactada cu-³±±
±±³            ³12/08/13³          ³ ando la TES sea execta o 0.                ³±±
±±³Laura Medina³20/09/13³  THVKUH  ³ Cambio para que consolide el reporte por   ³±± 
±±³            ³        ³          ³ grupo de sucursales (por razon social).    ³±±
±±³  Marco A.  ³17/01/17³SERINN001 ³ Se clona el Array de Filiales para CTREE   ³±±
±±³            ³        ³-1114     ³ aClone(aFilsCalc) (MEX)                    ³±±
±±³Oscar Garcia³21/05/18³DMINA-2802³Se eliminan #IFNDEF TOP, #IFNDEF TOP        ³±±
±±³            ³        ³          ³y CriaTrab() por SONARQUBE.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RETPGTOS(cForn1,cLoja1,cForn2,cLoja2,dDtIni,dDtFin,cFilIni,cFilFin,cPEFilUsr,cConsol) 
	
	Local nG		:= 0
	Local nFilIni	:= 0
	Local nFilFin	:= 0
	Local cBkpFil	:= ""
	Local aCpyFilsC	:= {}

	Private aDetPag	:= {}

	Default cPEFilUsr := ""

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³aDetPag                                   ³
	³1 - Fornecedor                            ³
	³2 - Loja                                  ³
	³3 - RFC                                   ³
	³4 - CURP                                  ³
	³5 - Notas                                 ³
	³	5.01 - nota                            ³
	³	5.02 - Serie                           ³
	³	5.03 - valbrut (moeda 1)               ³
	³	5.04 - valmerc (moeda 1)               ³
	³	5.05 - moeda                           ³
	³	5.06 - taxa moeda                      ³
	³	5.07 - tipo pagamento (SF4->F4_CLAVPG) ³
	³	5.08 - emissao                         ³
	³	5.09 - especie                         ³
	³	5.10 - valor pago (moeda 1)            ³
	³	5.11 - copensacao (moeda 1)            ³
	³	5.12 - impostos                        ³
	³		5.12.1 - codigo do imposto         ³
	³		5.12.2 - aliquota                  ³
	³		5.12.3 - base (moeda 1)            ³
	³		5.12.4 - valor (moeda 1)           ³
	³6 - Filial                                ³
	³7 - NCP                                   ³
	³	7.1 - notas                            ³
	³	7.2 - serie                            ³
	³	7.3 - emissao                          ³
	³	7.4 - iva                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	Default cForn1	:= ""
	Default cForn2	:= "zzzzzz"
	Default cLoja1	:= ""
	Default cLoja2	:= "zz"
	Default dDtIni	:= Ctod("01/01/" + StrZero(Year(dDataBase),4),"DDMMYYYY")
	Default dDtFin	:= Ctod("31/12/" + StrZero(Year(dDataBase),4),"DDMMYYYY")
	Default cFilIni	:= FWCodFil() // "01"
	Default cFilFin	:= FWCodFil() // "01"

	cBkpFil := cFilAnt
	nFilIni := Val(cFilIni)
	nFilIni := Max(nFilIni,1)
	nFilFin := Val(cFilFin)
	nFilFin := Max(nFilFin,1)
	aDetPag := {}       

	aCpyFilsC := aClone(aFilsCalc) //Copia arreglo con las filiales

	// ARL 10/04/12 - Manejo de filial P11
	For nG := 1 to Len(aCpyFilsC)
		If  aCpyFilsC[nG,1]  //Procesa las filiales marcadas
			If  (Iif(cConsol=="0",aCpyFilsC[nG,2] >= cFilIni .And. aCpyFilsC[nG,2] <= cFilFin,.T.))
				cFilAnt := aCpyFilsC[nG,2]
				RetPagFil(cForn1,cLoja1,cForn2,cLoja2,dDtIni,dDtFin,cPEFilUsr)
				RetNCPs(cForn1,cLoja1,cForn2,cLoja2,dDtIni,dDtFin,cPEFilUsr)
			Endif 
		Endif 
	Next
	cFilAnt := cBkpFil
	
Return (aDetPag)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETPAGFIL ºAutor  ³Marcello            ºFecha ³ 31/10/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor efetivamente pago das notas fiscais com baseº±±
±±º          ³nas parcelas pagas, para a filial corrente                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetPagFil(cForn1,cLoja1,cForn2,cLoja2,dDtIni,dDtFin,cPEFilUsr)
	Local cQuery	:= ""
	Local cQryAux	:= ""
	Local cQryCHV	:= ""
	Local cAliasCHV	:= ""
	Local cAlias	:= ""
	Local cIetuGrp	:= ""
	Local cFilSEK	:= ""
	Local cFilSE5	:= ""
	Local cCpoIVC	:= ""
	Local cCpoIEP	:= ""
	Local cCpoImp	:= ""
	Local cArqTrab	:= ""
	Local cFilUsr	:= ""
	Local cIEPS		:= SubStr(GetNewPar("MV_IEPS ",""),1,3)
	Local nValTit	:= 0
	Local nI		:= 0
	Local nX		:= 0
	Local nTit		:= 0
	Local nPos		:= 0
	Local nPorc		:= 0
	Local nPorcTit	:= 0
	Local nTtlOrd	:= 0
	Local nTtlTits	:= 0
	Local nVlrBase	:= 0
	Local nBaseFat	:= 0
	Local nVlrPago	:= 0
	Local nBaseTit	:= 0
	Local nMoedaBco	:= 0
	Local aTitulos	:= {}
	Local aEstrSE5	:= {}
	Local aImpD1	:= {}
	Local aImpostos	:= {}
	Local lF4clavpg := .F. 
	Local dFechCHDeb:= ctod("//")   //LEMP(04/05/11)    
	Local cTipMoeSEK:= ""           //LEMP(15/06/11)
	Local nVlrMoeSEK:= 0            //LEMP(15/06/11)
	Local lMoedaPac := .F.          //LEMP(01/07/11) 
	Local nTaxaSEK  := 0            //LEMP(04/08/11) 
	Local lChkDebPost := .F.		//ARL 19/08/11 
	Local nEntBase  := 0            //LEMP(28/10/11) 
	Local nEntVal   := 0            //LEMP(28/10/11)  
	Local lLoop     := .F.          //LEMP(14/11/11): No procesar mov que fueron dados de baja fuera del periodo
	Local cFilSE2   := xFilial("SE2")//LEMP(14/11/11)        
	Local cMoeExcep := ""            //LEMP(17/04/12): Excepcion por el tipo de moneda que se graba en SE5
	Local lDIOTSF1P := ExistBlock("DIOTSF1P")	//LEMP(TGOC72-30/01/13):Agregar PE    
	Local aDetPagPE	:= {}			//LEMP(TGOC72-30/01/13)  
	Local lEsTipTer := .F.          //LEMP(THAKVY) 

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Estrutura do array aTitulos:                ³
	³1) Tipo - 1 compensacao; 0 normal           ³
	³2) Ordem de pago                            ³
	³3) Numero do documento (fatura)             ³
	³4) Serie do documento                       ³
	³5) Fornecedor                               ³
	³6) Filial do fornecedor                     ³
	³7) Valor                                    ³
	³8) Especie (CH,EF,TF,NCP,NDI etc)           ³
	³9) Documento (no caso de compensacao, possui³
	³   o documento original da compensacao)     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	SE2->(DbSetOrder(1))
	SA6->(DbSetOrder(1))
	SF1->(DbSetOrder(1))
	SF2->(DbSetOrder(1))
	SD1->(DbSetOrder(1))
	SD2->(DbSetOrder(3))
	cFilSEK := xFilial("SEK")
	SEK->(DbSetOrder(1))
	cFilSE5 := xFilial("SE5")
	SE5->(DbSetORder(7))
	//
	DbSelectArea("SFB")
	DbSetOrder(1)
	SFB->(DbSeek(xFilial("SFB")+"IVC"))
	cCpoIVC := "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
	SFB->(DbSeek(xFilial("SFB")+cIEPS))
	cCpoIEP := "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
	lF4clavpg := (SF4->(FieldPos("F4_CLAVPG")) > 0)

	cQuery := "select E5_DATA,E5_TIPO,E5_TIPODOC,E5_VALOR,E5_MOEDA,E5_VLMOED2,E5_ORDREC,E5_MOTBX,E5_DTDISPO,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_FORNECE,E5_CLIENTE,E5_LOJA,E5_CLIFOR,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_TXMOEDA, E5_DOCUMEN, SE5.R_E_C_N_O_ from " + RetSqlName("SE5")+" SE5 "
	cQuery += " where"
	cQuery += " D_E_L_E_T_=''"
	cQuery += " and E5_FILIAL = '" + cFilSE5 + "'"
	cQuery += " and ("
	cQryAux := "(E5_CLIFOR >= '" + cForn1 + "'"
	cQryAux += " and E5_LOJA >= '" + cLoja1 + "'"
	cQryAux += " and E5_CLIFOR <= '" + cForn2 + "'"
	cQryAux += " and E5_LOJA <= '" + cLoja2 + "'"
	cQryAux += " and E5_DATA >= '" + Dtos(dDtIni) + "'"
	cQryAux += " and E5_DATA <= '" + Dtos(dDtFin) + "'"
	cQryAux += " and (E5_MOTBX = 'NOR' OR E5_MOTBX = 'CMP' )"	//LEMP(17/11/11):Solo procesa Compensacion (PA/NCP) y bajas automaticas (OP)
	cQryAux += " and  E5_SITUACA <> 'C'" 
	cQryAux += " and ("
	cQryAux += " ((E5_TIPODOC in ('VL','BA','CP')) and E5_RECPAG = 'P')"
	cQryAux += " or"
	cQryAux += " (E5_TIPODOC='ES' and E5_RECPAG='R')"
	cQryAux += "))"
	/*
	Ponto de entrada para alteracao do filtro*/
	If !Empty(cPEFilUsr)
		If ExistBlock(cPEFilUsr)
			cFilUsr	:=	ExecBlock(cPeFilUsr,.F.,.F.,{cQryAux,"NOR"})
			If !Empty(cFilUsr)
				cQryAux := cFilUsr
			Endif
		Endif
	Endif
	cQuery += cQryAux + ")"  
	
	/*LEMP(14/11/11):Procesar mov fuera del periodo pero que fueron debitados dentro,
					 La fecha de debito del cheque debe estar dentro del periodo de seleccion (dDtIni y dDtFin)*/
	cQuery += " UNION "  
	cQuery += " select E5_DATA,E5_TIPO,E5_TIPODOC,E5_VALOR,E5_MOEDA,E5_VLMOED2,E5_ORDREC,E5_MOTBX,E5_DTDISPO,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_FORNECE,E5_CLIENTE,E5_LOJA,E5_CLIFOR,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_TXMOEDA, E5_DOCUMEN, SE5.R_E_C_N_O_ "
	cQuery += " from " + RetSqlName("SE5") +" SE5, "+ RetSqlName("SE2") +" SE2,"+ RetSqlName("SEK") + " SEK"
	cQuery += " where"
	cQuery += "     SE5.D_E_L_E_T_=''" 
	cQuery += " and SEK.D_E_L_E_T_=''"
	cQuery += " and SE2.D_E_L_E_T_=''"
	cQuery += " and E5_FILIAL = '"+cFilSE5+"' and EK_FILIAL = '"+cFilSEK+"' and E2_FILIAL = '"+cFilSE2+"' "
	cQuery += " and ("
	cQryAux := "(E5_CLIFOR >= '" + cForn1 + "'"
	cQryAux += " and E5_LOJA >= '" + cLoja1 + "'"
	cQryAux += " and E5_CLIFOR <= '" + cForn2 + "'"
	cQryAux += " and E5_LOJA <= '" + cLoja2 + "'"  
	cQryAux += " and (E5_MOTBX = 'NOR' OR E5_MOTBX = 'CMP' )"	//LEMP(17/11/11):Solo procesa Compensacion (PA/NCP) y bajas automaticas (OP)  
	cQryAux += " and E5_ORDREC  = EK_ORDPAGO"       	
	cQryAux += " and EK_PREFIXO = E2_PREFIXO" 
	cQryAux += " and EK_NUM     = E2_NUM" 
	cQryAux += " and EK_PARCELA = E2_PARCELA" 
	cQryAux += " and EK_TIPO    = E2_TIPO" 
	cQryAux += " and EK_FORNECE = E2_FORNECE" 
	cQryAux += " and EK_LOJA    = E2_LOJA" 	
	cQryAux += " and E2_BAIXA >= '" + Dtos(dDtIni) + "'"
	cQryAux += " and E2_BAIXA <= '" + Dtos(dDtFin) + "'"
	cQryAux += " and  E5_SITUACA <> 'C'" 
	cQryAux += " and ("
	cQryAux += " ((E5_TIPODOC in ('VL','BA','CP')) and E5_RECPAG = 'P')"
	cQryAux += " or"
	cQryAux += " (E5_TIPODOC='ES' and E5_RECPAG='R') )"
	cQryAux += ")"         
	cQuery += cQryAux + ")" 
	//
	cAlias := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	TCSetField(cAlias,"E5_DATA","D",8,0)

	dbSelectArea(cAlias)
	(cAlias)->(DbGotop())
	While !((cAlias)->(Eof()))
		aTitulos   := {}
		nTtlOrd    := 0
		nTtlTits   := 0         
		dFechCHDeb := ctod("//")   //LEMP(04/05/11)
		lMoedaPac  := .F.          //LEMP(01/07/11)
		nTaxaSEK   := 0            //LEMP(04/08/11)
		lChkDebPost:= .F.			//ARL 19/08/11
		cTipMoeSEK := ""			//ARL 06/09/11
		nVlrMoeSEK := 0				//ARL 06/09/11 
		lLoop      := .F.          //LEMP(14/11/11):No procesar mov que fueron dados de baja fuera del periodo
		cMoeExcep  := (cAlias)->E5_MOEDA  //LEMP(17/04/12): Excepcion por el tipo de moneda que se graba en SE5
		//conversao do valor pago para a moeda 1
		SA6->(DbSeek(xFilial("SA6") + (cAlias)->E5_BANCO + (cAlias)->E5_AGENCIA + (cAlias)->E5_CONTA))
		nMoedaBco := If(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
		//LEMP(17/04/12): Excepcion por el tipo de moneda de la tabla SE5
		If   Alltrim((cAlias)->E5_TIPODOC)=='CP' .And. (cAlias)->E5_MOEDA == '02'  
			cMoeExcep :="  " 
		Endif
		If  nMoedaBco == 0 .And. !Empty(cMoeExcep)	// ARL 10/04/12
			nMoedaBco := Val(cMoeExcep)
		Endif     
		//LEMP(18/04/12): Tome la TC pactada (E5_TXMOEDA) y haga el cambio a moneda 1
		If  cMoeExcep != '01' .And. ((cAlias)->E5_TXMOEDA !=1 .And. (cAlias)->E5_TXMOEDA !=0) 
			nValTit := xMoeda((cAlias)->E5_VALOR,nMoedaBco,1,(cAlias)->E5_DATA,MsDecimais(1),(cAlias)->E5_TXMOEDA)
		Else
			nValTit := xMoeda((cAlias)->E5_VALOR,nMoedaBco,1,(cAlias)->E5_DATA,MsDecimais(1))
		Endif
		Do Case                                                                                               
			Case (cAlias)->E5_MOTBX == "CMP"      
			//Porcentagem do valor pago em relacao ao valor total do pagamento
			nPorcTit := 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando uma compensacao e cancelada, e criado um registro de estorno. Este estorno³
			//³e guardado para ser subtraido do valor pago.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(AllTrim((cAlias)->E5_TIPO) $ "NCP|NDI|PA")
				If AllTrim((cAlias)->E5_TIPODOC) == "ES"
					// <ARL 15/02/11>
					nPos := Ascan(aTitulos,{|aTit| aTit[3]+aTit[4]+aTit[5]+aTit[6] == (cAlias)->E5_NUMERO+(cAlias)->E5_PREFIXO+(cAlias)->E5_FORNECE+(cAlias)->E5_LOJA .And. aTit[7] > 0})
					If nPos > 0
						nDtDigit := aTitulos[nPos,11]
					Else
						For nI := 1 to Len(aDetPag)
							nPos := Ascan(aDetPag[nI,5],{|aPag| aPag[1]+aPag[2]+aDetPag[nI,1]+aDetPag[nI,2] == (cAlias)->E5_NUMERO+(cAlias)->E5_PREFIXO+(cAlias)->E5_FORNECE+(cAlias)->E5_LOJA .And. aPag[4] > 0})
							If nPos > 0
								Exit
							Endif
						Next
						nDtDigit := If(nPos == 0, (cAlias)->E5_DATA, aDetPag[nI,5,nPos,13])
					Endif
					Aadd(aTitulos,{0,"",(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_FORNECE,(cAlias)->E5_LOJA,-nValTit,1,(cAlias)->E5_TIPO,"",nDtDigit})
					// <\ARL>
				Else    // E5_TIPODOC == "CP" Compensacion
					Aadd(aTitulos,{0,"",(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_FORNECE,(cAlias)->E5_LOJA, nValTit,1,(cAlias)->E5_TIPO,"",(cAlias)->E5_DATA})
				Endif
				//LEMP(22/11/11):Tome en cuenta la TC del día del debito.
				If !Empty((cAlias)->E5_TXMOEDA) .And. (cAlias)->E5_TXMOEDA != 1
					// Baja/Estorno: Tasa pactada
					nTaxaSEK := (cAlias)->E5_TXMOEDA
				Endif     
			Endif
			Case (cAlias)->E5_MOTBX == "NOR"
			If !Empty((cAlias)->E5_ORDREC)
				If !(AllTrim((cAlias)->E5_TIPO) $ "NCP|NDI|PA")
					cOrdPago := AllTrim((cAlias)->E5_ORDREC)
					SEK->(DbSeek(cFilSEK + cOrdPago))
					While !(SEK->(Eof())) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cOrdPago
						If  Alltrim(SEK->EK_TIPO) == "CH"   
							nTaxaSEK:=0
							If SE2->(DbSeek(xFilial("SE2") + SEK->EK_PREFIXO + SEK->EK_NUM + SEK->EK_PARCELA + SEK->EK_TIPO + SEK->EK_FORNECE + SEK->EK_LOJA))
								If  !(dDtIni<=SE2->E2_BAIXA .And. dDtFin>=SE2->E2_BAIXA)
									SEK->(DbSkip())
									lLoop := .T.
									Loop
								Endif 
								If  SE2->E2_SALDO == 0
									If  SEK->EK_MOEDA <> '1'             //LEMP(14/06/11):Tome la fecha solo cuando se pague con moneda diferente de pesos.
										dFechCHDeb:= SE2->E2_BAIXA       //LEMP(04/05/11):Obtener fecha en que se debito el cheque 
									Else      //LEMP(15/06/11): Significa que la OP se genero en moneda1(Falta verificar que la NF sea en dolar)
										cTipMoeSEK:= SEK->EK_MOEDA    //Por default 1           
										nVlrMoeSEK:= SEK->EK_TXMOE02  //TC con la que se debito el cheque
									Endif 
									nTtlOrd += SEK->EK_VLMOED1 
									cMoeda:= IIf(Len(Alltrim(SEK->EK_MOEDA))==1,"0"+SEK->EK_MOEDA,SEK->EK_MOEDA) 
									If (SEK->(FieldPos("EK_TXMOE"+cMoeda)) > 0 ) 
										If  ObtMovVL((cAlias)->E5_ORDREC,(cAlias)->E5_CLIFOR,(cAlias)->E5_LOJA,SEK->EK_NUM,SEK->EK_TIPO) //Significa que hay moneda pactada <--???
											// ARL 19/08/2011 - Debito posterior
											nTaxaSEK := 0
											lChkDebPost := .T.
										Else
											// Indica que hay moneda en el movimiento del cheque - Debito inmediato
											nTaxaSEK := SEK->&("EK_TXMOE"+cMoeda)
										Endif
									EndIf 
									If  SE2->E2_BAIXA<>(cAlias)->E5_DATA  
										lMoedaPac := .T.
									Endif
									If cMoeExcep <> cMoeda .And. cMoeda == "01"
										// ARL 19/08/2011 Monedas diferentes y pago en MN; aplicar con tc pactada
										nTaxaSEK := SEK->&("EK_TXMOE"+cMoeExcep)
									Endif
								Endif
							Endif
						ElseIf Alltrim(SEK->EK_TIPO) $ "EF|TF|PA"
							nTtlOrd += SEK->EK_VLMOED1     
							nTaxaSEK:=0
							If  Alltrim(SEK->EK_TIPO) $ "EF|TF"                                               
								//LEMP(15/06/11): Significa que la OP se genero en moneda1(Falta verificar que la NF sea en dolar)
								If  SEK->EK_MOEDA == '1'             
									cTipMoeSEK:= SEK->EK_MOEDA    //Por default 1           
									nVlrMoeSEK:= SEK->EK_TXMOE02  //TC con la que se debito el cheque
								Endif 
								// ARL 22/08/2011 Verificar si monedas diferentes y pago en MN; aplicar con tc pactada
								// ARL 25/10/2011 cMoeda de SEK, EK_TXMOE## de SE5
								cMoeda := IIf(Len(Alltrim(SEK->EK_MOEDA))==1,"0","") + Trim(SEK->EK_MOEDA)
								If (SEK->(FieldPos("EK_TXMOE"+cMoeExcep)) > 0 )
									If cMoeExcep <> cMoeda .And. cMoeda == "01"
										nTaxaSEK := SEK->&("EK_TXMOE"+cMoeExcep)
									Endif
									If  ObtMovVL((cAlias)->E5_ORDREC,(cAlias)->E5_CLIFOR,(cAlias)->E5_LOJA,SEK->EK_NUM,SEK->EK_TIPO) //LEMP(18/10/11):Significa que hay moneda pactada
										nTaxaSEK := 0
									Else
										// Indica que hay moneda en el movimiento del cheque - Debito inmediato
										nTaxaSEK := SEK->&("EK_TXMOE"+cMoeExcep)
									Endif
								Endif
							Endif
						ElseIf Alltrim(SEK->EK_TIPO) $ "NCP|NDI|"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³A compensacao automatica gera um unico registro para toda  a ³
							//³ordem de pago. Quando o valor pago e maior que a soma dos    ³
							//³titulos e gerado um PA. Neste caso, o valor e armazenado mas ³
							//³nao integrara a soma dos pagamentos. Noutro caso, o valor e  ³
							//³guardado para depois ser rateado entre os titulos da ordem de³ 
							//³pago.                                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SEK->EK_TIPODOC == "PA"       
								nTtlOrd += SEK->EK_VLMOED1
							Endif
						Else
							If  AllTrim(SEK->EK_TIPO) $ "NF"
								nTtlTits += SEK->EK_VLMOED1								
							Elseif AllTrim(SEK->EK_TIPO) $ "NDP" //LEMP(16/05/11):La orden de pago puede contener una Nota de Cargo
								nTtlTits += SEK->EK_VLMOED1
							Endif
						Endif
						SEK->(DbSkip())
					Enddo    
					If  lLoop    
						(cAlias)->(DbSkip())
						Loop
					Endif
					//Porcentagem do valor pago em relacao ao valor total do pagamento
					nPorcTit := nTtlOrd / nTtlTits
					If  nTtlOrd > 0
						Aadd(aTitulos,{0,Iif((!Empty(dFechCHDeb) .And. dFechCHDeb<>(cAlias)->E5_DATA) .Or. lChkDebPost,"1",""),(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_CLIFOR,(cAlias)->E5_LOJA,nValTit,1,(cAlias)->E5_TIPO,"",Iif(!Empty(dFechCHDeb),dFechCHDeb,(cAlias)->E5_DATA)})  //LEMP(04/05/11)
					Endif
				Endif
			Else    //COMPENSACIONES (PA,DEBITO Y COMPENSACION)
				nPorcTit := 1
				Aadd(aTitulos,{0,"",(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_FORNECE,(cAlias)->E5_LOJA,nValTit,1,(cAlias)->E5_TIPO,"",(cAlias)->E5_DATA})
			Endif
		EndCase

		For nI := 1 To Len(aTitulos)
			aTitulos[nI,7] := aTitulos[nI,7] * nPorcTit
			aTitulos[nI,8] := nPorcTit
		Next

		For nTit := 1 To Len(aTitulos)
			nTtlFat := 0
			cTipoPag := ""
			aImpostos := {}

			/********************************************************************************
			* Devido ao projeto chave única do Protheus 12, foi criada a query abaixo para	*
			* realizar da forma correta a ligação entre as tabelas SE5 e SF1 uma vez que	*
			* o campo E5_PREFIXO não poderá mais ser utilizado como série no dbSeek com		*
			* a tabela SF1.	- Bruno Cremaschi - 08/05/2015									*
			*********************************************************************************/
			cQryCHV := "SELECT SF1.* "
			cQryCHV += "FROM " + RetSqlName("SE5") + " SE5 "
			cQryCHV += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON "
			cQryCHV += "F1_FILIAL = E5_FILIAL AND "
			cQryCHV += "F1_DOC = E5_NUMERO AND "
			cQryCHV += "F1_PREFIXO = E5_PREFIXO AND "
			cQryCHV += "F1_FORNECE = E5_FORNECE AND "
			cQryCHV += "F1_LOJA = E5_LOJA AND "
			cQryCHV += "SF1.D_E_L_E_T_ = '' "
			cQryCHV += "WHERE " 
			cQryCHV += "E5_FILIAL = '" + xFilial("SE5") + "' AND "
			cQryCHV += "E5_NUMERO = '" + aTitulos[nTit,3] + "' AND "
			cQryCHV += "E5_PREFIXO = '" + aTitulos[nTit,4] + "' AND "
			cQryCHV += "E5_FORNECE = '" + aTitulos[nTit,5] + "' AND "
			cQryCHV += "E5_LOJA = '" + aTitulos[nTit,6] + "' AND "
			cQryCHV += "SE5.D_E_L_E_T_ = '' "

			cAliasCHV := GetNextAlias()
			cQryCHV := ChangeQuery(cQryCHV)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCHV),cAliasCHV,.T.,.T.)
			dbSelectArea(cAliasCHV)

			If  !(cAliasCHV)->(EOF())//SF1->(DbSeek(xFilial("SF1") + aTitulos[nTit,3] + aTitulos[nTit,4] + aTitulos[nTit,5] + aTitulos[nTit,6]))
				nMoeda		:= (cAliasCHV)->F1_MOEDA
				nDtDigit	:= SToD((cAliasCHV)->F1_DTDIGIT)
				nTxMoeda	:= (cAliasCHV)->F1_TXMOEDA
				dDtEmis		:= SToD((cAliasCHV)->F1_EMISSAO)
				cEspNF		:= (cAliasCHV)->F1_ESPECIE
				cFilSE		:= xFilial("SD1")                                                                          
				nTtlFat := xMoeda((cAliasCHV)->F1_VALBRUT,nMoeda,1,aTitulos[nTit,11],MsDecimais(1)) 
				nVlrBase := 0
				nBaseFat := 0
				nBaseTit := 0
				nVlrTit  := 0   
				nEntBase := 0  //LEMP(28/10/11)
				nEntVal  := 0  //LEMP(28/10/11)
				//Bruno Cremaschi - Projeto chave única.	
				SD1->(DbSeek(cFilSE + (cAliasCHV)->F1_DOC + (cAliasCHV)->F1_SERIE + (cAliasCHV)->F1_FORNECE + (cAliasCHV)->F1_LOJA))
				While !(SD1->(Eof())) .And. SD1->D1_FILIAL == cFilSE .And. SD1->D1_DOC == (cAliasCHV)->F1_DOC .And. AllTrim(SD1->D1_SERIE) == AllTrim((cAliasCHV)->F1_SERIE) .And. SD1->D1_FORNECE == (cAliasCHV)->F1_FORNECE .And. Alltrim(SD1->D1_LOJA) == Alltrim((cAliasCHV)->F1_LOJA)
					If  SFC->(DbSeek(xFilial("SFC") + SD1->D1_TES))  
						If	SFB->(DbSeek(xFilial("SFB") + SFC->FC_IMPOSTO))     
							If  SFB->FB_IVAAFEC == '2'
								nBaseTit += SD1->D1_TOTAL  //LEMP(11/11/11): Considere ITEMS de IVA NO AFECTO para el promedio pero no para la base DIOT
								SD1->(DbSkip())
								Loop
							Endif
						Endif
					Endif

					nVlrBase := SD1->D1_TOTAL
					nVlrTit  := SD1->D1_TOTAL    
					If !Empty(SD1->D1_VALDESC)   //LEMP(17/05/11):Existe un descuente a nivel item y no se consideraba
						nVlrBase-= SD1->D1_VALDESC
						nVlrTit -= SD1->D1_VALDESC
					Endif
					If lF4clavpg
						SF4->(DbSeek(xFilial("SF4") + SD1->D1_TES))			
						cTipoPag := SF4->F4_CLAVPG
					Else
						cTipoPag := ""
					Endif
					aImpD1 := DefImposto(SD1->D1_TES)
					For nX := 1 To Len(aImpD1)
						cCampoBase:="SD1->D1_"+ aImpD1[nX][7]
						cCampoAliq:="SD1->D1_"+ aImpD1[nX][8]
						cCampoVal :="SD1->D1_"+ aImpD1[nX][2]
						nPos := Ascan(aImpostos,{|aimp| aimp[1] == aImpD1[nX,1] .And. aimp[2] == &cCampoAliq})
						If nPos == 0
							Aadd(aImpostos,{aImpD1[nX,1],&cCampoAliq,0,0})
							nPos := Len(aImpostos)
						Endif   
						If  dDtEmis ==  aTitulos[nTit,11]   //LEMP(11/08/11):Considerar la moneda pactada
							lMoedaPac := .T.             
						Endif                         
						If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)   //LEMP(15/06/11): Significa que el pago es en $ y la NF en dolar
							aImpostos[nPos,3] += xMoeda(&cCampoBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
							aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
							nEntBase := xMoeda(&cCampoBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK) //LEMP(28/10/11)
							nEntVal  := xMoeda(&cCampoVal,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)  //LEMP(28/10/11)
						Else                                                                         
							aImpostos[nPos,3] += xMoeda(&cCampoBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)   //LEMP(04/08/11) 
							aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)    //LEMP(04/08/11) 		
							nEntBase := xMoeda(&cCampoBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)  //LEMP(28/10/11)
							nEntVal  := xMoeda(&cCampoVal,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)  //LEMP(28/10/11)
						Endif
					Next
					SFC->(DbSeek(xFilial("SFC") +  SD1->D1_TES))
					While !(SFC->(Eof())) .And. SFC->FC_TES == SD1->D1_TES
						Do Case
							Case SFC->FC_IMPOSTO == "IVC"
							nVlrBase := nVlrBase -&cCpoIVC
							Case SFC->FC_IMPOSTO == cIEPS
							nVlrBase := nVlrBase- &cCpoIEP
							OtherWise
							IF SFC->FC_INCDUPL=="2"
								SFB->(DbSeek(xFilial("SFB") + SFC->FC_IMPOSTO))
								cCpoImp := "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
								nVlrTit -= &cCpoImp
							ElseIf SFC->FC_INCDUPL=="1"
								SFB->(DbSeek(xFilial("SFB") + SFC->FC_IMPOSTO))
								cCpoImp := "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
								nVlrTit += &cCpoImp
							EndIf
						EndCase     
						SFC->(DbSkip())
					Enddo
					SD1->(DbSkip())
					nBaseFat += nVlrBase
					nBaseTit += nVlrTit

					IF  len(aImpD1)==0    //Cuando el IVA es EXENTO o EXENTO IMP  (Esto se genera por producto o TES)
						Aadd(aImpostos,{"IVA",0,0,0})
						//LEMP(09/05/11): **Considerar IVA Excento y cero**       
						//aImpostos[len(aImpostos),4] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1))	                              
						If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)      
							aImpostos[len(aImpostos),4] += xMoeda(nVlrBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)   //THTDDW
						Else                                                                         
							//aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)    		
							aImpostos[len(aImpostos),4] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK) //THTDDW
						Endif			
					Elseif  nBaseFat <>0 .AND. nBaseTit <>0
						If  aImpostos[nPos,2]==0 //IVA CERO     //LEMP(28/10/11):Se estaba considerando como posicion a comparar, el tamaño total del arreglo 
							If  (nEntBase==0 .And. nEntVal==0)  //LEMP(28/10/11):Se valida la base y valor que se esta procesando en este Item, y no todo lo acumulado 
								/*aImpostos[nPos,3] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1))
								aImpostos[nPos,4] += xMoeda(nVlrTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1)) */
								If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)     //THTDDW
									aImpostos[nPos,3] += xMoeda(nVlrBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
									aImpostos[nPos,4] += xMoeda(nVlrTit,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
								Else                                                                         		
									aImpostos[nPos,3] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
									aImpostos[nPos,4] += xMoeda(nVlrTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
								Endif
							Endif
						Endif
						//LEMP(09/05/11): **Considerar IVA Excento y cero**	
					EndIF   

				Enddo
				// MC  
				nBaseFat := xMoeda(nBaseFat,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)  //LEMP(04/08/11) 
				nBaseTit := xMoeda(nBaseTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)  //LEMP(04/08/11) 

				nPorc := aTitulos[nTit,7] / nBaseTit
				nPorc := Iif(AllTrim((cAlias)->E5_TIPODOC) == "ES",-1*Min(1,abs(nPorc)),Iif(AllTrim((cAlias)->E5_TIPODOC) == "CP",nPorc,Min(1,abs(nPorc))) )   //LEMP(31/10/11):Tome correcto el valor minimo de porcentaje (valor absoluto en cant negativas)
				If  !Empty(aTitulos[nTit,2]) //LEMP(11/05/11):No sacar porcentaje   //LEMP(09/02/12):Tome la TC pactada y no la de la fecha de la compensacion (línea arriba)
					nPorc:=1
				Endif
				nVlrPago := nBaseFat * nPorc  

				lEsTipTer := .F.//LEMP(THAKVY) 
				SA2->(DbSeek(xFilial("SA2") + aTitulos[nTit,5] + aTitulos[nTit,6]))			
				IF  SA2->A2_TIPOTER == "15"   //LEMP(THAKVY)                                        
					//Ya no se valida el proveedor y loja, solo el Tipo tercero y Tipo de Operacion 
					nPos := Ascan(aDetPag,{|fat| fat[8] == SA2->A2_TIPOTER  .And. fat[9] == SA2->A2_TPOPER .And. fat[6] == cFilAnt})
					If  nPos != 0
						lEsTipTer := .T.
					Endif
				Else
					nPos := Ascan(aDetPag,{|fat| fat[1] == aTitulos[nTit,5] .And. fat[2] == aTitulos[nTit,6] .And. fat[6] == cFilAnt})
				Endif
				If  nPos == 0
					SA2->(DbSeek(xFilial("SA2") + aTitulos[nTit,5] + aTitulos[nTit,6]))
					Aadd(aDetPag,{aTitulos[nTit,5],aTitulos[nTit,6],SA2->A2_CGC,SA2->A2_CURP,{},cFilAnt,{},SA2->A2_TIPOTER,SA2->A2_TPOPER}) 
					nPos := Len(aDetPag)
				Endif
				If  !Empty(dDtEmis)  //LEMP(10/05/11):Que solo se lleve registros con fecha
					Aadd(aDetPag[nPos,5],{aTitulos[nTit,3],aTitulos[nTit,4],nTtlFat,nBaseFat,nMoeda,nTxMoeda,cTipoPag,dDtEmis,cEspNF,0,0,aImpostos,aTitulos[nTit,11]})
					nPosNF := Len(aDetPag[nPos,5])
					//	Endif  
					If aTitulos[nTit,1] == 1	//compensacao
						aDetPag[nPos,5,nPosNF,10] -= nVlrPago
						aDetPag[nPos,5,nPosNF,11] -= nVlrPago
					Else
						aDetPag[nPos,5,nPosNF,10] += nVlrPago
					EndIf  
				Endif

			ElseIF  lDIOTSF1P //LEMP(TGOC72-30/01/13):Agregar PE 
				// No existe NF entrada, se ejecuta PE
				aDetPagPE := ExecBlock("DIOTSF1P",.F.,.F.,{(cAlias)->R_E_C_N_O_,aTitulos[nTit], aDetPag})
				If ValType(aDetPagPE) == 'A' .And. Len(aDetPagPE) > 0
					aDetPag := aClone( aDetPagPE )
				Endif
			Endif
			(cAliasCHV)->(dbCloseArea())
		Next
		(cAlias)->(DbSkip())
	Enddo
	(cAlias)->(DbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETNCPS   ºAutor  ³Marcello            ºFecha ³ 03/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor das ncps efetivamente compensadas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetNCPs(cForn1,cLoja1,cForn2,cLoja2,dDtIni,dDtFin,cPEFilUsr)
	Local cQuery	:= ""
	Local cQryAux	:= ""
	Local cAlias	:= ""
	Local cIetuGrp	:= ""
	Local cFilSEK	:= ""
	Local cFilSE5	:= ""
	Local cCpoImp	:= ""
	Local cArqTrab	:= ""
	Local cFilUsr	:= ""
	Local nX		:= 0
	Local nPos		:= 0
	Local nPosNF	:= 0
	Local nValTit	:= 0
	Local nPorcTit	:= 0
	Local nValFat	:= 0
	Local aEstrSE5	:= {}
	Local aImpD1	:= {}
	Local aImpostos	:= {}  
	Local nVlrBase  := 0   //LEMP(13/10/11):Considerar IVA Retenido en NCP
	Local cEspNF	:= ""  //LEMP(13/10/11):Considerar IVA Retenido en NCP

	SA6->(DbSetORder(1))
	SF2->(DbSetOrder(1))
	SD2->(DbSetOrder(3))
	cFilSE := xFilial("SD2")
	cFilSE5 := xFilial("SE5")

	cQuery := "select E5_TIPODOC,E5_VALOR,E5_MOEDA,E5_DATA,E5_VLMOED2,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_LOJA,E5_CLIFOR,E5_BANCO,E5_AGENCIA,E5_CONTA from " + RetSqlName("SE5")
	cQuery += " where"
	cQuery += " D_E_L_E_T_=''"
	cQuery += " and E5_FILIAL = '" + cFilSE5 + "'"
	cQuery += " and ("
	cQryAux := "(E5_CLIFOR >= '" + cForn1 + "'"
	cQryAux += " and E5_LOJA >= '" + cLoja1 + "'"
	cQryAux += " and E5_CLIFOR <= '" + cForn2 + "'"
	cQryAux += " and E5_LOJA <= '" + cLoja2 + "'"
	cQryAux += " and E5_DATA >= '" + Dtos(dDtIni) + "'"
	cQryAux += " and E5_DATA <= '" + Dtos(dDtFin) + "'"
	cQryAux += " and E5_TIPO = 'NCP')"
	/*
	Ponto de entrada para alteracao do filtro*/
	If !Empty(cPEFilUsr)
		If ExistBlock(cPEFilUsr)
			cFilUsr	:=	ExecBlock(cPeFilUsr,.F.,.F.,{cQryAux,"NCP"})
			If !Empty(cFilUsr)
				cQryAux := cFilUsr
			Endif
		Endif
	Endif
	cQuery += cQryAux + ")"
	//
	cAlias := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	TCSetField(cAlias,"E5_DATA","D",8,0)

	dbSelectArea(cAlias)
	(cAlias)->(DbGotop())
	While !((cAlias)->(Eof()))
		//conversao do valor pago para a moeda 1
		SA6->(DbSeek(xFilial("SA6") + (cAlias)->E5_BANCO + (cAlias)->E5_AGENCIA + (cAlias)->E5_CONTA))
		nMoedaBco := If(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
		nValTit := xMoeda((cAlias)->E5_VALOR,nMoedaBco,1,(cAlias)->E5_DATA,MsDecimais(1))
		//
		SF2->(DbSeek(xFilial("SF2") + (cAlias)->E5_NUMERO + (cAlias)->E5_PREFIXO + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA))
		nMoeda		:= SF2->F2_MOEDA
		nDtDigit	:= SF2->F2_EMISSAO
		nTxMoeda	:= SF2->F2_TXMOEDA
		//nValFat		:= xMoeda(SF2->F2_VALBRUT,nMoeda,1,nDtDigit,MsDecimais(1),nTxMoeda)
		nValFat		:= xMoeda(SF2->F2_VALBRUT,nMoeda,1,nDtDigit,MsDecimais(1))
		//Porcentagem do valor pago em relacao ao valor total do pagamento
		nPorcTit  := nValTit / nValFat
		nPorcTit  := Min(1,nPorcTit)
		nVlrBase  := 0  //LEMP(13/10/11):Considerar IVA Retenido en NCP
		cEspNF	  := SF2->F2_ESPECIE   //LEMP(13/10/11):Considerar IVA Retenido en NCP
		aImpostos := {}
		SD2->(DbSeek(cFilSE + (cAlias)->E5_NUMERO + (cAlias)->E5_PREFIXO + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA))
		While !(SD2->(Eof())) .And. SD2->D2_FILIAL == cFilSE .And. SD2->D2_DOC == (cAlias)->E5_NUMERO .And. AllTrim(SD2->D2_SERIE) == AllTrim((cAlias)->E5_PREFIXO) .And. SD2->D2_CLIENTE == (cAlias)->E5_CLIFOR .And. SD2->D2_LOJA == (cAlias)->E5_LOJA
			SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES))
			SFC->(DbSeek(xFilial("SFC") + SD2->D2_TES))
			aImpD1 := DefImposto(SD2->D2_TES)
			For nX := 1 To Len(aImpD1)
				If  Substr(aImpD1[nX,1],1,2) == "IV" .OR. Substr(aImpD1[nX,1],1,3) == "REF" .OR. Substr(aImpD1[nX,1],1,2) == "RI"   //LEMP(13/10/11):Considerar IVA Retenido en NCP
					cCampoBase:="SD2->D2_"+ aImpD1[nX][7]
					cCampoAliq:="SD2->D2_"+ aImpD1[nX][8]
					cCampoVal :="SD2->D2_"+ aImpD1[nX][2]
					nPos := Ascan(aImpostos,{|aimp| aimp[1] == aImpD1[nX,1] .And. aimp[2] == &cCampoAliq})    				
					If nPos == 0
						Aadd(aImpostos,{aImpD1[nX,1],&cCampoAliq,0,0})
						nPos := Len(aImpostos)
					Endif
					//aImpostos[nPos,2] += xMoeda(&cCampoVal,nMoeda,1,nDtDigit,MsDecimais(1),nTxMoeda)
					aImpostos[nPos,3] += xMoeda(&cCampoBase,nMoeda,1,nDtDigit,MsDecimais(1))//LEMP(13/10/11):Considerar IVA Retenido en NCP
					aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,nDtDigit,MsDecimais(1))
				Endif
			Next  
			nVlrBase += SD2->D2_TOTAL    //LEMP(13/10/11):Considerar IVA Retenido en NCP
			SD2->(DbSkip())
		Enddo
		nPos := Ascan(aDetPag,{|fat| fat[1] == (cAlias)->E5_CLIFOR .And. fat[2] == (cAlias)->E5_LOJA .And. fat[6] == cFilAnt})
		If nPos == 0
			SA2->(DbSeek(xFilial("SA2") + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA))
			Aadd(aDetPag,{(cAlias)->E5_CLIFOR,(cAlias)->E5_LOJA,SA2->A2_CGC,SA2->A2_CURP,{},cFilAnt,{},SA2->A2_TIPOTER,SA2->A2_TPOPER}) //LEMP(THAKVY)
			nPos := Len(aDetPag)
		Endif
		Aadd(aDetPag[nPos,7],{(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,nDtDigit,0})  
		nPosNF := Len(aDetPag[nPos,7])
		//Endif
		For nX := 1 To Len(aImpostos)
			If  Substr(aImpostos[nX,1],1,3) != "REF" .AND. Substr(aImpostos[nX,1],1,2) != "RI"  //LEMP(13/10/11):Considerar IVA Retenido en NCP
				If (cAlias)->E5_TIPODOC == "ES"
					aDetPag[nPos,7,nPosNF,4] -= (aImpostos[nX,4] * nPorcTit) //LEMP(13/10/11):Considerar IVA Retenido en NCP  (aImpostos[nX,2] * nPorcTit)
				Else
					aDetPag[nPos,7,nPosNF,4] += (aImpostos[nX,4] * nPorcTit) //LEMP(13/10/11):Considerar IVA Retenido en NCP
				Endif 
			Else 	
				Aadd(aDetPag[nPos,5],{(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,nValTit,aImpostos[nX,3] * nPorcTit,nMoeda,nTxMoeda,"",nDtDigit,cEspNF,0,0,{aImpostos[nX]},nDtDigit})  
				nPosNF := Len(aDetPag[nPos,5])
				aDetPag[nPos,5,nPosNF,10] -= aImpostos[nX,3] * nPorcTit
				aDetPag[nPos,5,nPosNF,11] -= aImpostos[nX,3] * nPorcTit                          
			Endif
		Next
		(cAlias)->(DbSkip())
	Enddo
	(cAlias)->(DbCloseArea())
 
Return()    

Static Function ObtMovVL(cOrdPago,cCliente,cLoja,cCheque,cTipo)
	Local lEsDebDif := .F.         

	Local nIndSE5 := Retordem("SE5","E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ") 
	Local nTamPref:= TamSX3("E5_PREFIXO")[1]   
	Local nTamNum := TamSX3("E5_NUMERO")[1]
	Local nTamParc:= TamSX3("E5_PARCELA")[1]
	Local cNumero := ""
	Local aAreaSE5   := SE5->( GetArea() )

	Static lA6NumCh := (SA6->(FieldPos("A6_NUMCH")) > 0)

	cNumero := PadR( Trim(If(lA6NumCh,cCheque,cOrdPago)) , nTamNum )
	SE5->(DBSETORDER(nIndSE5))
	IF  SE5->(DBSEEK( XFILIAL("SE5") + SPACE(nTamPref) + cNumero + SPACE(nTamParc) + cTipo + cCliente + cLoja ))
		If  Empty(SE5->E5_MOEDA)
			lEsDebDif:= .T.
		Endif 
	Endif

	SE5->( RestArea(aAreaSE5) )

Return lEsDebDif
