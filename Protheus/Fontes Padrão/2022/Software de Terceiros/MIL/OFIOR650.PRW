// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º  08    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "OFIOR650.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOR650 º Autor ³ Andre Luis Almeida º Data ³  22/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relacao dos Clientes por data da ultima compra SA1         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR650
Private cNomeRel:= "OFIOR650"
Private cPerg   := "OFR650"
Private aClientes := {} 
Private cTitulo := STR0001 //Clientes por Data da ultima Compra
ValidPerg()
If Pergunte(cPerg,.t.)
	FS_OFR650()
EndIf
Return

Static Function FS_OFR650()
Local lA1_IBGE  := IIf(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Local cQryAlias := "SQLRELAT"
Local cQuery    := ""
cQuery := "SELECT SF2.F2_CLIENTE, SF2.F2_LOJA, MAX(SF2.F2_EMISSAO) AS DATAF2 FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SF2")+" SF2 "
cQuery += "WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
if MV_PAR05 == 1
	cQuery += "SF2.F2_PREFORI = '"+GetNewPar("MV_PREFBAL","BAL")+"' AND "
elseif MV_PAR05 == 2
	cQuery += "SF2.F2_PREFORI = '"+GetNewPar("MV_PREFOFI","OFI")+"' AND "
elseif MV_PAR05 == 3
	cQuery += "SF2.F2_PREFORI = '"+GetNewPar("MV_PREFVEI","VEI")+"' AND "
endif
cQuery += "SF2.F2_DOC = SD2.D2_DOC AND "
cQuery += "SF2.F2_SERIE = SD2.D2_SERIE AND "
cQuery += "SD2.D2_TES = SF4.F4_CODIGO AND "
cQuery += "SF4.F4_OPEMOV = '05' AND "
cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
cQuery += "SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND "
cQuery += "SD2.D_E_L_E_T_=' '  AND SF2.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' ' "
cQuery += "GROUP BY SF2.F2_CLIENTE, SF2.F2_LOJA"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
//
SA1->(DBSetOrder(1))
VAM->(DBSetOrder(1))
while !((cQryAlias)->(eof()))
	if (cQryAlias)->(DATAF2) > DTOS(DDATABASE - MV_PAR01)
		( cQryAlias )->( DbSkip() )
		loop
	endif
	if !Empty(MV_PAR02)
		if (cQryAlias)->(DATAF2) < DTOS(DDATABASE - MV_PAR02)
			( cQryAlias )->( DbSkip() )
			loop
		endif
	endif
	//
	DBSelectArea("SA1")
	DBSeek(xFilial("SA1") + (cQryAlias)->(F2_CLIENTE) + (cQryAlias)->(F2_LOJA)  )
	if !Empty(MV_PAR04)
		if SA1->A1_SATIV1 != MV_PAR04
			( cQryAlias )->( DbSkip() )
			loop
		endif
	endif
	If lA1_IBGE
		DBSelectArea("VAM")
		DbSeek( xFilial("VAM") + SA1->A1_IBGE )
	EndIf
	Aadd(aClientes,{ .t. , stod((cQryAlias)->( DATAF2 )) , (cQryAlias)->(F2_CLIENTE) , (cQryAlias)->(F2_LOJA) , SA1->A1_NOME , 	IIf(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+left(SA1->A1_TEL,15) ,	left(Transform(SA1->A1_CGC,	IIf(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18) , IIf(lA1_IBGE,left(VAM->VAM_DESCID,21)+"-"+VAM->VAM_ESTADO,left(SA1->A1_MUN,21)+"-"+SA1->A1_EST) , SA1->A1_SATIV1 + " " + Left(Posicione("SX5",1,xFilial("SX5")+ "T3" + SA1->A1_SATIV1 ,"X5_DESCRI"),12),SA1->A1_END,left(SA1->A1_BAIRRO,30),Transform(SA1->A1_CEP,"@R 99999-999") })
	( cQryAlias )->( DbSkip() )
EndDo
//
( cQryAlias )->( dbCloseArea() )
//
FS_IMPRIMIR()
Return

Static Function FS_IMPRIMIR()
Local ni := 0
Local i  := 0
Private cDesc1  := cTitulo
Private cDesc2  := ""
Private cDesc3  := ""
Private cAlias  := "SA1"
Private aReturn := {STR0002,1,STR0003,2,2,1,"",1} //Zebrado # Administracao
Private nLin    := 0
Private cTamanho:= "M"          // P/M/G
Private Limite  := 132           // 80/132/220
Private nLastKey:= 0
Private nCaracter:= 15
Private cabec1  := STR0004 //"Cod.Loja  Cliente                      CNPJ/CPF           Cidade/UF                Ult.Comp Fone                 Segmento"
Private cabec2  := ""
Private lAbortPrint:= .f.
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "SA1"
Private Li      := 132
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.F.,cTamanho)
If nLastKey == 27
	Return
EndIf
PERGUNTE(cPerg,.f.)
cTitulo += " ("+Transform(MV_PAR01,"@E 9999")+" " + STR0005 + ")" //dias
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
if mv_par06 == 1
	nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
Endif
If MV_PAR03 == 1
	@ nLin++ , 00 psay repl("-",132)
EndIf
cNomes   := ""
cEnds    := ""
cCeps    := ""
cBairros := ""
nColunas := mv_par07
if mv_par06 == 2
	Do While .T.
		If !(MsgYesNo(STR0021,STR0020)) //Deseja Executar Teste de Impressora p/ Posicionamento da Etiqueta? ### Teste de Impressora
			Exit
		EndIf
		For ni:=1 to 4
			nLin++
			For i:=1 to MV_PAR07
				@ nLin,(i-1)*36+1 PSAY Repl("*",34)+"  "
			Next
		Next
		nLin+=2
	EndDo
Endif
For ni := 1 to len(aClientes)
	If MV_PAR03 == 1
		If nLin >= 58
			nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
			@ nLin++ , 00 psay repl("-",132)
		EndIf
	Else
		If nLin >= 60
			nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		EndIf
	EndIf
	if mv_par06 == 1
		@ nLin++ , 00 psay left(aClientes[ni,3]+"-"+aClientes[ni,4]+" "+aClientes[ni,5]+space(38),38) +" "+ aClientes[ni,7] +" "+ aClientes[ni,8] +" "+ Transform(aClientes[ni,2],"@D") +" "+ aClientes[ni,6] +" "+ aClientes[ni,9]
		If MV_PAR03 == 1
			@ nLin++ , 18 psay aClientes[ni,10] +"  "+ aClientes[ni,11] +"  "+STR0006+": "+ aClientes[ni,12]
			@ nLin++ , 00 psay repl("-",132)
		EndIf
	Else
		if !(nColunas > 0 )
			nLin++
			@ nLin++, 1 PSAY cNomes
			@ nLin++, 1 PSAY cEnds
			@ nLin++, 1 PSAY cBairros
			@ nLin++, 1 PSAY cCeps
			nLin++
			nColunas := mv_par07
			cNomes := cEnds := cBairros := cCeps := ""
		Endif
		nColunas--
		cNomes   += left(aClientes[ni,5],34) +"  "
		cEnds    += left(aClientes[ni,10],34)+"  "
		cBairros += left(aClientes[ni,11]+space(34),34)+"  "
		cCeps    += aClientes[ni,12]+" "+aClientes[ni,8]+"  "
	EndIf
Next
If mv_par06 == 2 // Etiqueta
	If !Empty(cNomes+cEnds+cBairros+cCeps)
		nLin++
		@ nLin++, 1 PSAY cNomes
		@ nLin++, 1 PSAY cEnds
		@ nLin++, 1 PSAY cBairros
		@ nLin++, 1 PSAY cCeps
	EndIf
EndIf
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

MS_FLUSH()
Return

Static Function ValidPerg
Local i, j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,LEN(SX1->X1_GRUPO))
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01",STR0019,"","","mv_ch1","N",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //A quantos dias nao compra 
AADD(aRegs,{cPerg,"02",STR0018,"","","mv_ch2","N",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //Limite maximo de dias 
AADD(aRegs,{cPerg,"03",STR0018,"","","mv_ch3","N",1,0,0,"C","","mv_par03",STR0017,"","","","",STR0016,"","","","","","","","","","","","","","","","","","","",""}) //Mostra Endereco/Bairro/CEP  ### Sim ### nao
AADD(aRegs,{cPerg,"04",STR0015,"","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","T3",""}) //Segmento do Cliente  
AADD(aRegs,{cPerg,"05",STR0014,"","","mv_ch5","N",1,0,0,"C","","mv_par05",STR0014,"","","","",STR0008,"","","","",STR0013,"","","","",STR0012,"","","","","","","","","",""}) //Prefixo ### Balcao ### Oficina ### Veiculos ### Todos     
AADD(aRegs,{cPerg,"06",STR0011,"","","mv_ch6","N",1,0,0,"C","","mv_par06",STR0010,"","","","",STR0009,"","","","","","","","","","","","","","","","","","","",""}) //Tipo de Impressao ### Relatorio ### Etiqueta
AADD(aRegs,{cPerg,"07",STR0007,"","","mv_ch7","N",2,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //Numero de Colunas Etiqueta
For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)
Return