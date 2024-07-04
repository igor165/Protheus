#INCLUDE "PROTHEUS.CH" 
#INCLUDE "MATR142.CH"
#INCLUDE "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MATR142  บAutor  ณ FSW Argentina      บ Data ณ  11/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReporte de saldos pedidos compra por importaci๓n            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ06/07/15ณPCREQ-4256ณSe elimina la funcion AjustaSX1() que ณฑฑ
ฑฑณ            ณ        ณ          ณhace modificacion a SX1 por motivo de ณฑฑ
ฑฑณ            ณ        ณ          ณadecuacion a fuentes a nuevas estruc- ณฑฑ
ฑฑณ            ณ        ณ          ณturas SX para Version 12.             ณฑฑ
ฑฑณM.Camargo   ณ09.11.15ณPCREQ-4262ณMerge sistemico v12.1.8		           ณฑฑ
ฑฑณJonathan Glzณ19/12/16ณSERINN001-ณSe elimina ajuste a SX, por motivo de ณฑฑ
ฑฑณ            ณ        ณ       510ณlimpieza de CTREE y SX.               ณฑฑ
ฑฑณLuisEnriquezณ21/04/18ณDMINA-2465ณSe modifica picture para columnas Prc.ณฑฑ
ฑฑณ            ณ        ณ          ณUnit y Total.  (COL)                  ณฑฑ
ฑฑณDiego Riveraณ14/05/18ณDMINA-2948ณSe quita Substring de query para      ณฑฑ
ฑฑณ            ณ        ณ          ณColombia, ya que no permitia mostrar  ณฑฑ
ฑฑณ            ณ        ณ          ณtodos los items de las POs. (COL)     ณฑฑ
ฑฑณ            ณ        ณ          ณSe retirada validaci๓n DBA_DT_ENC<>'' ณฑฑ
ฑฑณ            ณ        ณ          ณpara visualizaci๓n de finalizados(COL)ณฑฑ
ฑฑณgSantacruz  ณ19/05/18ณDMINA-3111ณSe agrega en el Qry la relacion  por  ณฑฑ
ฑฑณ            ณ        ณ          ณItem entre DBB y DBC ya que duplicaba ณฑฑ
ฑฑณ            ณ        ณ          ณregistros.Variable privada para los   ณฑฑ
ฑฑณ            ณ        ณ          ณparametros.                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MATR142()
Local oReport

Private cPrcIni	:=''
Private cPrcFin	:=''
Private dFecIni	:=ctod("  /  /  ")
Private dFecFin	:=ctod("  /  /  ")
Private cPrdIni	:=''
Private cPrdFin	:=''
Private nVis	:=0
Private nMon	:=0
Private nTasa	:=0
Private nStatus	:=0
Private cPerg	:= "MTR142"

oReport := ReportDef()
oReport:PrintDialog()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณ FSW Argentina      บ Data ณ  11/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRerpotDef del TReport                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
Local oReport
Local oProces
Local cNomeRel		:= "MATR142"

Local cTitulo	 	:= STR0001 //"Despachos vs PO"

Local cPicture      := "9,999,999,999,999.99"
 

Private dDateConv	:= CTOD(" / / ")

Pergunte(cPerg,.F.)
oReport := TReport():New(cNomeRel,cTitulo,cPerg,{|oReport| ReportPrint(oReport,oProces)},STR0001)

oReport:oPage:nPaperSize	:= 9
oReport:SetLandScape()
oReport:SetTotalInLine(.F.)

oProces := TRSection():New(oReport,STR0002,{"DBB","DBC","SB1","SC7"},{STR0002})
oProces:SetTotalInLine(.F.)

TRCell():New(oProces,"DBC_HAWB"     	,,STR0002 ,PesqPict("DBC","DBC_HAWB")  	,TamSx3("DBC_HAWB")[1]  ,,{|| TRBCOM->DBC_HAWB           })
TRCell():New(oProces,"DBB_DOC"		 	,,STR0003 ,PesqPict("DBB","DBB_DOC")	,TamSx3("DBB_DOC")[1]	,,{|| TRBCOM->DBB_DOC			  })
TRCell():New(oProces,"DBC_ITEM"     	,,STR0004 ,PesqPict("DBC","DBC_ITEM")  	,TamSx3("DBC_ITEM")[1]  ,,{|| TRBCOM->DBC_ITEM           })
TRCell():New(oProces,"DBC_CODPRO"	 	,,STR0005 ,PesqPict("DBC","DBC_CODPRO")	,TamSx3("DBC_CODPRO")[1],,{|| TRBCOM->DBC_CODPRO		  })
TRCell():New(oProces,"B1_GRUPO"     	,,STR0007 ,PesqPict("SB1","B1_GRUPO")  	,TamSx3("B1_GRUPO")[1]  ,,{|| TRBCOM->B1_GRUPO           })
TRCell():New(oProces,"DBC_UM"       	,,STR0008 ,PesqPict("DBC","DBC_UM")    	,TamSx3("DBC_UM")[1]    ,,{|| TRBCOM->DBC_UM             })
TRCell():New(oProces,"DBC_QUANT"    	,,STR0009 ,PesqPict("DBC","DBC_QUANT") 	,TamSx3("DBC_QUANT")[1] ,,{|| TRBCOM->DBC_QUANT          })
TRCell():New(oProces,"DBC_PRECO"    	,,STR0010 ,cPicture                 	,TamSx3("DBC_PRECO")[1] + 4 ,,{|| xMoeda(TRBCOM->DBC_PRECO,TRBCOM->DBB_MOEDA,nMon,dDateConv)    })
TRCell():New(oProces,"DBC_TOTAL"    	,,STR0011 ,cPicture    	                ,TamSx3("DBC_TOTAL")[1] + 4 ,,{|| xMoeda(TRBCOM->DBC_TOTAL,TRBCOM->DBB_MOEDA,nMon,dDateConv)    })
TRCell():New(oProces,"DBC_LOCAL"    	,,STR0012 ,PesqPict("DBC","DBC_LOCAL") 	,TamSx3("DBC_LOCAL")[1] ,,{|| TRBCOM->DBC_LOCAL         })
TRCell():New(oProces,"DBC_DATPRF"   	,,STR0013 ,PesqPict("DBC","DBC_DATPRF")	,TamSx3("DBC_DATPRF")[1],,{|| STOD(TRBCOM->DBC_DATPRF)  })
TRCell():New(oProces,"DBC_PEDIDO"   	,,STR0014 ,PesqPict("DBC","DBC_PEDIDO")	,TamSx3("DBC_PEDIDO")[1],,{|| TRBCOM->DBC_PEDIDO		  })
TRCell():New(oProces,"DBC_ITEMPC"	 	,,STR0015 ,PesqPict("DBC","DBC_ITEMPC")	,TamSx3("DBC_ITEMPC")[1],,{|| TRBCOM->DBC_ITEMPC		  })
TRCell():New(oProces,"C7_QUANT"     	,,STR0016 ,PesqPict("SC7","C7_QUANT") 	,TamSx3("C7_QUANT")[1]  ,,{|| TRBCOM->C7_QUANT           })
TRCell():New(oProces,"C7_QUJE"      	,,STR0017 ,PesqPict("SC7","C7_QUANT")  	,TamSx3("C7_QUANT")[1]  ,,{|| TRBCOM->C7_QUJE            })
TRCell():New(oProces,"SALDO"        	,,STR0018 ,PesqPict("SC7","C7_QUANT")  	,TamSx3("C7_QUANT")[1]  ,,{|| TRBCOM->SALDO              })

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrintบAutor  ณ FSW Argentina      บ Data ณ  11/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del Report                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint(oReport,oProces)
Local cQry 	:= ""
Local cTpNf := GetMv("AR_TPNFSCO",,"5/8")

Pergunte(cPerg,.F.)
/*
MV_PAR01  ฟDe Proceso?
MV_PAR02  ฟA Proceso?
MV_PAR03  ฟDe Fecha de Proceso?
MV_PAR04  ฟA Fecha de Proceso?
MV_PAR05  ฟDe Producto?
MV_PAR06  ฟA Producto?
MV_PAR07  ฟVisualizar? 1-Pendientes 2-Todos
MV_PAR08  ฟMonedas? 1 2
MV_PAR09  ฟTasa de Cambio? 1- Movimiento 2- Dia
MV_PAR10  ฟFinalizado? 1-si -no
*/

cPrcIni	:=MV_PAR01
cPrcFin	:=MV_PAR02
dFecIni	:=MV_PAR03
dFecFin	:=MV_PAR04
cPrdIni	:=MV_PAR05
cPrdFin	:=MV_PAR06
nVis	:=MV_PAR07
nMon	:=MV_PAR08
nTasa	:=MV_PAR09
nStatus	:=MV_PAR10


#IFDEF TOP
	
	
	cTpNf := StrTran(cTpNf,"/","','")
	cTpNf := Alltrim(cTpNf)
	If Substr(cTpNf,Len(cTpNf),1) == "'"
		cTpNf := Substr(cTpNf,1,Len(cTpNf)-3)
	Endif
	

	
	cQry := " SELECT DBA_DTHAWB, DBC_HAWB, DBB_DOC, DBC_ITEM, DBB_ITEM, DBC_CODPRO, DBC_DESCRI, B1_GRUPO, DBC_UM, DBC_QUANT, DBC_PRECO, DBC_TOTAL, "+CRLF
	cQry += " DBC_LOCAL, DBC_DATPRF, DBC_PEDIDO, DBC_ITEMPC, C7_QUANT, C7_QUJE, (C7_QUANT - C7_QUJE) AS SALDO, DBB_MOEDA, DBB_EMISSA "+CRLF
	cQry += " FROM "+RetSqlName("DBB")+" DBB "+CRLF
	cQry += " INNER JOIN "+RetSqlName("DBA")+" DBA ON DBA_FILIAL = '"+xFilial("DBA")+"' AND DBA_HAWB = DBB_HAWB AND "+CRLF
	cQry += " DBA_DTHAWB BETWEEN '"+DTOS(dFecIni)+"' AND '"+DTOS(dFecFin)+"' AND "+CRLF
	
	IF nStatus == 1 // ฟFinalizado? 1-si -no
		IF cPaisLoc == "COL"
			cQry += " DBA_OK = '3' AND "+CRLF
		Else
			cQry += " DBA_OK = '3' AND DBA_DT_ENC <> '' AND "+CRLF
		EndIf
	Else
		IF cPaisLoc == "COL"
			cQry += " DBA_OK <> '3' AND "+CRLF
		Else
			cQry += " DBA_DT_ENC = '' AND "+CRLF
		EndIf
	Endif
	cQry += " DBA.D_E_L_E_T_ = '' "+CRLF
	
	cQry += " INNER JOIN "+RetSqlName("DBC")+" DBC ON DBC_FILIAL = '"+xFilial("DBC")+"' AND DBC_HAWB = DBB_HAWB AND  DBC_ITDOC = DBB_ITEM AND "+CRLF
	IF cPaisLoc == "COL" 
		cQry += " DBC_CODPRO BETWEEN '"+cPrdIni+"' AND '"+cPrdFin+"' AND DBC.D_E_L_E_T_ = '' "+CRLF
	Else
		cQry += " SUBSTRING(DBC_ITEMPC,2,3) = DBB_ITEM AND DBC_CODPRO BETWEEN '"+cPrdIni+"' AND '"+cPrdFin+"' AND DBC.D_E_L_E_T_ = '' "+CRLF
	Endif
	cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = DBC_CODPRO AND SB1.D_E_L_E_T_ = '' "+CRLF
	cQry += " INNER JOIN "+RetSqlName("SC7")+" SC7 ON C7_FILIAL = '"+xFilial("SC7")+"' AND C7_NUM = DBC_PEDIDO AND C7_ITEM = DBC_ITEMPC "+CRLF
	
	If nVis == 1
		cQry += " AND (C7_QUANT-C7_QUJE) <> 0 "+CRLF
	Endif
	
	cQry += " AND SC7.D_E_L_E_T_ = '' "+CRLF
	
	cQry += " WHERE "+CRLF
	cQry += " DBB_FILIAL = '"+xFilial("DBB")+"' "+CRLF
	cQry += " AND DBB_HAWB BETWEEN '"+cPrcIni+"' AND '"+cPrcFin+"' "+CRLF
	cQry += " AND DBB_TIPONF IN ('"+cTpNf+"') "
	cQry += " AND DBB.D_E_L_E_T_ = '' "+CRLF
	cQry += " ORDER BY DBB_HAWB "
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "TRBCOM"
	
	oReport:SetMeter(TRBCOM->(RecCount()))
	
	While TRBCOM->(!EOF())
	
		oReport:IncMeter(1)
	
		If nTasa == 1 // 1- Movimiento 2- Dia
			dDateConv := STOD(TRBCOM->DBB_EMISSA)
		Else
		    dDateConv := dDataBase
		Endif
	
		oProces:Init()
	
		oProces:PrintLine()
	
		TRBCOM->(DbSkip())
	EndDo
	TRBCOM->(DbCloseArea())
#ELSE
	Aviso(STR0001,STR0019,{STR0020})//"Relat๓rio disponํvel apenas para ambiente TopConnect."  

#ENDIF
Return
