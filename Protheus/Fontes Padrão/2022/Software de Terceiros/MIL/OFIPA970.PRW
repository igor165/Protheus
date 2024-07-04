// ษออออออออหออออออออป
// บ Versao บ 05     บ
// ศออออออออสออออออออผ
#include "PROTHEUS.CH"
#include "Ofipa970.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIPA970 ณ Autor ณ  Fabio                ณ Data ณ 25/06/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Aplicacao de Itens                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico  (Modelo3)                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIPA970()

Private nOPCG
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //"Aplicacao de Itens"
Private nUsado := 0
Private cMarVeiF3 // Utilizado na consulta padrao MCF

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de  Oficina e Auto Pe็as        //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIPA970" })
    Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse(06,01,22,75,"VE3")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPC970I    บAutor  ณFabio               บ Data ณ  10/09/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PC970I(cAlias,nReg,nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local a := 0
Local b := 0
Local c := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Private aFamilia := {{.f.,""}}
Private aClasse := {{.f.,""}}
Private aSubCla := {{.f.,""}}
Private aModelos := {{.f.,"","","","","","","",""}}
Private aTELA[0][0],aGETS[0]
Private aCols := {} , aHeader := {} , aCpoEnchoice := {}
Private cTudoOk    := ""
Private nLenAcols := 0
Private cGrupo := Space(TAMSX3("B1_GRUPO")[1])
Private cCodIte := Space(TAMSX3("B1_CODITE")[1])
Private cGrupoA := Space(TAMSX3("B1_GRUPO")[1])
Private nPosicao    := 1
Private cCodIteA := Space(TAMSX3("B1_CODITE")[1])
Private nLinhas := 99
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private cAliasVE3  := "SQLVE3"
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
cLinOkP    := "FG_OBRIGAT() .AND. OPA970VLIN()"
cFieldOkP  := "FG_MEMVAR()"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Opcoes de acesso para a Modelo 3                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=2
		nOpcG:=3
	Case nOpc == 4 && Alterar
		nOpcE:=2
		nOpcG:=4
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
	Otherwise
		nOpcE:=2  && Excluir
		nOpcG:=5
EndCase

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VV2",.T.)
DbSelectArea("VV2")

For nCntFor = 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VV1")
aHeader:={}
While !Eof().And.(x3_arquivo=="VV1")

	If X3USO(x3_usado).And.cNivel>=x3_nivel.And. (Alltrim(x3_Campo) $ [VV1_CODMAR/VV1_MODVEI/VV1_DESMOD])

		nUsado:=nUsado+1

		if x3_campo == "VV1_MODVEI"
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				15, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		Elseif x3_campo == "VV1_DESMOD"
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				20, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		Else
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		Endif
		if x3_campo <> "VV1_DESMOD"
	      	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
		Else
	      	&( "M->" + Alltrim(x3_campo) ) := ""
		Endif
	Endif

	dbSkip()

End
nUsado:=nUsado+1
Aadd(aHeader,{ STR0007, "VE3_ANOINI", "@R 9999",;
4, 0,".t.",;
"ววววววววววววววว", "C", "VE3", "V", "", "วว" } )

nUsado:=nUsado+1
Aadd(aHeader,{ STR0008, "VE3_ANOFIN", "@R 9999",;
4, 0,"FS_ATUALIZA()",;
"ววววววววววววววว", "C", "VE3", "V", "", "วว" } )


aCols := { Array(nUsado + 1) }
aCols[1,nUsado+1] := .F.
For nCntFor:=1 to nUsado
	aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
Next

aObjects := {}
AAdd( aObjects, { 05, 50 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 05, 130, .T. , .F. } )  //list box superior
AAdd( aObjects, { 05, 150, .T. , .T. } )  //getdados

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

nTam := ( aPosObj[1,4] / 2) //varaivel que armazena o resutlado da divisao da tela.

if nOpc == 4 .or. nOpc == 5 .or. nOpc == 2
   cGrupo   := VE3->VE3_GRUITE
   cCodIte  := VE3->VE3_CODITE
   cGrupoA  := VE3->VE3_GRUITE
   cCodIteA := VE3->VE3_CODITE

	cQuery := "SELECT VE3.VE3_FAMILI,VE3.VE3_CLASSE,VE3.VE3_SUBCLA "
	cQuery += "FROM "
	cQuery += RetSqlName( "VE3" ) + " VE3 "
	cQuery += "WHERE "
	cQuery += "VE3.VE3_FILIAL='"+ xFilial("VE3")+ "' AND VE3.VE3_GRUITE = '"+cGrupo+"' AND VE3.VE3_CODITE = '"+cCodIte+"' AND "//VE3.VE3_FAMILI = '"+cFamil+"' AND VE3.VE3_CLASSE = '"+cClass+"' AND VE3.VE3_SUBCLA = '"+cSubC+"' AND "
	cQuery += "VE3.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE3, .T., .T. )

    nPosicao := 1

	Do While !( cAliasVE3 )->( Eof() )

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"V7")
		While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V7"

		    if Len(aFamilia) == 1 .and. Empty(aFamilia[1,2])
		        aFamilia := {}
			Endif

			nP := Ascan(aFamilia, {|x| x[2]+x[3] == Alltrim(SX5->X5_DESCRI)+SX5->X5_CHAVE})
			if nP == 0
				if Alltrim(( cAliasVE3 )->VE3_FAMILI) == Alltrim(SX5->X5_CHAVE)
					aAdd(aFamilia,{.t.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
	       		Else
					aAdd(aFamilia,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
				Endif
    		Else
				if !aFamilia[nP,1]
					if Alltrim(( cAliasVE3 )->VE3_FAMILI) == Alltrim(SX5->X5_CHAVE)
						aFamilia[nP,1] := .t.
	    	   		Else
						aFamilia[nP,1] := .f.
					Endif
				Endif
    		Endif
	       dbSelectArea("SX5")
		   dbSkip()

		Enddo

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"V8")
		While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V8"

	    	if Len(aClasse) == 1 .and. Empty(aClasse[1,2])
	    	    aClasse := {}
			Endif
			nP := Ascan(aClasse, {|x| x[2]+x[3] == Alltrim(SX5->X5_DESCRI)+SX5->X5_CHAVE})
			if nP == 0
				if Alltrim(( cAliasVE3 )->VE3_CLASSE) == Alltrim(SX5->X5_CHAVE)
					aAdd(aClasse,{.t.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
	    		Else
					aAdd(aClasse,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
			    Endif
           Else
                if !aClasse[nP,1]
					if Alltrim(( cAliasVE3 )->VE3_CLASSE) == Alltrim(SX5->X5_CHAVE)
						aClasse[nP,1] := .t.
	    			Else
						aClasse[nP,1] := .f.
			    	Endif
			    Endif
           Endif
		   dbSelectArea("SX5")
		   dbSkip()

		Enddo

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"V9")
		While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V9"

		    if Len(aSubCla) == 1 .and. Empty(aSubCla[1,2])
	        	aSubCla := {}
			Endif

			nP := Ascan(aSubCla, {|x| x[2]+x[3] == Alltrim(SX5->X5_DESCRI)+SX5->X5_CHAVE})
			if nP == 0
				if Alltrim(( cAliasVE3 )->VE3_SUBCLA) == Alltrim(SX5->X5_CHAVE)
					aAdd(aSubCla,{.t.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
	    		Else
					aAdd(aSubCla,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})
	    		Endif
	       Else
	            if !aSubCla[nP,1]
					if Alltrim(( cAliasVE3 )->VE3_SUBCLA) == Alltrim(SX5->X5_CHAVE)
						aSubCla[nP,1] := .t.
	    			Else
						aSubCla[nP,1] := .f.
	    			Endif
	    		Endif
	       Endif
		   dbSelectArea("SX5")
		   dbSkip()

		Enddo

	   dbSelectArea(cAliasVE3)
	   ( cAliasVE3 )->(dbSkip())

	Enddo
	( cAliasVE3 )->( dbCloseArea() )
	if nOpc == 2 .or. nOpc == 4 .or. nOpc == 5
	    For a := 1 to Len(aFamilia)
		   if aFamilia[a,1]
			  cFamil := aFamilia[a,3]
			  Exit
		   Endif
   		Next
		nClasse := 0
		For b := 1 to Len(aClasse)
		   if aClasse[b,1]
			  cClass := aClasse[b,3]
			  Exit
		   Endif
		Next
		nSubcla := 0
		For c := 1 to Len(aSubCla)
		   if aSubCla[c,1]
			  cSubC := aSubCla[c,3]
			  Exit
		   Endif
		Next
		cQuery := "SELECT VE3.VE3_CODMAR,VE3.VE3_MODVEI,VE3.VE3_ANOINI,VE3.VE3_ANOFIN,VE3.VE3_CLASSE,VE3.VE3_FAMILI,VE3.VE3_SUBCLA "
		cQuery += "FROM "
		cQuery += RetSqlName( "VE3" ) + " VE3 "
		cQuery += "WHERE "
		cQuery += "VE3.VE3_FILIAL='"+ xFilial("VE3")+ "' AND VE3.VE3_GRUITE = '"+cGrupo+"' AND VE3.VE3_CODITE = '"+cCodIte+"' AND "//VE3.VE3_FAMILI = '"+cFamil+"' AND VE3.VE3_CLASSE = '"+cClass+"' AND VE3.VE3_SUBCLA = '"+cSubC+"' AND "
		cQuery += "VE3.D_E_L_E_T_=' '"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVE3, .T., .T. )

	    nPosicao := 1

		Do While !( cAliasVE3 )->( Eof() )

            if Len(aCols) == 1 .and. Empty(aCols[1,1])
               aCols := {}
            Endif
            if Len(aModelos) == 1 .and. Empty(aModelos[1,2])
               aModelos := {}
            Endif
            dbSelectArea("VV2")
            dbSetOrder(1)
            dbSeek(xFilial("VV2")+( cAliasVE3 )->VE3_CODMAR+( cAliasVE3 )->VE3_MODVEI)

   			nPos := Ascan(aCols, {|x| x[1]+x[2]+x[4]+x[5] == ( cAliasVE3 )->VE3_CODMAR+( cAliasVE3 )->VE3_MODVEI+( cAliasVE3 )->VE3_ANOINI+( cAliasVE3 )->VE3_ANOFIN})
	  		if nPos == 0
		  		aAdd(aCols,{( cAliasVE3 )->VE3_CODMAR,( cAliasVE3 )->VE3_MODVEI,VV2->VV2_DESMOD,( cAliasVE3 )->VE3_ANOINI,( cAliasVE3 )->VE3_ANOFIN,.f.})
            Endif
     		aAdd(aModelos,{.t.,VE3->VE3_GRUITE,VE3->VE3_CODITE,"","","","","",""})
			nFam := 0
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"V7"+( cAliasVE3 )->VE3_FAMILI)
//			For a := 1 to Len(aFamilia)
//			   if aFamilia[a,1]
				  aModelos[nPosicao,4] := Alltrim(SX5->X5_DESCRI)
//				  aModelos[nPosicao,4] := aFamilia[a,2]
//				  nFam := 1
//				  Exit
//			   Endif
//			Next
			nClasse := 0
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"V8"+( cAliasVE3 )->VE3_CLASSE)
//			For b := 1 to Len(aClasse)
//			   if aClasse[b,1]
//				  aModelos[nPosicao,7] := aClasse[b,2]
				  aModelos[nPosicao,7] := Alltrim(SX5->X5_DESCRI)
//		    	  nClasse := 1
//				  Exit
//			   Endif
//			Next
			nSubcla := 0
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"V9"+( cAliasVE3 )->VE3_SUBCLA)
//			For c := 1 to Len(aSubCla)
//			   if aSubCla[c,1]
//			      nSubcla := 1
				  aModelos[nPosicao,8] := Alltrim(SX5->X5_DESCRI)
//				  aModelos[nPosicao,8] := aSubCla[c,2]
//				  Exit
//			   Endif
//			Next

			aModelos[nPosicao,5] := ( cAliasVE3 )->VE3_CODMAR
			aModelos[nPosicao,6] := ( cAliasVE3 )->VE3_MODVEI
			aModelos[nPosicao,9] := ( cAliasVE3 )->VE3_ANOINI+"/"+( cAliasVE3 )->VE3_ANOFIN
			nPosicao += 1

    	   dbSelectArea(cAliasVE3)
	       ( cAliasVE3 )->(dbSkip())
	   Enddo
	   ( cAliasVE3 )->( dbCloseArea() )
   Else
	   acols[1,1] := VE3->VE3_CODMAR
	   M->VE3_CODMAR := VE3->VE3_CODMAR
	   acols[1,2] := VE3->VE3_MODVEI
	   M->VE3_MOVEI := VE3->VE3_MODVEI
	   M->VE3_ANOINI := VE3->VE3_ANOINI
	   M->VE3_ANOFIN := VE3->VE3_ANOFIN
	   acols[1,4] := VE3->VE3_ANOINI
	   acols[1,5] := VE3->VE3_ANOFIN
	   aModelos[1,1] := .t.
	   aModelos[1,2] := VE3->VE3_GRUITE
	   aModelos[1,3] := VE3->VE3_CODITE
	//   aModelos[1,4] := VE3->VE3_FAMILI
	   aModelos[1,5] := VE3->VE3_CODMAR
	   aModelos[1,6] := VE3->VE3_MODVEI
	//   aModelos[1,7] := VE3->VE3_CLASSE
	//   aModelos[1,8] := VE3->VE3_SUBCLA
	   aModelos[1,9] := VE3->VE3_ANOINI+"/"+VE3->VE3_ANOFIN
   Endif

	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"V9")
    For a := 1 to Len(aFamilia)
	   if aFamilia[a,1]
		  aModelos[1,4] := aFamilia[a,2]
		  Exit
	   Endif
   	Next
	nClasse := 0
	For b := 1 to Len(aClasse)
	   if aClasse[b,1]
		  aModelos[1,7] := aClasse[b,2]
		  Exit
	   Endif
	Next
	nSubcla := 0
	For c := 1 to Len(aSubCla)
	   if aSubCla[c,1]
		  aModelos[1,8] := aSubCla[c,2]
		  Exit
	   Endif
	Next

Else
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"V7")
	While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V7"

	    if Len(aFamilia) == 1 .and. Empty(aFamilia[1,2])
	        aFamilia := {}
		Endif
		aAdd(aFamilia,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})

	   dbSelectArea("SX5")
	   dbSkip()

	Enddo

	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"V8")
	While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V8"

	    if Len(aClasse) == 1 .and. Empty(aClasse[1,2])
	        aClasse := {}
		Endif
		aAdd(aClasse,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})

	   dbSelectArea("SX5")
	   dbSkip()

	Enddo

	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"V9")
	While !Eof() .and. xFilial("SX5") == SX5->X5_FILIAL .and. SX5->X5_TABELA == "V9"

	    if Len(aSubCla) == 1 .and. Empty(aSubCla[1,2])
	        aSubCla := {}
		Endif
		aAdd(aSubCla,{.f.,Alltrim(SX5->X5_DESCRI),SX5->X5_CHAVE})

	   dbSelectArea("SX5")
	   dbSkip()

	Enddo
Endif
if nOpc == 2
   lOpc := .f.
Else
   lOpc := .t.
Endif
DEFINE MSDIALOG oDlg1 TITLE STR0009 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],(aPosObj[1,4]/2)-30 LABEL ("") OF oDlg1 PIXEL // Caixa - Descricao Item / Meses Demanda

@ aPosObj[1,1]+006,aPosObj[1,2]+003 SAY STR0010 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+006,aPosObj[1,2]+020 MSGET oGrupo  VAR cGrupo PICTURE "@!" F3 "SBM" SIZE 30,08 OF oDlg1 PIXEL when lOpc
@ aPosObj[1,1]+006,aPosObj[1,2]+065 SAY STR0011 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+006,aPosObj[1,2]+095 MSGET oCodIte VAR cCodIte VALID FS_CODITE() PICTURE "@!" F3 "B20" SIZE 60,08 OF oDlg1 PIXEL when lOpc

@ aPosObj[1,1]+018,aPosObj[1,2]+053 SAY STR0012 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+028,aPosObj[1,2]+003 SAY STR0010 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+028,aPosObj[1,2]+020 MSGET oGrupoA  VAR cGrupoA PICTURE "@!" F3 "SBM" SIZE 30,08 OF oDlg1 PIXEL when lOpc
@ aPosObj[1,1]+028,aPosObj[1,2]+065 SAY STR0011 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+028,aPosObj[1,2]+095 MSGET oCodIteA VAR cCodIteA VALID FS_CODITEA() PICTURE "@!" F3 "B23" SIZE 60,08 OF oDlg1 PIXEL when lOpc

nTam := ((aPosObj[2,4]/2)-30)/3
@ aPosObj[2,1],aPosObj[2,2] LISTBOX olBox4 FIELDS HEADER "",;
														 STR0013;
    													COLSIZES 15,60 SIZE nTam,aPosObj[2,3]-63 OF oDlg1 PIXEL ON DBLCLICK (FS_MarcaFam(olBox4:nAt,nOpc))
olBox4:SetArray(aFamilia)
olBox4:bLine := { || {  if(aFamilia[olBox4:nAt,1] == .f.,oNo,oTik) ,;
								aFamilia[olBox4:nAt,2] }}
olBox4:bHeaderClick := {|oObj,nCol|  FS_MarFam() , olBox1:Refresh() }

@ aPosObj[2,1],aPosObj[2,2]+nTam LISTBOX olBox2 FIELDS HEADER "",;
														 STR0014;
    													COLSIZES 15,60 SIZE nTam,aPosObj[2,3]-63 OF oDlg1 PIXEL ON DBLCLICK (FS_MarcaCla(olBox2:nAt,nOpc))
olBox2:SetArray(aClasse)
olBox2:bLine := { || {  if(aClasse[olBox2:nAt,1] == .f.,oNo,oTik) ,;
								aClasse[olBox2:nAt,2] }}
olBox2:bHeaderClick := {|oObj,nCol|  FS_MarCla() , olBox1:Refresh() }

@ aPosObj[2,1],aPosObj[2,2]+(nTam * 2) LISTBOX olBox3 FIELDS HEADER "",;
														 STR0015;
    													COLSIZES 15,60 SIZE nTam,aPosObj[2,3]-63 OF oDlg1 PIXEL ON DBLCLICK (FS_MarcaSubCla(olBox3:nAt,nOpc))
olBox3:SetArray(aSubCla)
olBox3:bLine := { || {  if(aSubCla[olBox3:nAt,1] == .f.,oNo,oTik) ,;
								aSubCla[olBox3:nAt,2] }}
olBox3:bHeaderClick := {|oObj,nCol|  FS_MarSCla() , olBox1:Refresh() }

@ aPosObj[1,1],(aPosObj[1,4]/2)-30 LISTBOX olBox1 FIELDS HEADER "",;
														 STR0010,;
														 STR0016,;
														 STR0013,;
														 STR0017,;
														 STR0018,;
														 STR0014,;
														 STR0015,;
														 STR0019;
    													COLSIZES 15,20,60,40,20,40,40,40,40 SIZE (aPosObj[1,4]/2)+30,aPosObj[3,3]-10 OF oDlg1 PIXEL ON DBLCLICK(FS_MarcaMod(olBox1:nAt,nOpc))
olBox1:SetArray(aModelos)
olBox1:bLine := { || {  if(aModelos[olBox1:nAt,1] == .f.,oNo,oTik) ,;
								aModelos[olBox1:nAt,2],;
								aModelos[olBox1:nAt,3],;
								aModelos[olBox1:nAt,4],;
								aModelos[olBox1:nAt,5],;
								aModelos[olBox1:nAt,6],;
								aModelos[olBox1:nAt,7],;
								aModelos[olBox1:nAt,8],;
								aModelos[olBox1:nAt,9] }}
olBox1:bHeaderClick := {|oObj,nCol|  FS_MarcaT() , olBox1:Refresh() }



oGetVeiculo                 := MsGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],(aPosObj[3,4]/2)-30,nOpcG,cLinOkP,cTudoOk,,.T.,,,,nLinhas,cFieldOkP,,,,oDlg1)
oGetVeiculo:oBrowse:default()
oGetVeiculo:oBrowse:bChange   := {|| .t.}
oGetVeiculo:oBrowse:bEditCol  := {|| .t. }
oGetVeiculo:oBrowse:bDelete   := {|| IIf(aCols[n,Len(aCols[n])] , aCols[n,Len(aCols[n])] := .f. , aCols[n,Len(aCols[n])] := .t.),oGetVeiculo:oBrowse:SetFocus(),oGetVeiculo:oBrowse:Refresh(),FG_MEMVAR() }
oGetVeiculo:oBrowse:bGotFocus := {|| oGetVeiculo:oBrowse:Refresh()}
oGetVeiculo:oBrowse:Refresh()

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| IIf(FS_GRAPA970(nOpc),(oDlg1:End(),nOpca := 1),.f.) } , {|| oDlg1:End(),nOpca := 2})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRAPA970บAutor  ณThiago              บ Data ณ  13/09/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao na tabela VE3 dos itens selecionados.               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAPA970(nOpc)
Local y := 0
Local lAchou := .f.

if Len(aModelos) == 0 .or. (Len(aModelos) == 1 .and. Empty(aModelos[1,2]))
   MsgInfo(STR0026)
   Return(.f.)
Endif
For y := 1 to Len(aModelos)
    lAchou := .t.
	nP := Ascan(aFamilia, {|x| x[2] == aModelos[y,4]})
	nPa := Ascan(aClasse, {|x| x[2] == aModelos[y,7]})
	nPb := Ascan(aSubCla, {|x| x[2] == aModelos[y,8]})
    if aModelos[y,1]
        if nOpc <> 5
            if nP == 0
               cFami := ""
            Else
               cFami := aFamilia[nP,3]
            Endif
            if nPa == 0
                cClas := ""
            Else
            	cClas := aClasse[nPa,3]
            Endif
            if nPb == 0
                cSClas := ""
            Else
            	cSClas := aSubCla[nPb,3]
            Endif
	        dbSelectArea("VE3")
	        dbSetOrder(1)
	        if !dbSeek(xFilial("VE3")+aModelos[y,2]+aModelos[y,3]+aModelos[y,6]+"          "+alltrim(cFami)+alltrim(cClas)+alltrim(cSClas))
			    RecLock("VE3", .t. )
			    VE3->VE3_FILIAL := xFilial("VE3")
		    	VE3->VE3_GRUITE := aModelos[y,2]
			    VE3->VE3_CODITE := aModelos[y,3]
	   			nP := Ascan(aFamilia, {|x| x[2] == aModelos[y,4]})
		   		if nP > 0
				    VE3->VE3_FAMILI := aFamilia[nP,3]
				Endif
			    VE3->VE3_CODMAR := aModelos[y,5]
			    VE3->VE3_MODVEI := aModelos[y,6]
   				nP := Ascan(aClasse, {|x| x[2] == aModelos[y,7]})
	   			if nP > 0
				    VE3->VE3_CLASSE := aClasse[nP,3]
				Endif
	   			nP := Ascan(aSubCla, {|x| x[2] == aModelos[y,8]})
   				if nP > 0
				    VE3->VE3_SUBCLA := aSubCla[nP,3]
				Endif
			    VE3->VE3_ANOINI := substr(aModelos[y,9],1,4)
	    		VE3->VE3_ANOFIN := substr(aModelos[y,9],6,4)
			    MsUnlock()
		    Else
			    RecLock("VE3", .f. )
		    	VE3->VE3_FILIAL := xFilial("VE3")
		    	VE3->VE3_GRUITE := aModelos[y,2]
			    VE3->VE3_CODITE := aModelos[y,3]
   				nP := Ascan(aFamilia, {|x| x[2] == aModelos[y,4]})
	   			if nP > 0
				    VE3->VE3_FAMILI := aFamilia[nP,3]
				Endif
		    	VE3->VE3_CODMAR := aModelos[y,5]
			    VE3->VE3_MODVEI := aModelos[y,6]
   				nP := Ascan(aClasse, {|x| x[2] == aModelos[y,7]})
	   			if nP > 0
				    VE3->VE3_CLASSE := aClasse[nP,3]
				Endif
		   		nP := Ascan(aSubCla, {|x| x[2] == aModelos[y,8]})
   				if nP > 0
				    VE3->VE3_SUBCLA := aSubCla[nP,3]
				Endif
			    VE3->VE3_ANOINI := substr(aModelos[y,9],1,4)
	    		VE3->VE3_ANOFIN := substr(aModelos[y,9],6,4)
		    	MsUnlock()
		    Endif
         Else
            if nP == 0
               cFami := ""
            Else
               cFami := aFamilia[nP,3]
            Endif
            if nPa == 0
                cClas := ""
            Else
            	cClas := aClasse[nPa,3]
            Endif
            if nPb == 0
                cSClas := ""
            Else
            	cSClas := aSubCla[nPb,3]
            Endif
	        dbSelectArea("VE3")
	        dbSetOrder(1)
	        if dbSeek(xFilial("VE3")+aModelos[y,2]+aModelos[y,3]+aModelos[y,6]+"          "+alltrim(cFami)+alltrim(cClas)+alltrim(cSClas))
	            RecLock("VE3",.F.,.T.)
    	        dbdelete()
        	    MsUnlock()
            Endif
         Endif
	 Endif
Next
if !lAchou
   MsgInfo(STR0027)
   Return(.f.)
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CODITE บAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao no campo codigo de item.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CODITE()

cGrupoA  := cGrupo
cCodIteA := cCodIte

if !Empty(cCodIte)
	dbSelectArea("SB1")
	dbSetOrder(7)
	if !dbSeek(xFilial("SB1")+cGrupo+cCodIte)
	   MsgInfo(STR0020)
	   Return(.f.)
	Endif
Endif
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CODITEAบAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao no campo codigo de item.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CODITEA()

if !Empty(cCodIteA)
	dbSelectArea("SB1")
	dbSetOrder(7)
	if !dbSeek(xFilial("SB1")+cGrupoA+cCodIteA)
	   MsgInfo(STR0020)
	   Return(.f.)
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUALIZAบAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza listbox.					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ATUALIZA()
Local a := 0
Local b := 0
Local c := 0
Local x := 0
Local i := 0

if Empty(aCols[n,1]) .or. Empty(aCols[n,2]) .or. Empty(aCols[n,3]) .or. Empty(aCols[n,4]) .or. Empty(M->VE3_ANOFIN)
   MsgInfo(STR0025)
   Return(.f.)
Endif
if aCols[n,4] > M->VE3_ANOFIN
   MsgInfo(STR0030)
   Return(.f.)
Endif
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGrupo+cCodIte)
While !Eof() .and. xFilial("SB1") == SB1->B1_FILIAL .and. SB1->B1_GRUPO+SB1->B1_CODITE <= cGrupoA+cCodIteA

	if Len(aModelos) == 1 .and. Empty(aModelos[1,2])
	    aModelos := {}
	Endif
    nPos := Ascan(aModelos,{|x| x[2]+x[3]+x[5]+alltrim(x[6])+x[9] == SB1->B1_GRUPO+SB1->B1_CODITE+aCols[n,1]+alltrim(aCols[n,2])+aCols[n,4]+"/"+M->VE3_ANOFIN })
    if nPos == 0
        nPosicao := Len(aModelos)+1
        lEntrou := .f.
		For a := 1 to Len(aFamilia)
		   if aFamilia[a,1]
				For b := 1 to Len(aClasse)
				   if aClasse[b,1]
				      For c := 1 to Len(aSubCla)
         			     if aSubCla[c,1]
							aAdd(aModelos,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,"","","","","",""})
   						    aModelos[nPosicao,4] := aFamilia[a,2]
		 				    aModelos[nPosicao,7] := aClasse[b,2]
	 					    aModelos[nPosicao,8] := aSubCla[c,2]
							aModelos[nPosicao,5] := aCols[n,1]
							aModelos[nPosicao,6] := aCols[n,2]
							aModelos[nPosicao,9] := aCols[n,4]+"/"+M->VE3_ANOFIN
							nPosicao += 1
					        lEntrou := .t.
	  				     Endif
	 				  Next
	  		       Endif
	  		    Next
			Endif
		Next
		if !lEntrou
		    lEntrou := .f.
			For a := 1 to Len(aFamilia)
			   if aFamilia[a,1]
			   		lAchouCla := .f.
					For b := 1 to Len(aClasse)
					   if aClasse[b,1]
					      lAchouSC := .f.
					      For c := 1 to Len(aSubCla)
         				     if aSubCla[c,1]
								aAdd(aModelos,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,"","","","","",""})
   						    	aModelos[nPosicao,4] := aFamilia[a,2]
		 					    aModelos[nPosicao,7] := aClasse[b,2]
		 					    aModelos[nPosicao,8] := aSubCla[c,2]
								aModelos[nPosicao,5] := aCols[n,1]
								aModelos[nPosicao,6] := aCols[n,2]
								aModelos[nPosicao,9] := aCols[n,4]+"/"+M->VE3_ANOFIN
								nPosicao += 1
						        lEntrou := .t.
						      	lAchouSC := .t.
		  				     Endif
		 				  Next
		 				  if !lAchouSC
								aAdd(aModelos,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,"","","","","",""})
   						    	aModelos[nPosicao,4] := aFamilia[a,2]
		 					    aModelos[nPosicao,7] := aClasse[b,2]
								aModelos[nPosicao,5] := aCols[n,1]
								aModelos[nPosicao,6] := aCols[n,2]
								aModelos[nPosicao,9] := aCols[n,4]+"/"+M->VE3_ANOFIN
								nPosicao += 1
						        lEntrou := .t.
		 				  Endif
	   			   		  lAchouCla := .t.
	  			       Endif
	  			    Next
	  			    if !lAchouCla
						aAdd(aModelos,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,"","","","","",""})
				    	aModelos[nPosicao,4] := aFamilia[a,2]
						aModelos[nPosicao,5] := aCols[n,1]
						aModelos[nPosicao,6] := aCols[n,2]
						aModelos[nPosicao,9] := aCols[n,4]+"/"+M->VE3_ANOFIN
						nPosicao += 1
				        lEntrou := .t.
	  			    Endif
				Endif
			Next
			if !lEntrou
				aAdd(aModelos,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,"","","","","",""})
				aModelos[nPosicao,5] := aCols[n,1]
				aModelos[nPosicao,6] := aCols[n,2]
				aModelos[nPosicao,9] := aCols[n,4]+"/"+M->VE3_ANOFIN
				nPosicao += 1
			Endif
		Endif
	Else
	   MsgStop(STR0029)
	   Return(.f.)
	Endif

    dbSelectArea("SB1")
    dbSkip()
Enddo


olBox1:SetArray(aModelos)
olBox1:bLine := { || {  if(aModelos[olBox1:nAt,1] == .f.,oNo,oTik) ,;
								aModelos[olBox1:nAt,2],;
								aModelos[olBox1:nAt,3],;
								aModelos[olBox1:nAt,4],;
								aModelos[olBox1:nAt,5],;
								aModelos[olBox1:nAt,6],;
								aModelos[olBox1:nAt,7],;
								aModelos[olBox1:nAt,8],;
								aModelos[olBox1:nAt,9] }}

olBox1:refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarcaFamบAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca checkbox					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarcaFam(nLinha,nOpc)

if nOpc <> 2 .and. nOpc <> 5 .and. nOpc <> 4
	If aFamilia[nLinha,1] == .f.
	   aFamilia[nLinha,1] := .t.
	Else
	   aFamilia[nLinha,1] := .f.
	EndIf
Endif
oLbox4:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarcaModบAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca checkbox					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarcaMod(nLinha,nOpc)

if nOpc <> 2
	If aModelos[nLinha,1] == .f.
	   aModelos[nLinha,1] := .t.
	Else
	   aModelos[nLinha,1] := .f.
	EndIf
	oLbox1:Refresh()
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarcaClaบAutor  ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca checkbox					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarcaCla(nLinha,nOpc)

if nOpc <> 2 .and. nOpc <> 5 .and. nOpc <> 4
	If aClasse[nLinha,1] == .f.
	   aClasse[nLinha,1] := .t.
	Else
	   aClasse[nLinha,1] := .f.
	EndIf
	oLbox2:Refresh()
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarcaSubClaบAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca checkbox	       				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarcaSubCla(nLinha,nOpc)

if nOpc <> 2 .and. nOpc <> 5 .and. nOpc <> 4
	If aSubCla[nLinha,1] == .f.
	   aSubCla[nLinha,1] := .t.
	Else
	   aSubCla[nLinha,1] := .f.
	EndIf
	oLbox3:Refresh()
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarcaT     บAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos checkbox    				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarcaT()
Local k := 0

if aModelos[1,1]
	For k := 1 to Len(aModelos)
	    aModelos[k,1] := .f.
	Next
Else
	For k := 1 to Len(aModelos)
	    aModelos[k,1] := .t.
	Next
Endif
oLbox1:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarFam     บAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos checkbox    				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarFam()
Local k := 0

if aFamilia[1,1]
	For k := 1 to Len(aFamilia)
	    aFamilia[k,1] := .f.
	Next
Else
	For k := 1 to Len(aFamilia)
	    aFamilia[k,1] := .t.
	Next
Endif
olBox4:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarCla     บAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos checkbox    				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarCla()
Local k := 0

if aClasse[1,1]
	For k := 1 to Len(aClasse)
	    aClasse[k,1] := .f.
	Next
Else
	For k := 1 to Len(aClasse)
	    aClasse[k,1] := .t.
	Next
Endif
olBox2:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MarSCla     บAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos checkbox    				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MarSCla()
Local k := 0

if aSubCla[1,1]
	For k := 1 to Len(aSubCla)
	    aSubCla[k,1] := .f.
	Next
Else
	For k := 1 to Len(aSubCla)
	    aSubCla[k,1] := .t.
	Next
Endif
olBox3:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOPA970VLIN     บAutor    ณThiago              บ Data ณ  14/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao na linha    				                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OPA970VLIN()

if Empty(aCols[n,4]) .or. Empty(aCols[n,5])
   MsgInfo(STR0024)
   Return(.f.)
Endif

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณFabio               บ Data ณ  04/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao de menu                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { { STR0001,"axPesqui", 0 , 1},;  //Pesquisar
                      { STR0002,"PC970I", 0 , 2},; //Visualizar
                      { STR0003,"PC970I", 0 , 3},; //Incluir
                      { STR0004,"PC970I", 0 , 4},; //Alterar
                      { STR0005,"PC970I", 0 , 5} } //Excluir
Return aRotina
