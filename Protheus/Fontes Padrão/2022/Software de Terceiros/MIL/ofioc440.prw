// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 7      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#INCLUDE "OFIOC440.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OFIOC440   ³ Autor ³ Rafael Goncalves     ³ Data ³ 15/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Vizualiza e imprime logs do sistema                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Oficina, Veiculo, Auto-Pecas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC440()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0

Local aParamBox := {}
Local nPosIte := 0
Local nPosDes := 0
Local cFiltroOS := space(8)
Local cFiltroOC := space(8)
Local cValFilt:= ""
Local cDesStats:= ""
Local aDirLog := {}
Local aAuxLog := {}
Local cDatIni := (dDataBase-day(dDataBase))+1 // 1o. dia do mes corrente
Local cDatFin := ddatabase
Local cCodUser:= space(len(__cUserID))
Local ni:=1
Local lok := .f.
Local lAdd := .f. 
Local aOrd := {"","","","","","","","",""}
Local cDescri := ""
Local cOrd    := space(20)
Local cFonte  := ""
Local cData   := ""
Local cUsuar  := ""
Local cOS     := ""
Local cTT     := ""
Local cSrv    := ""
Local cMotivo := ""
Local cProdut := ""

Local cAltera := ""
Local cFil    := ""
Local cNota   := ""
Local cStatus := "" 
Local aOrdem    := {STR0038,STR0039,STR0040}


Private aLogFsOrc := {}
Private aLogPausa := {}
Private aBotoes  := {{STR0011,{|| FS_IMPRIMIR() },STR0001}}
Private cDirLog := ""


aAuxLog := Directory("\logsmil\*.*",'D')//levanta os diretorios da pasta Log.

DbSelectArea("SX5")

For ni:=1 to len(aAuxLog)
	If aAuxLog[ni,1]<>"." .and. aAuxLog[ni,1]<>".."
		aAdd(aDirLog,aAuxLog[ni,1])
	EndIF
Next

While .T.
	aParamBox:= {}
	aRet := {}
	
	aAdd(aParamBox,{2,STR0003,cDirLog,aDirLog,80,"",.T.})
	aAdd(aParamBox,{1,STR0004,cDatIni,"@D","","","",60,.F.})
	aAdd(aParamBox,{1,STR0005,cDatFin,"@D","","","",60,.F.})
	aAdd(aParamBox,{1,STR0006,cCodUser,"","","USR","",0,.F.})
	aAdd(aParamBox,{1,STR0007,cFiltroOC,"",'vazio() .or. FG_SEEK("VS1","mv_par05",1,.F.)',"VS1ORC","",60,.F.})
	aAdd(aParamBox,{1,STR0008,cFiltroOS,"",'vazio() .or. FG_Seek("VO1","mv_par06",1,.f.)',"VO1","",60,.F.})
	aAdd(aParamBox,{2,STR0037,"",aOrdem,80,"",.f.}) 
	
	If ParamBox(aParamBox,STR0002,@aRet,,,,,,,,.F.)
		If Empty(aRet[1]) .or. Empty(aRet[2]) .or. Empty(aRet[3])
			
			msginfo(STR0009,STR0010)
			cDirLog := aRet[1] // Selecione o Diretorio do Log.
			cDatIni := aRet[2] // Data Inicial
			cDatFin := aRet[3] // Data Final
			cCodUser:= aRet[4] // Codigo Usuario
			cFiltroOC := aRet[5] // Codigo Filtro
			cFiltroOS := aRet[6] // Codigo Filtro
			
		Else
			cDirLog := aRet[1] // Selecione o Diretorio do Log.
			cDatIni := aRet[2] // Data Inicial
			cDatFin := aRet[3] // Data Final
			cCodUser:= aRet[4] // Codigo Usuario
			cFiltroOC := aRet[5] // Codigo Filtro
			cFiltroOS := aRet[6] // Codigo Filtro
			lok := .t.
			Exit
		EndIf
	Else
		Exit
	EndIf
EndDo

If lok
	///////////////////////////////////////////////////////////////////////////
	//          C r i a     A r q u i v o    d e    T r a b a l h o          //
	///////////////////////////////////////////////////////////////////////////
	aVetCampos := {}
	aadd(aVetCampos,{ "TRB_LINHA" , "C" , 220 , 0 })     //  Linha Texto  //
	///////////////////////////////////////////////////////////////////////////
	oObjTempTable := OFDMSTempTable():New()
	oObjTempTable:cAlias := "TRB"
	oObjTempTable:aVetCampos := aVetCampos
	oObjTempTable:CreateTable(.f.)
	
	aFiles := {}
	aSize := {}
	aVetCampos:={}
	
	DbSelectArea("TRB")
	
	ADIR("\logsmil\"+cDirLog+"\*.TXT",aFiles,aSize)
	for ni = 1 to len(aFiles)
		if Subs(aFiles[ni],5,8) >= Dtos(cDatIni) .and. Subs(aFiles[ni],5,8) <= Dtos(cDatFin)
			cFile :="\logsmil\"+cDirLog+"\"+aFiles[ni]
			
			Append From &cFile sdf
			//RecLock("TRB",.t.)
			//TRB_LINHA := ""
			//MsUnlock()
		endif
	next
	DbselectArea("TRB")
	DbGoTop()
	
	While !eof()
		nPosIte := 0
		nPosDes := 0
		cValFilt := ""
		cDesStats:= ""
		lAdd := .f.
		//1 - DATA
		//2 - hora
		//3 - usuario
		//4 - orcamento
		//5 - Fase
		
		//selecionar o numero da OS
		nPosIte := AT(STR0014,TRB->TRB_LINHA)
		If nPosIte # 0
			lAdd := .t.
			cValFilt := Subs(TRB->TRB_LINHA,nPosIte+5,len(VO1->VO1_NUMOSV) )
			If !Empty(cFiltroOS)
				If Alltrim(cFiltroOS) <> Alltrim(cValFilt)
					lAdd := .F.
				Endif
			EndiF
			nPosIte := 0
		EndIF
		
		//selecionar o numero do Orcamento
		nPosIte := AT("OFIXA01",TRB->TRB_LINHA)
		If nPosIte # 0
			lAdd := .t.
			cValFilt := subs(right(alltrim(TRB->TRB_LINHA),13),1,TamSx3("VS3_NUMORC")[1])
			cFase1 := subs(right(alltrim(TRB->TRB_LINHA),4),1,1)
			cFase2 := right(alltrim(TRB->TRB_LINHA),1)
			cDesStats2 := ""
			DbSelectArea("SX5")
			DbSetOrder(1)
			IF DbSeek( xFilial("SX5") + "VU"+cFase1)
				cDesStats := SX5->X5_DESCRI
			EndIF
			IF DbSeek( xFilial("SX5") + "VU"+cFase2)
				cDesStats2 := SX5->X5_DESCRI
			EndIF
			If !Empty(cFiltroOC)
				If Alltrim(cFiltroOC) <> Alltrim(cValFilt)
					lAdd := .f.
				Endif
			EndiF
			nPosIte := 0
		EndIF
		
		If lAdd

            if cDirLog == STR0036

				nPosDia := AT(STR0015,TRB->TRB_LINHA)
	
	            cFonte := substr(TRB->TRB_LINHA,1,nPosDia-2)   
	
				nPosUsu := AT(STR0012,TRB->TRB_LINHA)
				If nPosUsu == 0
					nPosUsu := AT(STR0013,TRB->TRB_LINHA)
				Endif
	            cData  := substr(TRB->TRB_LINHA,nPosDia+4,(nPosUsu-nPosDia)-4)
    	
				nPosOS := AT(STR0014,TRB->TRB_LINHA)
            	cUsuar := substr(TRB->TRB_LINHA,nPosUsu+6,(nPosOS-nPosUsu)-6)

				nPosTT := AT(STR0016,Alltrim(TRB->TRB_LINHA)) 
    	        cOS := substr(Alltrim(TRB->TRB_LINHA),nPosOS+4,(nPosTT-nPosOS)-6) 
    	        
				nPosSrv := AT(STR0017,Alltrim(TRB->TRB_LINHA))
	            cTT := substr(Alltrim(TRB->TRB_LINHA),nPosTT+3,(nPosSrv-nPosTT)-5) 
            	
				nPosMot := AT(STR0018,Alltrim(TRB->TRB_LINHA))
        	    cSrv := substr(Alltrim(TRB->TRB_LINHA),nPosSrv+4,(nPosMot-nPosSrv)-6) 
            	
				nPosProd := AT(STR0019,Alltrim(TRB->TRB_LINHA))
        	    cMotivo := substr(Alltrim(TRB->TRB_LINHA),nPosMot,(nPosProd-nPosMot)-1) 
            
        	    cProdut := substr(Alltrim(TRB->TRB_LINHA),nPosProd+6,Len(Alltrim(TRB->TRB_LINHA))) 

				If !Empty(cCodUser)// Codigo Usuario
					IF alltrim(substr(cUsuar,1,6)) <> alltrim(cCodUser)
						nPosIte := 0
						DBSelectArea("TRB")
						DBSkip()
						Loop
					EndIF
					nPosIte := 0
				EndIF

            
				aAdd(aLogPausa,{ cValFilt+Subs(TRB->TRB_LINHA,nPosIte+5,17) , cFonte, cData , cUsuar , cOS , cTT , cSrv ,cMotivo , cProdut })

             Else

				nPosDia := AT(STR0015,TRB->TRB_LINHA)
	
	            cFonte := substr(TRB->TRB_LINHA,1,nPosDia-2)   
	
				nPosUsu := AT(STR0012,TRB->TRB_LINHA)
				If nPosUsu == 0
					nPosUsu := AT(STR0013,TRB->TRB_LINHA)
				Endif
	            cData  := substr(TRB->TRB_LINHA,nPosDia+4,(nPosUsu-nPosDia)-4)
    	
				nPosAlt := AT(STR0020,TRB->TRB_LINHA)
            	cUsuar := substr(TRB->TRB_LINHA,nPosUsu+6,(nPosAlt-nPosUsu)-6)

				nPosA := AT("->",Alltrim(TRB->TRB_LINHA)) 
    	        cAlt := substr(Alltrim(TRB->TRB_LINHA),nPosAlt+5,(nPosA-nPosAlt)-5)
				nPosB := AT(":",cAlt)
	            cAltera := substr(cAlt,1,nPosB-1) 
            	
				cNFil := AT("/",cAlt)
        	    cFil := substr(cAlt,nPosB+1,cNFil-nPosB-1) 
            	
	            cNota := substr(cAlt,cNFil+1,(Len(cAlt)-cNFil)-2) 
    	                                                                      
				cNStatus := AT("->",TRB->TRB_LINHA)
            	cStatus := substr(TRB->TRB_LINHA,cNStatus+2,1) 

		 		If !Empty(cCodUser)// Codigo Usuario
					IF alltrim(substr(cUsuar,1,6)) <> alltrim(cCodUser)
						nPosIte := 0
						DBSelectArea("TRB")
						DBSkip()
						Loop
					EndIF
					nPosIte := 0
				EndIF
            
				aAdd(aLogFsOrc,{ cValFilt+Subs(TRB->TRB_LINHA,nPosIte+5,17) , cFonte, cData , cUsuar , cAltera , cFil , cNota , cStatus , "("+cFase1+")"+"- "+Alltrim(cDesStats) +" para "+"("+cFase2+")"+"- "+Alltrim(cDesStats2)})
             
             Endif                                                                      	
		EndiF
		
		DBSelectArea("TRB")
		DBSkip()
	Enddo
	
	If Len(aLogFsOrc) <= 0
		aAdd(aLogFsOrc,{ "" , "" , "" , "" , "" , "" , "" , "" , "" })
	Endif
	If Len(aLogPausa) <= 0
		aAdd(aLogPausa,{ "" , "" , "" , "" , "" , "" , "" , "" , "" })
	Endif   
	
	if aRet[7] == STR0039                                         
		aSort(aLogFsOrc,,,{|x,y| x[3]+x[7] < y[3]+y[7]})
		aSort(aLogPausa,,,{|x,y| x[3]+x[5] < y[3]+y[5]})
	Elseif aRet[7] == STR0040                                         
		aSort(aLogFsOrc,,,{|x,y| x[4]+x[3] < y[4]+y[3]})
		aSort(aLogPausa,,,{|x,y| x[4]+x[3] < y[4]+y[3]})
	Elseif aRet[7] == STR0038                                        
		aSort(aLogFsOrc,,,{|x,y| x[7]+x[3] < y[7]+y[3]})
		aSort(aLogPausa,,,{|x,y| x[5]+x[3] < y[5]+y[3]})
    Endif
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0, 0 , .T. , .F. } ) 	//Cabecalho
	AAdd( aObjects, { 0, 103 , .T. , .T. } )  	//list box
	//AAdd( aObjects, { 0,   0 , .T. , .T. } )  	//Rodape
	//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
	//tamanho para resolucao 1024*768
	//aSizeAut[3]:= 508
	//aSizeAut[5]:= 1016
	// Fator de reducao de 0.8
	for nCntTam := 1 to Len(aSizeAut)
		aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
	next
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos  := MsObjSize (aInfo, aObjects,.F.)
	

	DEFINE MSDIALOG oLogOfic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0021 OF oMainWnd PIXEL
	oLogOfic:lEscClose := .F.
	// VEICULOS //
    
    if cDirLog <> STR0036
		@ aPos[2,1],aPos[2,2] LISTBOX oLbVeic FIELDS HEADER STR0022,STR0023,STR0024,STR0026,STR0027,STR0025  COLSIZES ;
		30,40,40,35,40,230 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oLogOfic PIXEL //ON DBLCLICK (FS_TIK2(oLbVeic:Nat))
		oLbVeic:SetArray(aLogFsOrc)
		oLbVeic:bLine := { || { aLogFsOrc[oLbVeic:nAt,02],;
								aLogFsOrc[oLbVeic:nAt,03],;
								aLogFsOrc[oLbVeic:nAt,04],;
								aLogFsOrc[oLbVeic:nAt,06],;
								aLogFsOrc[oLbVeic:nAt,07],;
								aLogFsOrc[oLbVeic:nAt,09] }}

	Else                                                   
	
		aAdd(aLogPausa,{ cValFilt+Subs(TRB->TRB_LINHA,nPosIte+5,17) , cFonte, cData , cUsuar , cOS , cTT , cSrv ,cMotivo , cProdut })
	
		@ aPos[2,1],aPos[2,2] LISTBOX oLbVeic FIELDS HEADER STR0022,STR0023,STR0024,STR0028,STR0029,STR0030,STR0031,STR0032  COLSIZES ;
		30,30,30,30,30,40,80,230 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oLogOfic PIXEL //ON DBLCLICK (FS_TIK2(oLbVeic:Nat))
		oLbVeic:SetArray(aLogPausa)
		oLbVeic:bLine := { || { aLogPausa[oLbVeic:nAt,02],;
								aLogPausa[oLbVeic:nAt,03],;
								aLogPausa[oLbVeic:nAt,04],;
								aLogPausa[oLbVeic:nAt,05],;
								aLogPausa[oLbVeic:nAt,06],;
								aLogPausa[oLbVeic:nAt,07],;
								aLogPausa[oLbVeic:nAt,08],;
								aLogPausa[oLbVeic:nAt,09] }}
	Endif
	
	ACTIVATE MSDIALOG oLogOfic ON INIT EnchoiceBar(oLogOfic,{|| oLogOfic:End() , .f. },{|| oLogOfic:End() },,aBotoes ) CENTER
	
	DbSelectArea("TRB")
	oObjTempTable:CloseTable()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Rafael G. Silva       ³ Data ³ 03/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao da Simulacao (SELECIONADOS)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local ni			:= 0
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := "Logs Mil - "+cDirLog
Private cNomProg:= "FM_VERLOG"
Private cNomeRel:= "FM_VERLOG"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

//cabec1 := left("  Data"+space(13),13)+left("Hora"+space(10),10)+left("Usuario"+space(34),34)+left("Status"+space(14),14)
//cabec2 := "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1

if cDirLog == STR0033  
	@ nLin++ , 00 psay STR0034
Else
	@ nLin++ , 00 psay STR0035
Endif
	
if cDirLog == STR0033 
	For ni:=1 to len(aLogFsOrc)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 00 psay aLogFsOrc[ni,2]+" "+Padr(aLogFsOrc[ni,3],20)+" "+aLogFsOrc[ni,4]+" "+Padr(aLogFsOrc[ni,6],12)+" "+aLogFsOrc[ni,7]+"   "+aLogFsOrc[ni,9]
	Next
Else
	For ni:=1 to len(aLogPausa)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 00 psay aLogPausa[ni,2]+" "+Padr(aLogPausa[ni,3],20)+" "+aLogPausa[ni,4]+"   "+Padr(Alltrim(aLogPausa[ni,5]),10)+"    "+Padr(Alltrim(aLogPausa[ni,6]),4)+"   "+aLogPausa[ni,7]+"    "+aLogPausa[ni,8]+"    "+aLogPausa[ni,9]
	Next
Endif

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()   
