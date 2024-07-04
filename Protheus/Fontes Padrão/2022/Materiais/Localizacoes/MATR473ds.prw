#include "protheus.ch"
#include "Birtdataset.ch"
#include "MATR473.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³          ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 06.05.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imp. de pedidos de Ventas en BIRT , de acuerdo a los         ³±±
±±³          ³ parametros que el usuario define.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (void)                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±³            ³          ³      ³                                          ³±±
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset M473ds
	title STR0001 //"Pedido de Venta"
	description  STR0001 //"Pedido de Venta"
	PERGUNTE "MATR473"

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define las columnas del dataset dsVen.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
columns
	define column CODIG TYPE CHARACTER  SIZE 20 LABEL STR0002 //Codigo Cliente/Tienda
	define column NMERO LIKE C5_NUM
	define column CLNTE LIKE C5_CLIENTE
	define column CANTD LIKE C6_QTDVEN
	define column UNIDD LIKE C6_UM
	define column PRCUT LIKE C6_PRCVEN
	define column VALTO LIKE C6_VALOR
	define column VALDS LIKE C6_VALDESC
	define column CDPAG LIKE E4_DESCRI
	define column NOME  LIKE A1_NOME
	define column MUNCP LIKE A1_MUN
	define column ESTAD TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A1_EST"
	define column PAISD TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A1_PAISDES"
	define column CEP   LIKE A1_CEP
	define column DIREC TYPE CHARACTER  SIZE 200 LABEL STR0003 //Direccion Clte
	define column PRODU TYPE CHARACTER  SIZE 15  LABEL STR0004 //Codigo Producto
	define column CONCT TYPE CHARACTER  SIZE 200 LABEL STR0005 //Concepto
	define column EMISO TYPE CHARACTER  SIZE 10  LABEL STR0006 //Fecha Emision
	define column ENTGA TYPE CHARACTER  SIZE 10  LABEL STR0007 //Fecha Entrega
	define column LETRA TYPE CHARACTER  SIZE 300 LABEL STR0008 //Importe Letra
	define column NMEMP TYPE CHARACTER  SIZE 100 LABEL STR0009 //Nombre Empresa
	define column DREMP TYPE CHARACTER  SIZE 300 LABEL STR0010 //Direc. Empresa
	define column CPEMP TYPE CHARACTER  SIZE 100 LABEL STR0011 //CP. Empresa
	define column MUNENT LIKE A1_MUN
	define column EDOENT LIKE A1_ESTADO
	define column CEPENT LIKE A1_CEP
	define column DRNENT TYPE CHARACTER SIZE 200 LABEL STR0003 //Direccion Clte
	define column PAIENT TYPE CHARACTER SIZE 40  DECIMALS 0 LABEL "A1_PAISENT"
	define column IMAGE  type character size 20   label "Imagen"

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query, para la obtencion de informacion del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
define query "SELECT CODIG, NMERO, CLNTE, CANTD, UNIDD, PRCUT, VALTO, VALDS, CDPAG, IMAGE, "+;
                   " NOME, MUNCP, ESTAD, PAISD, CEP, DIREC, PRODU, CONCT, EMISO, ENTGA, "+;
                   " LETRA, NMEMP, DREMP, CPEMP, MUNENT, EDOENT, CEPENT, DRNENT, PAIENT  "+;
             "FROM %WTable:1% "
//             "WHERE NMERO BETWEEN ? AND ? AND CLNTE BETWEEN ? AND ? "


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se inicia la rutina de llenado del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
process dataset

Local cWTabAlias
Local cPedIn	 := self:execParamValue("MV_PAR01")
Local cPedFn	 := self:execParamValue("MV_PAR02")
Local cClteIn	 := self:execParamValue("MV_PAR03")
Local cClteFi	 := self:execParamValue("MV_PAR04")
Local cFchIni	 := self:execParamValue("MV_PAR05")
Local cFchFin	 := self:execParamValue("MV_PAR06")
Local lRet 	 := .F.

if ::isPreview()
endif

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se crea la tabla temporal, que sera la fuente de los datos para el dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
cWTabAlias := ::createWorkTable()
chkFile("SC5")

Processa({|_lEnd| lRet := PrintRpt(cWTabAlias,cPedIn,cPedFn,cClteIn,cClteFi,cFchIni,cFchFin)}, ::title())

	if !lRet
		MsgInfo(STR0019)
	else
		MsgInfo(STR0020)
	endif

return .T.


static function PrintRpt (cWTabAlias,cPedIn,cPedFn,cClteIn,cClteFi,cFchIni,cFchFin)

Local cFilSC5  := xfilial("SC5")
Local cFilSC6  := xfilial("SC6")
Local cFilSE4  := xfilial("SE4")
Local cFilSB1  := xfilial("SB1")
Local cFilSA1  := xfilial("SA1")
Local cPerg 	 := "MATR473"
Local cNomeEmp := ""
Local cDircEmp := ""
Local cCECPEmp := ""
Local cnt		 := 0
Local nSTotal	 := 0
Local nDesct	 := 0
Local cNmero	 := ''

Local cEmiso	 := ""
Local cEntga	 := ""
Local cCS5COD  := ""
Local cCS5LOJA := ""
Local aAr		 :={}

private cQuery := ''
private cTempF := CriaTrab(nil, .f.)

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//SE ASIGNA EL VALOR A LAS PARAMTROS DE "DATOS DE LA EMPRESA2, PARA PODER
//USARLOS EN LA IMPRESION DEL REPORTE.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
cNomeEmp := RTRIM(SM0->M0_NOME)
cDircEmp := RTRIM(SM0->M0_ENDCOB)+", "+ RTRIM(SM0->M0_BAIRCOB)+"."
cCECPEmp := RTRIM(SM0->M0_CIDCOB)+", "+ RTRIM(SM0->M0_ESTCOB) +", "+ RTRIM(SM0->M0_CEPCOB)+"."

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query y para el llenado de la tabla temporal.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
If cPaisLoc == "ARG"
	cQuery := "SELECT C5_CLIENTE, C5_LOJACLI, C5_NUM, C6_QTDVEN, C6_UM, C6_PRCVEN, C6_VALOR, C6_VALDESC, E4_DESCRI, A1_NOME, "
	cQuery += " A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_PAIS, A1_CEP, C6_PRODUTO, B1_DESC, C5_EMISSAO, C5_FECENT, A1_COD , A1_LOJA, C5_CLIENT, C5_LOJAENT  "
Else
	cQuery := "SELECT C5_CLIENTE, C5_LOJACLI, C5_NUM, C6_QTDVEN, C6_UM, C6_PRCVEN, C6_VALOR, C6_VALDESC, E4_DESCRI, A1_NOME, "
	cQuery += " A1_END, A1_NR_END, A1_NROINT, A1_BAIRRO, A1_MUN, A1_EST, A1_PAIS, A1_CEP, C6_PRODUTO, B1_DESC, C5_EMISSAO,  "
	cQuery += " C5_FECENT, C5_CLIENT, C5_LOJAENT "
EndIf

cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SE4")+" SE4, "+RetSqlName("SB1")+" SB1, "+RetSqlName("SA1")+" SA1 "
cQuery += " WHERE C5_NUM BETWEEN '"+ cPedIn +"' AND '"+ cPedFn +"' "
cQuery += " AND C5_CLIENTE BETWEEN '"+ cClteIn +"' AND '"+ cClteFi +"' "
cQuery += " AND C5_EMISSAO BETWEEN '"+ DTOS(cFchIni) +"' AND '"+ DTOS(cFchFin)+"' "
cQuery += " AND C5_CONDPAG = E4_CODIGO "
cQuery += " AND C5_CLIENTE + C5_LOJACLI = A1_COD + A1_LOJA  "
cQuery += " AND B1_COD = C6_PRODUTO "
cQuery += " AND C5_NUM=C6_NUM "
cQuery += " AND C5_FILIAL = '"+cFilSC5+"' "
cQuery += " AND C6_FILIAL = '"+cFilSC6+"' "
cQuery += " AND B1_FILIAL = '"+cFilSB1+"' "
cQuery += " AND E4_FILIAL = '"+cFilSE4+"' "
cQuery += " AND A1_FILIAL = '"+cFilSA1+"' "
cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
cQuery += " AND SE4.D_E_L_E_T_ = ' ' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY C5_NUM, C5_CLIENTE, C5_EMISSAO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)

TCSetField( cTempF , "C5_EMISSAO" , "D" )
TCSetField( cTempF , "C5_FECENT"  , "D" )

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Comienza el llenado de la tabla temporal.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

count to nCount

(cTempF)->(dbGoTop())

ProcRegua(nCount)

While (!(cTempF)->(EOF()))
	cnt++

	cNmero	:= (cTempF)->C5_NUM
	nSTotal:= 0
	nDesct	:= 0
	While (!(cTempF)->(EOF())) .and. cNmero == (cTempF)->C5_NUM

		Incproc()

		cCS5COD  := C5_CLIENT
		cCS5LOJA := C5_LOJAENT

		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->CODIG	:= (cTempF)->C5_CLIENTE+"/"+(cTempF)->C5_LOJACLI
			(cWTabAlias)->NMERO	:= (cTempF)->C5_NUM
			(cWTabAlias)->CLNTE	:= (cTempF)->C5_CLIENTE
			(cWTabAlias)->CANTD	:= (cTempF)->C6_QTDVEN
			(cWTabAlias)->UNIDD	:= (cTempF)->C6_UM
			(cWTabAlias)->PRCUT	:= (cTempF)->C6_PRCVEN
			(cWTabAlias)->VALTO	:= (cTempF)->C6_VALOR
			(cWTabAlias)->VALDS	:= (cTempF)->C6_VALDESC
			(cWTabAlias)->CDPAG	:= (cTempF)->E4_DESCRI
			(cWTabAlias)->NOME 	:= (cTempF)->A1_NOME
			(cWTabAlias)->MUNCP	:= (cTempF)->A1_MUN
			(cWTabAlias)->ESTAD	:= POSICIONE("SX5",1,XFILIAL("SX5")+"12"+(cTempF)->A1_EST,"X5_DESCSPA")
			(cWTabAlias)->PAISD  := POSICIONE("SYA",1,XFILIAL("SYA")+(cTempF)->A1_PAIS,"YA_DESCR")
			(cWTabAlias)->CEP		:= (cTempF)->A1_CEP

			If cPaisLoc == "ARG"
				(cWTabAlias)->DIREC	:= RTRIM((cTempF)->A1_END)    +", "+ RTRIM((cTempF)->A1_BAIRRO)
			Else
				(cWTabAlias)->DIREC	:= RTRIM((cTempF)->A1_END)    +", "+ RTRIM((cTempF)->A1_NR_END) +" "+;
										   RTRIM((cTempF)->A1_NROINT) +", "+ RTRIM((cTempF)->A1_BAIRRO)
			EndiF

			(cWTabAlias)->PRODU	:= RTRIM((cTempF)->C6_PRODUTO)
			(cWTabAlias)->CONCT	:= RTRIM((cTempF)->B1_DESC)

			cEmiso	 := DTOC((cTempF)->C5_EMISSAO)
			cEntga	 := DTOC((cTempF)->C5_FECENT )

				(cWTabAlias)->EMISO	:= cEmiso
				(cWTabAlias)->ENTGA	:= cEntga

			nSTotal	+= (cTempF)->C6_VALOR
			nDesct		+= (cTempF)->C6_VALDESC

				(cWTabAlias)->LETRA	:= extenso(nSTotal-nDesct,.f.,1)
				(cWTabAlias)->NMEMP	:= RTRIM(cNomeEmp)
				(cWTabAlias)->DREMP	:= RTRIM(cDircEmp)
				(cWTabAlias)->CPEMP	:= RTRIM(cCECPEmp)

				aAr := DIRCENT(cFilSA1, cCS5COD, cCS5LOJA)

				(cWTabAlias)->MUNENT	:= aAr[1]
				(cWTabAlias)->EDOENT	:= aAr[2]
				(cWTabAlias)->CEPENT	:= aAr[3]
				(cWTabAlias)->DRNENT	:= aAr[4]
				(cWTabAlias)->PAIENT := aAr[5]
				(cWTabAlias)->IMAGE	:= "lgrl"+cEmpAnt+".bmp"

		(cWTabAlias)->(MsUnLock())

		(cTempF)->(dbSkip())

	EndDo
EndDo
(cTempF)->(dbCloseArea())
lRet := cnt > 0

return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIRECT         ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 06.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene la informacion del direccion del clientes donde se       ³±±
±±³          ³ realizara la entrega del pedido de venta.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function DIRCENT(cFilSA1 ,cCS5COD, cCS5LOJA )
Local aArray := {}
DbSelectArea("SA1")
DbSetOrder(1) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA

	IF DbSeek(cFilSA1 + cCS5COD + cCS5LOJA ) // Filial,  Codigo, Loja

		aAdd(aArray, SA1->A1_MUN)
		aAdd(aArray, POSICIONE("SX5",1,XFILIAL("SX5")+"12"+SA1->A1_EST,"X5_DESCSPA"))
		aAdd(aArray, SA1->A1_CEP)

		If cPaisLoc == "ARG"
			aAdd(aArray, RTRIM(SA1->A1_END) +", "+ RTRIM(SA1->A1_BAIRRO))
		Else
			aAdd(aArray, RTRIM(SA1->A1_END) +", "+ RTRIM(SA1->A1_NR_END) +" "+ RTRIM(SA1->A1_NROINT) +", "+ RTRIM(SA1->A1_BAIRRO))
		Endif
		aAdd(aArray, POSICIONE("SYA",1,XFILIAL("SYA")+SA1->A1_PAIS,"YA_DESCR"))
	Endif
SA1->(DbCloseArea())
return aArray