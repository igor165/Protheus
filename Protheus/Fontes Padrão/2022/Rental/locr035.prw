#Include "LOCR035.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RWMAKE.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ LOCR035   บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Analise de Autorizacao de Servi็os               บฑฑ
ฑฑบ          ณ Chamada: Via menu de usuแrio.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  
/*/

// ======================================================================= \\
Function LOCR035() 
// ======================================================================= \\

// --> DECLARACAO DE VARIAVEIS.
Local   cDesc1      := STR0001 													// "Este programa tem como objetivo imprimir relatorio "
Local   cDesc2      := STR0002 													// "de acordo com os parametros informados pelo usuario."
Local   cDesc3      := STR0085 													// "Analise de AS"
Local   Titulo      := STR0085 													// "Analise de AS"
Local   cPerg       := "LOCR035" 												// "RELRAAS"
Local   CABEC1      := ""
Local   CABEC2      := ""
Local   nLin        := 80
Local   Imprime 

Private aOrd        := {} 
Private lEnd        := .F.
Private lAbortPrint := .F.
Private Limite      := 120
Private Tamanho     := "G"
Private NomeProg    := "LOCR035" 												// Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := {"Zebrado" , 1 , "Administracao" , 2 , 2 , 1 , "" , 1} 
Private nLastKey    := 0
Private cbTxt       := Space(10)
Private cbCont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "LOCR035" 												// Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 	:= ""

Private nMVPAR15    := 0 

Imprime := .T. 

//ValidPerg(cPerg)                                                                         
Pergunte(cPerg,.F.)

nMVPAR15 := MV_PAR15 															// --> 1=LOCACAO (FPA)   /   2=EQUIPAMENTO (FP4) 
nMVPAR15 := 1 																	// --> For็ar sempre 1=LOCACAO, em Set/2021 ้ o ๚nico disponivel para o RENTAL 

// --> MONTA A INTERFACE PADRAO COM O USUARIO...
wnrel := SetPrint(cString , NomeProg , cPerg , @Titulo , cDesc1 , cDesc2 , cDesc3 , .T. , aOrd , .T. , Tamanho , , .T.) 

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn , cString) 

If nLastKey == 27
	Return
EndIf

nTipo := Iif(aReturn[4]==1 , 15 , 18) 

RptStatus({|| RunReport(CABEC1 , CABEC2 , Titulo , nLin) } , Titulo) 

Return 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFun็ไo    ณ RUNREPORT บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescri็ไo ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function RunReport(CABEC1 , CABEC2 , Titulo , nLin)

Local aArea     := GetArea()
//Local cArquivo																	// Arquivo padrใo HTML na pasta SERVER\System
//Local nArq																		// Abertura do arquivo binแrio
//Local cHTML																		// Strings temporแria para alimentar o arquivo.html
Local cQry  	:= ""															// Query 
Local aOpcCmb   := {} 															// MontaCombo("FQ5_STATUS")
Local aOpcCmb1  := MontaCombo("FQ5_TPAS") 										// T=Transporte ; E=Equipamentos ; F=Frete ; L=Locacao ; M=Mao de Obra 

aAdd(aOpcCmb,{"1",STR0078}) 													// "Em Aberto" 
aAdd(aOpcCmb,{"2",STR0079}) 													// "Em Transito" 
aAdd(aOpcCmb,{"3",STR0080}) 													// "Encerrada" 
aAdd(aOpcCmb,{"4",STR0081}) 													// "Chegada/filial" 
aAdd(aOpcCmb,{"5",STR0082}) 													// "Fechada" 
aAdd(aOpcCmb,{"6",STR0083}) 													// "Aprovada" 
aAdd(aOpcCmb,{"9",STR0084}) 													// "Cancelada" 

// AS  - FQ5_AS 
// CLIENTE - FQ5_NOMCLI
// LOCAL DA OBRA  : FQ5_DESTIN
// STATUS         : aOpcCmb := MontaCombo("FPO_STATUS")							// Carrega os itens do ComboBox da SX3 ; ' Status: ' + aOpcCmb[aScan(aOpcCmb, {|x| x[3]==FPO_STATUS}), 4]
// FROTA          : FQ5_GUINDA
// DT EMISSAO     : FQ5_DATGER
// DT PROGRAMACAO : FQ5_DTPROG
// DATA DO ACEITE : FQ5_ACEITE

If Select("TRB") <> 0 
	dbSelectArea("TRB") 
	dbCloseArea() 
EndIf

// --> Status AS (DTQ)
//          { STR0010     , STR0011     , STR0012   , STR0013    , STR0014     } 
xaTmp    := {"1=Em Aberto","6=Aprovada","9=Cancelada"} //"3=Encerrada","5=Fechada","6=Aprovada","9=Cancelada"} 
MV_PAR07 := Left(xaTmp[MV_PAR07], 1)
MV_PAR08 := Left(xaTmp[MV_PAR08], 1)

cQry := " SELECT FQ5_FILIAL , FQ5_DATGER , FQ5_STATUS , FQ5_GUINDA , FQ5_NOMCLI , FQ5_SOT , "                                 + CRLF
cQry += "        FQ5_AS     , FQ5_TPAS   , FQ5_DESTIN , FQ5_DTPROG , FQ5_ACEITE "                                             + CRLF
cQry += " FROM " + RetSqlName("FQ5") + " FQ5 "                                                                                + CRLF
cQry += "        JOIN " + RetSqlName("FP0") + " FP0 ON FP0.D_E_L_E_T_ = '' AND FQ5_FILORI=FP0_FILIAL AND FQ5_SOT=FP0_PROJET " + CRLF
cQry += " WHERE  FQ5.D_E_L_E_T_ = '' "                                                                                        + CRLF
cQry += "   AND  FQ5_DATGER BETWEEN '" + DtoS(MV_PAR11)	+ "' AND '" + DtoS(MV_PAR12) + "'"                                    + CRLF
cQry += "   AND  FQ5_STATUS BETWEEN '" +      MV_PAR07  + "' AND '" +      MV_PAR08  + "'"                                    + CRLF
cQry += "   AND  FQ5_TPAS   = '" + Iif(nMVPAR15=1,"L","E") + "'"                                                              + CRLF
cQry += "   AND  FQ5_FILIAL = '" + xFilial("FQ5") + "'"                                                                       + CRLF
cQry += "   AND  FQ5_GUINDA BETWEEN '"+       MV_PAR09  + "' AND '" +      MV_PAR10  + "'"                                    + CRLF
cQry += "   AND  FQ5_AS     BETWEEN '"+       MV_PAR01  + "' AND '" +      MV_PAR02  + "'"                                    + CRLF
cQry += "   AND  FP0_CLIENT BETWEEN '"+       MV_PAR03  + "' AND '" +      MV_PAR05  + "'"                                    + CRLF
cQry += "   AND  FP0_LOJA   BETWEEN '"+       MV_PAR04  + "' AND '" +      MV_PAR06  + "'"                                    + CRLF
// --> 1=Em Aberto   ||  3=Encerrada  ||  5=Fechada  ||  6=Aprovada  ||  9=Cancelada
If MV_PAR13 == 1
	cQry += " ORDER BY FQ5_STATUS, FQ5_DATGER, FQ5_AS "                                                                       + CRLF
Else  
	cQry += " ORDER BY FQ5_DATGER, FQ5_STATUS, FQ5_AS "                                                                       + CRLF
EndIf


cQry := ChangeQuery(cQry) 

dbUseArea(.T. , "TOPCONN" , TCGenQry(,,cQry) , "TRB" , .F. , .T.) 

CABEC1 := PadR( STR0015 , Len(FQ5->FQ5_AS)+1	       ) 						// "AS"
CABEC1 += PadR( STR0016 , Len(FQ5->FQ5_NOMCLI)+1       ) 						// "CLIENTE"
CABEC1 += PadR( STR0017 , Len(FQ5->FQ5_DESTIN)+1       ) 						// "MUN. OBRA"
CABEC1 += PadR( STR0018 , 22 					       ) 						// "STATUS"
CABEC1 += PadR( STR0019 , Len(FQ5->FQ5_GUINDA)+2       )  						// "FROTA"
CABEC1 += PadR( STR0020 , Len(DtoC(FQ5->FQ5_DATGER))+2 ) 						// "DT EMISS"
//CABEC1 += PadR( STR0021 , Len(DtoC(FQ5->FQ5_DATGER))+2 ) 						// "DT PROGR"
CABEC1 += PadR( STR0022 , Len(DtoC(FQ5->FQ5_DATGER))+2 )  						// "DT ACEIT"

/*
If MV_PAR14 == 1																// Se for exportar para o Excel 
	cArquivo := CriaTrab(,.F.)+".htm"											// Arquivo padrใo HTML na pasta SERVER\System
	nArq     := fCreate(cArquivo,0)												// Abertura do arquivo binแrio

	cHTML := "<HTML><HEAD><TITLE>"+STR0023+"</TITLE></HEAD>" + CRLF 			// "Relacao de Transportes da Autorizacao de Servi็o"
	cHTML += "<BODY><TABLE BORDER='1'><TR>"
	cHTML += "<TD colspan='8'><CENTER><H2>"+STR0023+"</H2></CENTER>" 			// "Relacao de Transportes da Autorizacao de Servi็o"

	nPosCmb1 := 1
	If aScan(aOpcCmb , {|x| x[1]== MV_PAR07}) == 0
		nPosCmb1 := aScan(aOpcCmb , {|x| x[1]== MV_PAR07})
	EndIf

	nPosCmb2 := 1
	If aScan(aOpcCmb , {|x| x[1]== MV_PAR08}) == 0
		nPosCmb2 := aScan(aOpcCmb , {|x| x[1]== MV_PAR08})
	EndIf

	cHTML += STR0025 + MV_PAR01                + STR0026 + MV_PAR02 																	// Parโmetros: AS         ##  " at้ "
	cHTML += STR0027 + MV_PAR03                + STR0028 + MV_PAR04            + STR0026 + MV_PAR05 + STR0028 + MV_PAR06 			// " - Cliente de "       ##  "/"       ##  " at้ "  ##  "/" 
	cHTML += STR0029 + MV_PAR07                + STR0030 + aOpcCmb[nPosCmb1,2] + STR0026 + MV_PAR08 + STR0030 + aOpcCmb[nPosCmb2,2] 	// " - Status  de "       ##  " - "     ##  " at้ "  ##  " - " 
	cHTML += STR0031 + Iif(nMVPAR15=1,"L","E") + STR0030 + aOpcCmb1[aScan(aOpcCmb1, {|x| x[3]==Iif(nMVPAR15=1,"L","E")}), 2] 		// " - Tipo Servi็o de "  ##  " - " 
	cHTML += STR0032 + MV_PAR09                + STR0026 + MV_PAR10 																	// " - Frota de "         ##  " at้ " 
	cHTML += STR0033 + DtoC(MV_PAR11)          + STR0026 + DtoC(MV_PAR12) 															// " - Emissao entre "    ##  " at้ "
	cHTML += STR0034 + Iif(MV_PAR13==1 , STR0035 , STR0036) 																// " - Ordem   "          ##  "Status"  ##  "Data de Emissao" 
	cHTML += "</TD></TR><TR>"
	cHTML += "<TH>"+STR0037+"</TH>" 																						// "AS"
	cHTML += "<TH>"+STR0038+"</TH>" 																						// "Nome Cliente"
	cHTML += "<TH>"+STR0039+"</TH>" 																						// "Municipio/UF"
	cHTML += "<TH>"+STR0040+"</TH>" 																						// "Status"
	cHTML += "<TH>"+STR0041+"</TH>" 																						// "Frota"
	cHTML += "<TH>"+STR0042+"</TH>" 																						// "Data de Emissใo"
	cHTML += "<TH>"+STR0043+"</TH>" 																						// "Data de Programa็ใo"
	cHTML += "<TH>"+STR0044+"</TH>" 																						// "Data do Aceite"
	cHTML += "</TR>" + CRLF
	FWrite(nArq,cHtml,Len(cHtml))
EndIf
*/

dbSelectArea("TRB")
SetRegua(RecCount())

While TRB->(!Eof()) 
        
	IncRegua()
	cAs 	:= TRB->FQ5_AS
	cNome   := TRB->FQ5_NOMCLI
	cMunLoc := TRB->FQ5_DESTIN
	cFrota  := TRB->FQ5_GUINDA
	cStatus := TRB->FQ5_STATUS + " - " + aOpcCmb[aScan(aOpcCmb, {|x| x[1]==TRB->FQ5_STATUS}), 2]
	dDatEmi := DtoC(StoD(TRB->FQ5_DATGER))
	dDatPrg := DtoC(StoD(TRB->FQ5_DTPROG))
	dDatAce := DtoC(StoD(TRB->FQ5_ACEITE))

	If nLin > 55 																// Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    	Cabec(Titulo , CABEC1 , CABEC2 , NomeProg , Tamanho , nTipo)
		nLin := 8
	EndIf

    @ nLin, 000	     PSay cAs 
    @ nLin, pCol()+1 PSay cNome 
    @ nLin, pCol()+1 PSay cMunLoc 
    @ nLin, pCol()+1 PSay cStatus 
    @ nLin, pCol()+1 PSay cFrota 
    @ nLin, pCol()+2 PSay dDatEmi 
    //@ nLin, pCol()+2 PSay dDatPrg 
	@ nLin, pCol()+2 PSay dDatAce 
    
	/*
	If MV_PAR14 == 1															// Se for exportar para o Excel
		cHtml := "<tr>"
		cHtml += "<td>&nbsp;" + cAS 	+ "</td>"
		cHtml += "<td>&nbsp;" + cNome 	+ "</td>"
		cHtml += "<td>&nbsp;" + cMunLoc + "</td>"
		cHtml += "<td>&nbsp;" + cStatus + "</td>"
		cHtml += "<td>&nbsp;" + cFrota  + "</td>"
		cHtml += "<td>&nbsp;" + dDatEmi	+ "</td>"
		cHtml += "<td>&nbsp;" + dDatPrg	+ "</td>"				
		cHtml += "<td>&nbsp;" + dDatAce	+ "</td>"				
		cHtml += "</tf>"+CRLF
		FWrite(nArq , cHtml , Len(cHtml)) 
	EndIf
	*/
      	
    nLin := nLin + 1 															// Avanca a linha de impressao

	dbSelectArea("TRB")
	TRB->(dbSkip())
EndDo 
		

TRB->(dbCloseArea())

// --> Finaliza a execucao do relatorio... 
Set Device To Screen

// --> Se impressao em disco, chama o gerenciador de impressao... 
If aReturn[5]==1
   dbCommitAll()
   Set Printer To
   OurSpool(wnrel)
EndIf

MS_FLUSH()

/*
If MV_PAR14 == 1																// Se for exportar para o Excel
	cHtml := " </table></body></html>"+CRLF
	FWrite(nArq,cHtml,Len(cHtml))
	fClose(nArq)																// Fechamos o arquivo padrใo HTML
	CpyS2T(GetSrvProfString("Startpath","")+cArquivo, AllTrim(GetTempPath()), .T.)		// Copia Arquivo HTML do Server\System p/ temporแrio do cliente
	FErase(cArquivo)															// Remove arquivo do Server\System

	If ApOleClient("MsExcel") 													// Se tem Excel no cliente. Abrimos o excel com o arquivo HTML
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(AllTrim(GetTempPath()) + cArquivo)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else																		// Se nใo encontrou o Excel, o S.O. decide como abrir
		ShellExecute("open",AllTrim(GetTempPath()) + cArquivo,"","",1)
	EndIf
EndIf
*/

RestArea(aArea)

Return



// ======================================================================= \\
Static Function ValidPerg(cPerg)
// ======================================================================= \\
/*
Local _SALIAS := ALIAS()
Local aRegs   := {}
Local I,J

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PadR(cPerg,10) 

//         {Grupo,Ordem,cPergunt			,cPerSpa             ,cPerEng            ,cVar    ,Tip,Tam,Dec,Presel,GSC,cValid                                   ,cVar01    ,cDef01       ,cDefSpa1    ,cDefEng1  ,cCnt01,cVar02,cDef02       ,cDefSpa2     ,cDefEng2    ,cCnt02,cVar03,cDef03   ,cDefSpa3   ,cDefEng3,cCnt03,cVar04,cDef04    ,cDefSpa4  ,cDefEng4  ,cCnt04,cVar05,cDef05     ,cDefSpa5   ,cDefEng5  ,cCnt05,cF3    ,cPyme,cGrpSxg,cHelp,Picture})
aAdd(aRegs,{cPerg,"01" ,"Numero AS de ?"   ,"ฟDe Numero AS ?"    ,"From AS Number ?" ,"mv_ch1","C",27 ,00 ,00    ,"G",""                                       ,"MV_PAR01",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,"DTQAS",""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"02" ,"Numero AS ate ?"  ,"ฟA Numero AS ?"     ,"To AS Number ?"   ,"mv_ch2","C",27 ,00 ,00    ,"G","NaoVazio() .And. (MV_PAR02 >= MV_PAR01)","MV_PAR02",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,"DTQAS",""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"03" ,"Cliente de ?"     ,"ฟDe Cliente ?"      ,"From Customer ?"  ,"mv_ch3","C",06 ,00 ,00    ,"G",""                                       ,"MV_PAR03",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,"SA1"  ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"04" ,"Loja de ?"        ,"ฟDe Tienda ?"       ,"From store ?"     ,"mv_ch4","C",02 ,00 ,00    ,"G",""                                       ,"MV_PAR04",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"05" ,"Cliente ate ?"    ,"ฟA Cliente ?"       ,"To Customer ?"    ,"mv_ch5","C",06 ,00 ,00    ,"G","NaoVazio() .And. (MV_PAR05 >= MV_PAR03)","MV_PAR05",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,"SA1"  ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"06" ,"Loja ate ?"       ,"ฟA Tienda ?"        ,"To store ?"       ,"mv_ch6","C",02 ,00 ,00    ,"G","NaoVazio() .And. (MV_PAR06 >= MV_PAR04)","MV_PAR06",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""         ,""        ,""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"07" ,"Status de ?"      ,"ฟDe Estatus ?"      ,"From Status ?"    ,"mv_ch7","C",01 ,00 ,00    ,"C",""                                       ,"MV_PAR07","Em Aberto"  ,"En abierto","Opened"  ,""    ,""    ,"Encerrada"  ,"Cerrada"    ,"Concluded" ,""    ,""    ,"Fechada","Terminada","Closed",""    ,""    ,"Aprovada","Aprobada","Approved",""    ,""    ,"Cancelada","Cancelado","Canceled",""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"08" ,"Status ate ?"     ,"ฟA Estatus ?"       ,"To Status ?"      ,"mv_ch8","C",01 ,00 ,00    ,"C","NaoVazio() .And. (MV_PAR08 >= MV_PAR07)","MV_PAR08","Em Aberto"  ,"En abierto","Opened"  ,""    ,""    ,"Encerrada"  ,"Cerrada"    ,"Concluded" ,""    ,""    ,"Fechada",""         ,"Closed",""    ,""    ,"Aprovada","Aprobada","Approved",""    ,""    ,"Cancelada","Cancelado","Canceled",""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"09" ,"Frota de ?"       ,"ฟDe Flota ?"        ,"From Fleet ?"     ,"mv_ch9","C",16 ,00 ,00    ,"G",""                                       ,"MV_PAR09",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,"ST9"  ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"10" ,"Frota ate ?"      ,"ฟA Flota ?"         ,"To Fleet ?"       ,"mv_cha","C",16 ,00 ,00    ,"G","NaoVazio() .And. (MV_PAR10 >= MV_PAR09)","MV_PAR10",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,"ST9"  ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"11" ,"Emitido de ?"     ,"ฟDe Perํodo ?"      ,"From period ?"    ,"mv_chb","D",08 ,00 ,00    ,"G",""                                       ,"MV_PAR11",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"12" ,"Emitido ate ?"    ,"ฟA Perํodo ?"       ,"To period ?"      ,"mv_chc","D",08 ,00 ,00    ,"G","NaoVazio() .And. (MV_PAR12 >= MV_PAR11)","MV_PAR12",""           ,""          ,""        ,""    ,""    ,""           ,""           ,""          ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"13" ,"Ordem ?"          ,"ฟOrden ?"           ,"Order?"           ,"mv_chd","N",01 ,00 ,00    ,"C",""                                       ,"MV_PAR13","Status"     ,"Estatus"   ,"Status"  ,""    ,""    ,"Dt. Emissao","Fc. Emisi๓n","Issue Dt"  ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,""     ,""   ,""     ,""   ,""     })
aAdd(aRegs,{cPerg,"14" ,"Exporta Excel ?"  ,"ฟExportar a Excel?" ,"Export to Excel?" ,"mv_che","N",01 ,00 ,00    ,"C",""                                       ,"MV_PAR14","Sim"        ,"Si"        ,"Yes"     ,""    ,""    ,"Nใo"        ,"No"         ,"No"        ,""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,""     ,""   ,""     ,""   ,""     })
//dd(aRegs,{cPerg,"15" ,"Tipo de Servico ?","ฟTipo de servicio ?","Type of Service ?","mv_chf","C",01 ,00 ,00    ,"G",""                                       ,"MV_PAR15","Locacao"    ,"Asignaci๓n","Rental"  ,""    ,""    ,"Equipamento","Equipamiento","Equipment",""    ,""    ,""       ,""         ,""      ,""    ,""    ,""        ,""        ,""        ,""    ,""    ,""         ,""        ,""         ,""    ,"78"   ,""   ,""     ,""   ,""     })

For I:=1 To Len(aRegs)
	If !dbSeek(cPerg+aRegs[I,2])
		RecLock("SX1",.T.)
		For J:=1 To FCount()
			If J <= Len(aRegs[I])
				FIELDPUT(J,aRegs[I,J])
			EndIf
		Next J 
		MsUnLock()
	EndIf
Next I 

dbSelectArea(_SALIAS)
*/
Return

