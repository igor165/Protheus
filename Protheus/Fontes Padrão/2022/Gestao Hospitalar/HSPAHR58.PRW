#INCLUDE "HSPAHR58.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR58 บ       ณ MARCELO JOSE       บ Data ณ 17/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ESTATISTICA DE INTERNACAO                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHR58()
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local nLin           := 80     
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private tamanho      := "G"
Private cTitulo      := STR0003 //"ESTATISTICA DE INTERNACAO"
Private limite       := 132
Private m_pag        := 01
Private nomeprog     := "HSPAHR58"
Private nTipo        := 18
Private aReturn      := { STR0004 , 1, STR0005 , 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "HSPAHR58"
Private cString      := ""
Private aContas      := {}
Private cPerg        := "HSPR58"
Private nMaxLin      := 0
Private cAnoMes      := ""
Private cLimDataE    := ""
Private nConsDataS   := "" 
Private nResul       :=0            
Private nQtPa        := 0
Private aMatImp      := {},;
        aMatTemp     := {},;
        aMatQbr1     := {},;
        aMesAno      := {}
        aVetMesSTR   := {STR0014, STR0015, STR0016, ; //Adminssoes###Altas###"Pacientes dia:"
                         STR0017, STR0018, STR0019,;//"Nro Leitos Utiliz. :"###"Entrada Transf.Unid:"###"Saida Transf. Unid.:" 
                         STR0020, STR0021, STR0022,;//"Alta por Obito ....:"###"Transf.p/ Hospitais:"###"Leitos Dia ........:" 
                         STR0023, STR0024, STR0025,;//"Numero de saidas ..:"###"Tx. Mortalid. geral:"###"Media  Permanencia :"  
                         STR0026, STR0027, }//"Tx. Ocup.Hospitalar:"###"Indice Rotatividade:"
        aIndicad     := {{STR0037, "999999"},	{STR0038, "999999"}, {STR0039, "999999"}, {STR0040, "999999"},; //"Admisso๕es"###"Altas"###"Pacientes dia"###"Nro Leitos"
 																			 			{STR0041, "999999"},	 {STR0042, "999999"}, {STR0043, "999999"},; //"Entrada Transf.Unid"###"Saida Transf. Unid."###"Alta por Obito"
 																			 		 {STR0044, "999999"}, {STR0045, "999999"}, {STR0046, "999999"},; //"Transf.p/ Hospitais"###"Leitos Dia"###"Numero de saidas"
 																			 		 {STR0047, "@E 9999.99"}, {STR0048, "@E 9999.99"}, {STR0049, "@E 9999.99"},; //"Tx. Mortalid. geral"###"Media  Permanencia"###"Tx. Ocup.Hospitalar"
																				 		 {STR0050, "@E 9999.99"}}      //"Indice Rotatividade"
	
        cCabec1      := STR0006 //"Parametros           "
        cCabec2      := ""         

Private cDoCodLoc    := ""
Private cAteCodLoc   := ""
Private cDoCodCon    := ""
Private cAteCodCon   := ""
Private cMesRef			   := ""
Private nMesRetr     := 0
Private nSaltPag     := 0
Private nAgruPor     := 0
Private aMatGer      := {} //Matriz com total geral
Private nSetores     := 0 

 
AAdd(aMatGer,{01,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0014}) //admissoes       
AAdd(aMatGer,{02,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0015}) //altas           
AAdd(aMatGer,{03,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0016}) //pacientes dia   
AAdd(aMatGer,{04,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0017}) //nro leitos      
AAdd(aMatGer,{05,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0018}) //entrada transf unid 
AAdd(aMatGer,{06,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0019}) //saida transf unid
AAdd(aMatGer,{07,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0020}) //alta por obito
AAdd(aMatGer,{08,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0021}) //transf para hospitais
AAdd(aMatGer,{09,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0022}) //leitos dia      
AAdd(aMatGer,{10,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0023}) //numero de saidas

If !HS_ExisDic({{"C", "GAV_DTCRIA",.T.}})
	Return(.F.)
EndIf

If !Pergunte(cPerg,.T.)
	Return( NIL )
EndIf

cDoCodLoc  := MV_PAR01
cAteCodLoc := MV_PAR02
cMesRef	   := MV_PAR03
nMesRetr   := MV_PAR04
nSaltPag   := MV_PAR05
nAgruPor   := MV_PAR06

nMaxLin := HS_MaxLin(MV_PAR07)

wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)


If nLastKey == 27
	Return( NIL )
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return( NIL )
Endif

Processa({|| RunRepRel()             }, cTitulo)
Processa({|| FS_CALCM()              }, cTitulo)
Processa({|| IMPREL58(cTitulo, nLin )}, cTitulo)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRUNREPREL บ       ณ MARCELO JOSE       บ Data ณ 17/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXECUTA A IMPRESSAO DO RELATORIO                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RunRepRel()

Local cQuery     := "",;
      nCtaFor    := 1,;
      nPos       := 0,;
      cAltaObt   := GETMV("MV_TPALTA"),;
      cAltaTra   := GETMV("MV_ALTATRA"),;  
      cRegAte    := "",;
      nMes := 0, nAno := 0, nCtaMes := 1,;
      nAdmis     := 0, nAltas := 0, nPacDia := 0, nEntTra := 0, nSaiTra := 0, nAltObt := 0, nTraHos := 0, nTotAlta := 0


          
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta cabec MES/ANO            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

AADD(aMesAno,{"","","","","","","","","","","",""})
nMes := Val(Substr(cMesRef, 1, 2))
nAno := Val(Substr(cMesRef, 4, 4))
FOR nCtaFor := 1 to nMesRetr
 	aMesAno[1,nCtaFor] := StrZero(nMes,2) + "/" + Str(nAno, 4, 0)
	nMes := nMes - 1
	cCabec1 := cCabec1 + aMesAno[1,nCtaFor]+"   "
	If nMes <= 0
		nMes := 12
		nAno := nAno - 1
	EndIf
Next
cCabec1 := cCabec1 + STR0007  //"   Total"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia PROCESSAMENTO           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcRegua(nMesRetr)  // seta o tamanho da regua

For nCtaMes := 1 to nMesRetr
IncProc(STR0008 + AllTrim(Str(nCtaMes)) ) //"Proc. Contagem do Mes: "
	
	cAnoMes := Substr(DTOS(CTOD("01/" + Substr(aMesAno[1,nCtaMes], 1, 2) + "/" + Substr(aMesAno[1,nCtaMes], 4, 4))) ,1, 6)
	
	cQuery := "SELECT DISTINCT GCS_NUMLEI, GCS.GCS_NOMLOC, GB1.GB1_CODLOC, GCY.GCY_REGATE, GAV.GAV_TIPO, GCY.GCY_TPALTA, "
	cQUery += "GAV.GAV_ESTATI, GCY.GCY_CODLOC, GCY_DATATE, GCY_DATALT "
	cQuery += " FROM " + RetSQLName("GCY") + " GCY "
	cQuery += " JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE "
	cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))
	cQuery += "           AND GB1.GB1_DATAE <= '" + cLimDataE + "' "
	cQuery += "           AND (GB1.GB1_DATAS >= '" + cAnoMes + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
	cQuery += " 										AND GB1.GB1_CODLOC BETWEEN '" + cDoCodLoc + "' AND '" + cAteCodLoc + "' "
	cQuery += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC
	cQuery += " 									 AND GAV.GAV_QUARTO = GB1.GB1_QUARTO	AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "
	cQuery += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "
	cQuery += "          AND GCS.GCS_TIPLOC = '3' "
	cQuery += "WHERE "
	cQuery += " GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' AND GCY.GCY_ATENDI = '0' "
	cQuery += " AND (GCY.GCY_DATATE BETWEEN '" + cAnoMes + "01" + "' AND '" + cLimDataE + "' OR
	cQuery += "       GCY.GCY_DATALT BETWEEN '" + cAnoMes + "01" + "' AND '" + cLimDataE + "')"
	cQuery += " ORDER BY GB1.GB1_CODLOC, GCY.GCY_REGATE , GAV.GAV_TIPO"
	
	cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS "R58QRY"
	
	DbSelectArea("R58QRY")
	dbGotop()
	While !Eof()
		
		nPos:= aScan(aMatImp, {| aVet | aVet[1] == R58QRY->GB1_CODLOC	})
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDEFINICAO DA MATRIZ 3D - TRIDIMENSIONAL    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//
		If nPos <= 0
			aadd(aMatImp,{ R58QRY->GB1_CODLOC,R58QRY->GCS_NOMLOC, "", "",	;
			{0,0,0,0,0,0,0,0,0,0,0,0},; //Admissoes
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0},;
			{0,0,0,0,0,0,0,0,0,0,0,0}	})
			
			nPos := Len(aMatImp)
		EndIf
		
		nAdmis    := IIF(cRegAte <> R58QRY->GCY_REGATE .And. R58QRY->GCY_DATATE >= cAnoMes+"01" .And. R58QRY->GCY_DATATE <= cLimDataE, 1, 0)
		nAltas    := IIF(R58QRY->GCY_CODLOC == R58QRY->GB1_CODLOC .And. !EMPTY(R58QRY->GCY_TPALTA) .And. !(R58QRY->GCY_TPALTA $ cAltaObt+cAltaTra) .And. ;
		R58QRY->GCY_DATALT >= cAnoMes+"01" .And. R58QRY->GCY_DATALT <= cLimDataE, 1, 0)
		
		nTotAlta  := IIF(R58QRY->GCY_CODLOC == R58QRY->GB1_CODLOC .And. !Empty(R58QRY->GCY_TPALTA) .And. ;
		R58QRY->GCY_DATALT >= cAnoMes+"01" .And. R58QRY->GCY_DATALT <= cLimDataE, 1, 0)
		aTransf   := FS_MovLei(R58QRY->GCY_REGATE, R58QRY->GB1_CODLOC, aMesAno[1,nCtaMes], cAltaTra)
		nEntTra   := IIf(aTransf[1], 1, 0)
		nSaiTra   := IIf(aTransf[2], 1, 0)
		
		DbSelectArea("R58QRY")   // APOS A EXECUCAO DA FUNCAO FS_MOVLEI RETORNA PARA O ALIAS DA QUERY
		
		nAltObt   := IIF(R58QRY->GCY_CODLOC == R58QRY->GB1_CODLOC .And. R58QRY->GCY_TPALTA $ cAltaObt ,1,0)
		nTraHos   := IIF(R58QRY->GCY_CODLOC == R58QRY->GB1_CODLOC .And. R58QRY->GCY_TPALTA $ cAltaTra ,1,0)
		
		aMatImp[nPos,05][nCtaMes] += nAdmis     // Admissoes
		aMatImp[nPos,06][nCtaMes] += nAltas     // Altas
		
		
		aMatImp[nPos,09][nCtaMes] += nEntTra    // Entrada Transf.Unid.
		aMatImp[nPos,10][nCtaMes] += nSaiTra    // Saida Transf. Unid.
		aMatImp[nPos,11][nCtaMes] += nAltObt    // Alta por Obito
		aMatImp[nPos,12][nCtaMes] += nTraHos    // Transf.p/ Hospitais
		aMatImp[nPos,19][nCtaMes] += nTotAlta   // Saidas
		aMatImp[nPos, 08][nCtaMes] :=  R58QRY->GCS_NUMLEI  //Leitos
		
		// esta definindo logo abaixo  => Leitos Dia
		// esta definindo logo abaixo  => Numero de saidas
		// esta definindo logo abaixo  => Tx. Mortalid. geral
		// esta definindo logo abaixo  => Media  Permanencia
		// esta definindo logo abaixo  => Tx. Ocup.Hospitalar
		// esta definindo logo abaixo  => Indice Rotatividade
		
		cRegAte := R58QRY->GCY_REGATE
		DbSkip()
	EndDo
	
	
	
	dbCloseArea()  // fecho o alias da query
       
Next nCtaMes

aSort(aMatImp,,,{|x,y| X[1]+X[3] < Y[1]+Y[3] })

Return( Nil )                                                               
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CALCM  บ       ณ MARCELO JOSE       บ Data ณ 20/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CALCULO DAS MEDIAS DOS INDICES                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function FS_CALCM()
Local nCtaMes := 1, nCtaSet := 1, cAnoMes :=  "", nQteDiaMes := 0
Local aSetor  := {}

ProcRegua(nMesRetr)  // seta o tamanho da regua
Private aVetDados    := {}
Private aVetDias     := {}





For nCtaMes := 1 to nMesRetr
	
	IncProc( STR0009 + AllTrim(Str(nCtaMes)) ) //"Proc. Indicadores do Mes: "
	
	cAnoMes := Substr(DTOS(CTOD("01/" + Substr(aMesAno[1,nCtaMes], 1, 2) + "/" + Substr(aMesAno[1,nCtaMes], 4, 4))) ,1, 6)
	
	// pega a quantidade de DIAS DO MES
	nQteDiaMes := VAL(SUBS(DTOC(LASTDAY(STOD(cAnoMes+"01"))),1,2))
	
	aSetor := {}
	
	// faco o processamento dos indices medidos de todos os setores convenio no mes.
	For nCtaSet := 1 to Len(aMatImp)
		
		// Total de pacientes internados por mes
		//(Pacientes Internados + Pacientes Admitidos + Pacientes transferidos) - (Saํdas + Saํdas por Transfer๊ncias)
		
		aMatImp[nCtaSet, 07][nCtaMes] :=  FS_PacDia(aMesAno[1, nCtaMes], aMatImp[nCtaSet, 01], cAnoMes, aMatImp[nCtaSet, 03]) ///nQteDiaMes
		
		
		
		// Leitos Dia (Nro de Leitos * qtde dias do mes)
		aMatImp[nCtaSet, 13][nCtaMes] :=NoRound(aMatImp[nCtaSet, 08][nCtaMes] * nQteDiaMes, 0)
		
		// Numero de saidas  (Altas + Altas por obito + transf hospitais)
		aMatImp[nCtaSet,14][nCtaMes] := aMatImp[nCtaSet,06][nCtaMes]  + aMatImp[nCtaSet,11][nCtaMes] + aMatImp[nCtaSet,12][nCtaMes]
		
		// Taxa de Mortalidade geral     (Alta por Obito / Numero de saidas)* 100
		aMatImp[nCtaSet,15][nCtaMes] := ( aMatImp[nCtaSet,11][nCtaMes] /   aMatImp[nCtaSet,14][nCtaMes] ) * 100
		
		// Media  Permanencia                Pacientes Dia       /     Numero de saidas
		aMatImp[nCtaSet,16][nCtaMes] := aMatImp[nCtaSet,07][nCtaMes] /  aMatImp[nCtaSet,14][nCtaMes] //* nQteDiaMes
		
		// Taxa de Ocupacao Hospitalar   Pacientes Dia / Leitos Dia
		aMatImp[nCtaSet,17][nCtaMes] := aMatImp[nCtaSet,07][nCtaMes]/ aMatImp[nCtaSet,13][nCtaMes] * 100
		
		// INDICE DO ROTATIVIDADE         Numero de saidas       /   Numero de Leitos
		aMatImp[nCtaSet,18][nCtaMes] := ( aMatImp[nCtaSet,14][nCtaMes] / NoRound(aMatImp[nCtaSet, 08][nCtaMes], 0) )
		
		
		//Totais Gerais
		
		aMatGer[01, nCtaMes + 1] += aMatImp[nCtaSet, 05][nCtaMes] //Total Geral de Admissoes
		aMatGer[02, nCtaMes + 1] += aMatImp[nCtaSet, 06][nCtaMes] //Total Geral de Altas
		aMatGer[03, nCtaMes + 1] += aMatImp[nCtaSet, 07][nCtaMes] //Total Geral de Pacientes Dia
		aMatGer[05, nCtaMes + 1] += aMatImp[nCtaSet, 09][nCtaMes] //Total Geral de Entrada transf unid
		aMatGer[06, nCtaMes + 1] += aMatImp[nCtaSet, 10][nCtaMes] //Total Geral de Saida Transf. Unid.
		aMatGer[07, nCtaMes + 1] += aMatImp[nCtaSet, 11][nCtaMes] //Total Geral de Altas Por Obito
		aMatGer[08, nCtaMes + 1] += aMatImp[nCtaSet, 12][nCtaMes] //Total Geral de Transf.p/ Hospitais
		aMatGer[10, nCtaMes + 1] += (aMatImp[nCtaSet, 06][nCtaMes]+aMatImp[nCtaSet, 11][nCtaMes]+aMatImp[nCtaSet, 12][nCtaMes])
		aMatGer[04, nCtaMes + 1] += aMatImp[nCtaSet, 08][nCtaMes] //Leitos
		aMatGer[09, nCtaMes + 1] += aMatImp[nCtaSet, 13][nCtaMes] //Total Geral de Leitos Dia desse setor
		
		
	Next nCtaSet
	
Next nCtaMes

nSetores := Len(aSetor)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPREL58  บ       ณ MARCELO JOSE       บ Data ณ 17/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXECUTA A IMPRESSAO DO RELATORIO                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function IMPREL58(cTitulo, nLin)
Local nCtaFor   := 1,;
      nTotFor   := 0,;
      nCtaMes   := 1,;
      nCol      := 22,;
      nTot      := 0,;
      nTotTmp   := 0,;
      nCtaInd   := 0


Private cQbr1 := "",  cQbr2 := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLoop de Impressao dos dados    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

ProcRegua(Len(aMatImp))  // seta o tamanho da regua



For nCtaFor = 1 to Len(aMatImp)
	
	IncProc( STR0010 + AllTrim(Str(nCtaFor)) )  //"Imprimindo: "
	
	If lAbortPrint
		@nLin,00 PSAY STR0011 //"INTERROMPIDO PELO USUARIO"
		Exit
	Endif
	
	If nAgruPor <> 2 .And. nLin > 55
		nLin := FS_ImpCabe(nLin)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณcontrole de quebra por CONVENIOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nAgruPor <> 2 .And. cQbr1 != aMatImp[nCtaFor, 1]
		
		If nCtaFor > 1
			
			If nSaltPag == 2  // CONTROLE DAS PERGUNTAS SE SALTA PAGINA.
				nLin := FS_ImpCabe(nLin)
			Else
			    nLin := nLin + 5
			EndIf
		EndIf
		
		If nLin + 5 > nMaxLin
			nLin := FS_ImpCabe(nLin)
		EndIf
		
		@ nLin,00  Psay STR0013 + aMatImp[nCtaFor, 1] + " - " + aMatImp[nCtaFor, 2]
		nLin++
		cQbr1 := aMatImp[nCtaFor, 1]
		
		nLin++
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ                  I M P R E S S A O    D O S    I T E N S                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	For nCtaInd := 1 to 14 //Indicadores     //verificar se ้ 4
		nLin := FS_ImpIten(nCtaFor, nCtaInd, nLin, nAgruPor <> 2)
	Next
	
Next nCtaFor


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImpressao do RESUMO            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//imprime total geral

nLin := FS_ImpCabe(nLin)
























@ nLin,00  Psay STR0033 //"TOTAL GERAL"
nLin := nLin + 2
nCol := 22

For nTotFor := 1 to 10
	@ nLin,00  Psay aMatGer[nTotFor][15]
	nTot := 0
	For nCtaMes := 1 to nMesRetr
		@ nLin,nCol  Psay TRANSFORM(aMatGer[nTotFor][nCtaMes+1], aIndicad[nTotFor, 2])
		nCol := nCol + 10
		If nTotFor==4    //Leitos divide
			nTot += aMatGer[nTotFor][nCtaMes+1]/nMesRetr
			
		ELSE
			nTot += aMatGer[nTotFor][nCtaMes+1] // Totaliza a soma de todos os meses
		ENDIF
		
	Next
	@ nLin,nCol  Psay TRANSFORM(nTot, aIndicad[nTotFor, 2])
	nlin ++
	nCol := 22
Next

// calcula Taxa de Mortalidade geral
@ nLin,00  Psay STR0024
nCol    :=21
nTotTmp :=0
For nCtaMes:= 1 to nMesRetr
	nTot := (aMatGer[7][nCtaMes+1] / aMatGer[10][nCtaMes+1]) * 100
	@ nLin,nCol  Psay TRANSFORM(nTot, aIndicad[nTotFor, 2])
	nCol := nCol + 10
	nTotTmp += nTot
Next
@ nLin,nCol  Psay TRANSFORM(nTotTmp/nMesRetr, aIndicad[nTotFor, 2])
nLin++

// calcula media de permanencia geral Pacientes dia divido pelo n๚mero de saํdas
@ nLin,00  Psay STR0025
nCol:=21
nTotTmp:=0
For nCtaMes:= 1 to nMesRetr
	
	nTot := aMatGer[3][nCtaMes+1] / aMatGer[10][nCtaMes+1]
	@ nLin,nCol  Psay TRANSFORM(nTot, aIndicad[nTotFor, 2])
	nCol := nCol + 10
	nTotTmp += nTot
Next
@ nLin,nCol  Psay TRANSFORM(nTotTmp /nMesRetr, aIndicad[nTotFor, 2])
nLin +=1

// calcula taxa de ocupacao hospitalar geral Pacientes dia dividido por leitos dia, Multiplicado por 100;
@ nLin,00  Psay STR0026
nCol:=21
nTotTmp:=0










For nCtaMes:= 1 to nMesRetr
	nTot := (aMatGer[3][nCtaMes+1]/ aMatGer[9][nCtaMes+1] * 100)// paciente dia/leitos dias *100
	@ nLin,nCol  Psay TRANSFORM(nTot, aIndicad[nTotFor, 2])
	nCol := nCol + 10
	nTotTmp += nTot
Next
@ nLin,nCol  Psay TRANSFORM(nTotTmp / nMesRetr, aIndicad[nTotFor, 2])
nLin ++

// calcula indice de rotatividade geral   //n de saida / n leitos
@ nLin,00  Psay STR0027
nCol:=21
nTotTmp:=0
For nCtaMes:= 1 to nMesRetr
	nTot := aMatGer[10][nCtaMes+1] / aMatGer[4][nCtaMes+1]
	@ nLin,nCol  Psay TRANSFORM(nTot, aIndicad[nTotFor, 2])
	nCol := nCol + 10
	nTotTmp += nTot
Next
@ nLin,nCol  Psay TRANSFORM(nTotTmp/nMesRetr, aIndicad[nTotFor, 2])
nLin += 2














nLin++
@nLin, 000 PSAY __PRTTHINLINE()

Set Printer to
Set Device  to Screen

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDR58 บ       ณ MARCELO JOSE       บ Data ณ 18/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDACAO DA PERGUNTA MES/ANO                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_VldR58()
Local lRet := .T.




If ReadVar() == "MV_PAR03"
	If !(lRet := Substr(MV_PAR03, 1, 2) $ "01/02/03/04/05/06/07/08/09/10/11/12")
		HS_MsgInf(STR0029 , STR0030 , STR0031) //"Mes/Ano referencia invalido"###"Aten็ใo"###"Mes/Ano Refer๊ncia"
	ElseIf !(lRet := Substr(MV_PAR03, 4, 4) + Substr(MV_PAR03, 1, 2) <= Substr(DTOS(DDATABASE), 1, 6) )
		HS_MsgInf(STR0032, STR0030, STR0031) //"Mes/Ano referencia nใo pode ser maior que o m๊s da database."###"Aten็ใo"###"Mes/Ano Refer๊ncia"
	Endif
	
ElseIf ReadVar() == "MV_PAR04"
	If !(lRet := MV_PAR04 <= 12)
		HS_MsgInf(STR0035, STR0030, STR0036) //"N๚mero de meses retroativos invแlido."###"Aten็ใo"###"Meses Retroativos"
	EndIf
	
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOVLEI บ       ณ JOSE ORFEU         บ Data ณ 18/09/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CALCULA OS PAR.RELATORIO: ENTRADA E SAIDA POR TRNSF.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_MovLei(cRegAte, cCodLoc, cData, cAltaTra)
LOCAL aArea	    := GetArea()
Local aRet      := {.F., .F.}
Local cAnoMes   := Substr(DTOS(CTOD("01/" + Substr(cData, 1, 2) + "/" + Substr(cData, 4, 4))) ,1, 6)
Local cSql :=""
cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))

cSql := "SELECT DISTINCT GB1_CODLOC, GB1_DATAE, GB1_HORAE, GCY_TPALTA " + ;
"FROM " + RetSqlName("GB1") + " GB1 " + ;
"JOIN " + RetSqlName("GAV") + " GAV ON GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_CODLOC = GB1_CODLOC AND GAV_QUARTO = GB1_QUARTO AND GAV_LEITO = GB1_LEITO AND NOT GAV_TIPO IN ('2', '7') AND GAV_ESTATI = '1' " + ;
"JOIN " + RetSqlName("GCY") + " GCY ON GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = '" + cRegAte + "' " + ;
"WHERE GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1_REGATE = '" + cRegAte + "' " + ;
"           AND GB1.GB1_DATAE <= '" + cLimDataE + "' " + ;
"           AND (GB1.GB1_DATAS >= '" + cAnoMes + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') " +;
"ORDER BY GB1_DATAE, GB1_HORAE"



cSql := ChangeQuery(cSql)














dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "GB1MOV", .T., .T.)

// Saidas
aRet[2] := !Eof() .And. GB1MOV->GB1_CODLOC == cCodLoc .And. !(GB1MOV->GCY_TPALTA $ cAltaTra)

If aRet[2]
	DbSkip()
	
	aRet[2] := !Eof()
EndIf

// Entradas
GB1MOV->(DbGotop())
aRet[1] := !Eof() .And. GB1MOV->GB1_CODLOC <> cCodLoc

dbCloseArea()
RestArea(aArea) 
Return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR58  บAutor  ณMicrosiga           บ Data ณ  02/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que calcula o indice ==>> PACIENTES DIAS             บฑฑ
ฑฑบ          ณPor Setor e Por Mes                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FS_PacDia(cData, cSet, cAnoMes, cCodCon)
Local nRet		:= 0
Local cSql		:= ""
Local cDatIni	:= cAnoMes + "01"


cSQL := "SELECT GCS.GCS_NOMLOC, GB1.GB1_CODLOC, GCY.GCY_REGATE, GB1.GB1_QUARTO, " //GCW.GCW_DESCLI, GCW.GCW_CODCLI,
cSQL += "GB1.GB1_LEITO, GB1.GB1_DATAE, GB1.GB1_DATAS, GB1.GB1_HORAS "
cSQL += " FROM " + RetSQLName("GCY") + " GCY "

If "DB2" $ Upper(TCGETDB())
	cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON  GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
Else
	cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
endif

cSQL += " JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_REGATE = GCY.GCY_REGATE AND GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*'  "
cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))

cSQL += "                                      AND GB1.GB1_DATAE BETWEEN '" + cDatIni + "' AND '" + cLimDataE + "' "
cSQL += "                                      AND (GB1.GB1_DATAS >= '" + cAnoMes + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
cSQL += " AND GB1.GB1_CODLOC = '" + cSet + "' "
cSQL += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO "
cSQL += " 																																							AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "
cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "


cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
cSQL += "AND GCY.GCY_TPALTA <> '99' "
cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSQL += "                      AND GCZ_REGATE = GCY.GCY_REGATE) "
cSQL += "ORDER BY  GB1.GB1_CODLOC"

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")

DbGoTop()







aVetDados:={}





While !Eof()
	AADD(aVetDados, { QRY->GB1_CODLOC, ;
	SUBSTR(QRY->GCS_NOMLOC, 1, 30), ;
	QRY->GCY_REGATE, ;
	QRY->GB1_QUARTO, ;
	QRY->GB1_LEITO, ;
	QRY->GB1_DATAE, ;
	QRY->GB1_DATAS,;
	QRY->GB1_HORAS})
	DbSkip()
EndDo

















If Len(aVetDados) > 0
	nRet:= FS_MontaM(cAnoMes)
EndIf

dbCloseArea()
Return(nRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MontaM บ Autor ณ                    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_MontaM(cAnoMes)
Local cCodQuebra := ""
Local nCont      := 0, nDias := 0

Local dDataS     := CTOD(""), dDataE := CTOD("")
Local nQtPa      :=0
Local nConsDataS :=2
Private nPermLei   := GETMV("MV_PERMLEI")

For nCont := 1 To Len(aVetDados)
	If cCodQuebra <> aVetDados[nCont, 1]
		If !Empty(cCodQuebra)
			aAdd(aVetGRaf, {aVetDias[Len(aVetDias), 34], ALLTRIM(aVetDias[Len(aVetDias), 32]) + "-" + aVetDias[Len(aVetDias), 33]})
		EndIf
		cCodQuebra := aVetDados[nCont, 1]
		AADD(aVetDias, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, aVetDados[nCont, 1], aVetDados[nCont, 2], 0})
	EndIf
	
	dDataE := IIF(STOD(aVetDados[nCont, 6]) < STOD(cAnoMes + "01"), STOD(cAnoMes + "01"), STOD(aVetDados[nCont, 6]))
	
	If !EMPTY(aVetDados[nCont, 7])
		dDataS := IIF(aVetDados[nCont, 7] > cLimDataE, STOD(cLimDataE), STOD(aVetDados[nCont, 7]))
	Else
		If cAnoMes < SUBSTR(DTOS(dDataBase), 1, 6)
			dDataS := LastDay(STOD(cAnoMes+"01"))
		Else
			dDataS := dDataBase
		EndIf
	EndIf
	
	If dDataE == dDataS //Se entrou e saiu mesmo dia sempre contar 1, independente do perํodo dura็ใo
		FS_SomaDia(dDataE)
	Else
		dDataAtu := dDataE
		For nDias := 1 To (dDataS - dDataE)
			FS_SomaDia(dDataAtu)
			dDataAtu ++
		Next
		If Empty(aVetDados[nCont, 8]) .Or. (nConsDataS == 2 .And. SubHoras(aVetDados[nCont, 8], 0) >= nPermLei) //Considera Dt Saida
			FS_SomaDia(dDataS)
		EndIf
	EndIf
	
Next

nQtPa  :=aVetDias[Len(aVetDias), 34] ++
Return(nQtPa)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_SomaDiaบ Autor ณ                    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_SomaDia(dData)

aVetDias[Len(aVetDias), DAY(dData)] ++
aVetDias[Len(aVetDias), 34] ++

Return(dData)
 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpItenบ Autor ณ                    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_ImpIten(nCtaFor, nCtaInd, nLin, lImp)
Local nPosInd := 0
Local nCtaMes := 0
Local nTotSet := 0
Local nCol    := 22
Local nPos    := 0

nPosInd := nCtaInd + 04

If lImp
	nLin++
	@ nLin,00  Psay aVetMesSTR[nCtaInd] //imprime numero leito
EndIf

If nCtaInd <= 10
	nPos:= aScan(aMatQbr1, {| aVet | aVet[1] == cQbr1	.And. aVet[17] == cQbr2 .And. aVet[2] == nCtaInd })
EndIf

For nCtaMes := 1 to nMesRetr
	If lImp
		@ nLin, nCol  Psay Str(aMatImp[nCtaFor, nPosInd][nCtaMes],7, IIF(nCtaInd <= 10, 0, 2))
		nCol    := nCol + 10
	EndIf
	// matriz de totais por convenio
	If nCtaInd <= 10
		If nPos == 0
			AAdd(aMatQbr1,{cQbr1, nCtaInd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, aVetMesSTR[nCtaInd], cQbr2})
			nPos := Len(aMatQbr1)
		EndIf
		
		If nAgruPor <> 2
			aMatQbr1[nPos][nCtaMes+2] := aMatImp[nCtaFor, nPosInd][nCtaMes]
		Else
			aMatQbr1[nPos][nCtaMes+2] += IIF(aMatQbr1[nPos][2] == 4 .And. nCtaFor > 1 .And. aMatImp[nCtaFor, 1] == aMatImp[nCtaFor - 1, 1], 0, aMatImp[nCtaFor, nPosInd][nCtaMes])
		EndIf
		nTotSet += aMatQbr1[nPos][nCtaMes+2]
	Else
		nTotSet += aMatImp[nCtaFor, nPosInd][nCtaMes]
	EndIf
	
Next

If lImp
	@ nLin,nCol Psay Str(IIf(nPosInd == 8, nTotSet/nMesRetr, nTotSet), 8, IIF(nCtaInd <= 10, 0, 2))
EndIf























If nCtaInd <= 10
	If nAgruPor <> 2
		aMatQbr1[npos][15] := IIf(nPosInd == 8, nTotSet/nMesRetr, nTotSet)
	Else
		aMatQbr1[npos][15] += IIf(nPosInd == 8, IIF(aMatQbr1[nPos][2] == 4 .And. nCtaFor > 1 .And. aMatImp[nCtaFor, 1] == aMatImp[nCtaFor - 1, 1], 0, nTotSet/nMesRetr), nTotSet)
	EndIf
EndIf







If lImp .And. nLin + 20 > nMaxLin
	nLin := FS_ImpCabe(nLin)
EndIf

Return(nLin)
 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpCabeบ Autor ณ                    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Imprime Cabecalho                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_ImpCabe(nLin)
 
Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
nLin := 8

Return(nLin)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณHS_TelaR58บ Autor ณ HEIMDALL CASTRO    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar que monta a tela a ser mostrada para o     บฑฑ
ฑฑบ          ณ usuแrio com os dados que sใo apresentados no relat๓rio.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HS_TelaR58()

Private lLoop := .T.
Private lPerg := .T.

While lLoop

	HS_TR58Ori()

EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณHS_TelaR58บ Autor ณ HEIMDALL CASTRO    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar que monta a tela a ser mostrada para o     บฑฑ
ฑฑบ          ณ usuแrio com os dados que sใo apresentados no relat๓rio.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HS_TR58Ori()

Local nOpcA    := 0
Local nGDOpc 	 := 0
Local nCtaFor  := 0, nCtaInd := 0
Local aCDAD    := {}, aHDAD   := {}


Private oDlg, oDat, oRetr, oSetor, oConv, oFolGDs, oDAD
Private cDat      := "", cSetor := "", cRet := "", cConv := ""
Private aSize   	 := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}
Private aButtons  := {}
Private aTela     := {}
Private aGets     := {}
Private cPerg     := "HSPR58"
Private nLastKey  := 0
Private cDoCodLoc  := ""
Private cAteCodLoc := ""
Private cDoCodCon  := ""
Private cAteCodCon := ""
Private cMesRef			 := ""
Private nMesRetr   := 0
Private nSaltPag   := 0
Private nAgruPor   := 0
Private aIndicad  := {{STR0037, "999999"},	{STR0038, "999999"}, {STR0039, "999999"}, {STR0040, "999999"},; //"Admisso๕es"###"Altas"###"Pacientes dia"###"Nro Leitos"
{STR0041, "999999"},	 {STR0042, "999999"}, {STR0043, "999999"},; //"Entrada Transf.Unid"###"Saida Transf. Unid."###"Alta por Obito"
{STR0044, "999999"}, {STR0045, "999999"}, {STR0046, "999999"},; //"Transf.p/ Hospitais"###"Leitos Dia"###"Numero de saidas"
{STR0047, "@E 9999.99"}, {STR0048, "@E 9999.99"}, {STR0049, "@E 9999.99"},; //"Tx. Mortalid. geral"###"Media  Permanencia"###"Tx. Ocup.Hospitalar"
{STR0050, "@E 9999.99"}}      //"Indice Rotatividade"

lLoop := .F.

If !HS_ExisDic({{"C", "GAV_DTCRIA"}},.T.)
	Return(.F.)
EndIf

If !FS_MntDadT(oDAD, @aHDAD, @aCDAD,.F.)
	Return(Nil)
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 080, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

//Adciona botใo na enchoicebar
Aadd(aButtons	, {"S4WB011N", {||FS_MntDadT(oDAD, @aHDAD, @aCDAD, .T.),IIf(lLoop,(nOpcA := 0, oDlg:End()),.F.)}, STR0051})  //"Perguntas"
Aadd(aButtons	, {"S4WB007N", {||HSPAHR58()}, STR0052})   //"Relat๓rio"

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Procedimentos SUS"

@ 020, 015 Say STR0053      Of oDlg    Pixel COLOR CLR_BLUE //"Data:"
@ 018, 040 MsGet oDat       VAR cDat   SIZE 050, 009 Picture "@!" WHEN .F. OF oDlg Pixel COLOR CLR_BLACK
@ 020, 250 Say STR0054 Of oDlg    Pixel COLOR CLR_BLUE //"Retroativ:"
@ 018, 275 MsGet oRetr      VAR cRet   SIZE 030, 009 Picture "@!" WHEN .F. OF oDlg Pixel COLOR CLR_BLACK
@ 020, 310 Say STR0055      Of oDlg    Pixel COLOR CLR_BLUE //"Meses"
@ 040, 015 Say STR0056     Of oDlg    Pixel COLOR CLR_BLUE //"Setor:"
@ 038, 040 MsGet oSetor     VAR cSetor SIZE 200, 009 Picture "@!" WHEN .F. OF oDlg Pixel COLOR CLR_BLACK
@ 040, 250 Say STR0057  Of oDlg    Pixel COLOR CLR_BLUE //"Conv๊nio:"
@ 038, 275 MsGet oConv      VAR cConv  SIZE 200, 009 Picture "@!" WHEN .F. OF oDlg Pixel COLOR CLR_BLACK

oDAD := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0,,,,,, 99999,,,, oDlg, aHDAD, aCDAD)
oDAD:oBrowse:Align := CONTROL_ALIGN_BOTTOM
oDAD:oBrowse:BlDblClick := {||.F.}

oDlg:bStart := { || oDAD:Refresh()}




ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()},, aButtons)




Return(Nil)                                        


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MNTDADTบ Autor ณ HEIMDALL CASTRO    บ Data ณ  23/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar que monta a impressao dos dados do         บฑฑ
ฑฑบ          ณ relat๓rio.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function FS_MntDadT(oDAD, aHDAD, aCDAD, lBut)
               
Local nCtaFor  := 0, nTotQbr := 0, nTotFor := 0
Local nCtaInd  := 0, nCtaMes := 0, nTot := 0
Local cCodLoc  := "", cCodCon := ""
Local cTitulo  := STR0003 //"ESTATISTICA DE INTERNACAO"
Local nPos     := 0, nTotInd := 0
Local nValTmp  := 0
Local nTotTmp  := 0

Private cCodQbr1  := "",;
        cDesQbr1  := "",;
        cCodQbr2  := "",;
        cDesQbr2  := "",;
        cQbr1     := "",;
        cQbr2     := "",;
        cCabec1   := STR0006,; //"Parametros           "
        cCabec2   := "",;
        aMatImp   := {},;
        aMatTemp  := {},;
        aMatConv  := {}, aMesAno      := {},;
        aMatQbr1  := {}
        aVetMesSTR   := {STR0014, STR0015, STR0016, ; //Adminssoes###Altas###"Pacientes dia:"
                         STR0017, STR0018, STR0019,;//"Nro Leitos Utiliz. :"###"Entrada Transf.Unid:"###"Saida Transf. Unid.:" 
                         STR0020, STR0021, STR0022,;//"Alta por Obito ....:"###"Transf.p/ Hospitais:"###"Leitos Dia ........:" 
                         STR0023, STR0024, STR0025,;//"Numero de saidas ..:"###"Tx. Mortalid. geral:"###"Media  Permanencia :"  
                         STR0026, STR0027, }//"Tx. Ocup.Hospitalar:"###"Indice Rotatividade:"
 
Private aMatGer  := {}
Private nSetores := 0



AAdd(aMatGer,{01,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0014}) //admissoes
AAdd(aMatGer,{02,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0015}) //altas
AAdd(aMatGer,{03,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0016}) //pacientes dia
AAdd(aMatGer,{04,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0017}) //nro leitos
AAdd(aMatGer,{05,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0018}) //entrada transf unid
AAdd(aMatGer,{06,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0019}) //saida transf unid
AAdd(aMatGer,{07,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0020}) //alta por obito
AAdd(aMatGer,{08,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0021}) //transf para hospitais
AAdd(aMatGer,{09,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0022}) //leitos dia
AAdd(aMatGer,{10,0,0,0,0,0,0,0,0,0,0,0,0,0,STR0023}) //numero de saidas

For nCtaMes := 1 to nMesRetr
	For nTotFor := 1 to 10
		nTot := 0
		For nTotQbr := 1 to Len(aMatQbr1)/10
			nTot += aMatQbr1[(nTotQbr - 1) * 10 + nTotFor][nCtaMes+2]
		Next
		aMatGer[nTotFor][nCtaMes + 1] += nTot
		aMatGer[nTotFor][14] += nTot
	Next
Next

If lBut

	If Pergunte(cPerg,.T.)
		lLoop := .T.
		lPerg := .F.
	EndIf

	Return(.F.)
	
EndIf			

If !Pergunte(cPerg,lPerg)
	If lPerg
		Return(.F.)
	EndIf
EndIf

lPerg := .T.

cDoCodLoc  := MV_PAR01
cAteCodLoc := MV_PAR02
cMesRef				:= MV_PAR03
nMesRetr   := MV_PAR04
nSaltPag   := MV_PAR05
nAgruPor   := MV_PAR06

nMaxLin := HS_MaxLin(MV_PAR07)

If nLastKey == 27
	Return(.F.)
Endif

cDat   := cMesRef
cSetor := STR0059 + cDoCodLoc + "] " + ALLTRIM(HS_IniPadR("GCS", 1, cDoCodLoc, "GCS_NOMLOC",, .F.)) + STR0060 + cAteCodLoc + "] " + ALLTRIM(HS_IniPadR("GCS", 1, cAteCodLoc, "GCS_NOMLOC",, .F.)) //"Do ["###" at้ ["
cRet   := ALLTRIM(STR(nMesRetr))


aMatImp := {}

Processa({|| RunRepRel()             }, cTitulo)
Processa({|| FS_CALCM()              }, cTitulo)

aHDAD := {}
Aadd(aHDAD, {STR0063 , "cCodLoc", "@!", 003, 0,,, "C",, "V",,,,"V"})  //"C๓d. Setor"
Aadd(aHDAD, {STR0064 , "cDesLoc", "@!", 030, 0,,, "C",, "V",,,,"V"}) //"Des. Setor"
Aadd(aHDAD, {STR0065  , "cNomInd", "@!", 020, 0,,, "C",, "V",,,,"V"}) //"Indicador "

For nCtaFor := 1 To nMesRetr
	Aadd(aHDAD, {aMesAno[1][nCtaFor], aMesAno[1][nCtaFor],   "", 003, 0,,, "N",, "V",,,,"V"})
Next
Aadd(aHDAD, {STR0066       , "cTotGer", "", 003, 0,,, "N",, "V",,,,"V"}) //"Total"

aCDAD := {}

If nAgruPor == 1
	For nCtaFor := 1 To Len(aMatImp)
		For nCtaInd := 1 To 14
			If nAgruPor == 1 //Setor
				cCodQbr1 := IIF(aMatImp[nCtaFor, 1] == cCodLoc, "", aMatImp[nCtaFor, 1])
				cDesQbr1 := IIF(aMatImp[nCtaFor, 1] == cCodLoc, "", aMatImp[nCtaFor, 2])
			EndIf
			AAdd(aCDAD, {cCodQbr1, cDesQbr1, 	aIndicad[nCtaInd, 1]})
			aSize(aCDAD[Len(aCDAD)], nMesRetr + 5)
			
			nTotInd := 0
			For nCtaMes := 1 To nMesRetr
				if  nCtaInd =4 //leitos
					aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(aMatImp[nCtaFor, nCtaInd+4, nCtaMes], aIndicad[nCtaInd, 2])
					nTotInd :=aMatImp[nCtaFor, 08][nCtaMes]
				else
					aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(aMatImp[nCtaFor, nCtaInd+4, nCtaMes], aIndicad[nCtaInd, 2])
					nTotInd += aMatImp[nCtaFor, nCtaInd+4, nCtaMes]
				endif




				
			Next
			aCDAD[Len(aCDAD), Len(aCDAD[1]) - 1] := TRANSFORM(nTotInd, aIndicad[nCtaInd, 2])
			aCDAD[Len(aCDAD), Len(aCDAD[1])]     := .F.
			
			
			
			cCodLoc := aMatImp[nCtaFor, 1]
			
		Next nCtaInd
		cCodLoc := ""
		
	Next nCtaFor
	
EndIf

//Geral

  
For nCtaFor = 1 to Len(aMatImp)
	For nCtaInd := 1 To 14
		FS_ImpIten(nCtaFor, nCtaInd, 0, .F.)
	Next
Next


AAdd(aCDAD, {"", "Total Geral"})
aSize(aCDAD[Len(aCDAD)], nMesRetr + 5)
aCDAD[Len(aCDAD), Len(aCDAD[1])]     := .F.


For nCtaInd := 1 To 14
	AAdd(aCDAD, {"", "", aIndicad[nCtaInd, 1]})
	aSize(aCDAD[Len(aCDAD)], nMesRetr + 5)
	nTotTmp := 0
	For nCtaMes := 1 to nMesRetr
		If nCtaInd <= 10
			
			If nCtaInd =4
				//Calculo dos Leitos
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(aMatGer[nCtaInd][nCtaMes + 1], aIndicad[nCtaInd, 2])
				nTotTmp += aMatGer[nCtaInd][nCtaMes + 1]/nMesRetr
			else
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(aMatGer[nCtaInd][nCtaMes + 1], aIndicad[nCtaInd, 2])
				nTotTmp += aMatGer[nCtaInd][nCtaMes + 1]
			endif
			
		Else
			If nCtaInd == 11
				// calcula Taxa de Mortalidade geral
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 7 })
				nValTmp := aMatGer[npos][nCtaMes+1]
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 10 })
				
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(nValTmp / aMatGer[npos][nCtaMes+1] * 100, aIndicad[nCtaInd, 2])
				nTotTmp += nValTmp / aMatGer[npos][nCtaMes+1] * 100 / nMesRetr
				
			ElseIf nCtaInd == 12
				// calcula media de permanencia geral Pacientes m๊s divido pelo n๚mero de saํdas;
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 3 })
				nValTmp := aMatGer[npos][nCtaMes+1]
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 10 })
				
				
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(nValTmp / aMatGer[npos][nCtaMes+1] , aIndicad[nCtaInd, 2])
				nTotTmp += nValTmp / aMatGer[npos][nCtaMes+1]  / nMesRetr
				
			ElseIf nCtaInd == 13
				// calcula taxa de ocupacao hospitalar geral
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 3 })
				nValTmp := aMatGer[npos][nCtaMes+1]
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 9 })
				
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(nValTmp / aMatGer[npos][nCtaMes+1] * 100, aIndicad[nCtaInd, 2])
				nTotTmp += nValTmp / aMatGer[npos][nCtaMes+1] / nMesRetr * 100
				
			ElseIf nCtaInd == 14
				// calcula indice de rotatividade geral   n๚mero de saํdas dividido por leitos
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 10 })
				nValTmp := aMatGer[npos][nCtaMes+1]
				nPos := aScan(aMatGer, {| aVet | aVet[1] == 4 })   //
				
				aCDAD[Len(aCDAD), nCtaMes + 3] := TRANSFORM(nValTmp / aMatGer[npos][nCtaMes+1] , aIndicad[nCtaInd, 2])
				nTotTmp += nValTmp / aMatGer[npos][nCtaMes+1] / nMesRetr
				
			EndIf
		EndIf
	Next
	
	aCDAD[Len(aCDAD), Len(aCDAD[1]) - 1] := TRANSFORM(nTotTmp, aIndicad[nCtaInd, 2])
	aCDAD[Len(aCDAD), Len(aCDAD[1])]     := .F.
	
Next


   
Return(.T.) 


