#include "Ofiia110.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA110 ³ Autor ³  Renata/Andre         ³ Data ³ 26/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula aumento de preco atraves dos dados do arq. VI2     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA110
                
Private cIndex , cChave , cCond  
Private aCampos       := {}
Private aCamposCamTec := {}
Private aRotina       := MenuDef()
Private cCadastro := OemToAnsi(STR0005)  //Aumento de preco peca original scania
Private cCodMar

if !Pergunte("OFIMAR",.t.) 
   Return
Endif

cCodMar := MV_PAR01

DbSelectArea("VI2")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VI2_CODMAR==cCodMar'
IndRegua("VI2",cIndex,cChave,,cCond,STR0007) //"Filtrando!!"

DbSelectArea("VI2")
nIndex := RetIndex("VI2")+1
#IFNDEF TOP
   DbSetIndex(cIndex+ordBagExt())
#ENDIF
DbSetOrder(nIndex)

mBrowse( 6, 1,22,75,"VI2")

DbSelectArea("VI2")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA110A    | Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama funcoes de gravacoes fs_gravaprc                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IA110A(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA110A(cAlias,nReg,nOpc)

Private aRotina := { {  ,"", , 3},;   && Pesquisar
                      {  ,"", , 3},;   && Visualizar
                      {  ,"", , 3}}    && Atualizar

Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lRet := .t.

Processa( {|| FS_GRAVAPRC() } ) 

If !lRet
   MostraErro()
EndIf

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fs_gravaprc Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta vetor para o mata010 e atualiza o arquivo SB0 c/ os   ³±±
±±³          ³dados do VI2                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FS_GRAVAPRC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVAPRC()
               
Local lAcheiSB1 := .t. , cPecInt
Private nValVda := 0 , nValRep := 0 , nValGar := 0 , nPrePlu , nAlqIPI 
Private cCtaCtb , cCenCus , cAlmox , cTesEnt , cTesSai , cCodFab , cGruIte 
Private aIncSB1 := {}

FG_SEEK("VE4","VI2->VI2_CODMAR",1,.F.)
cCtaCtb := VE4->VE4_CTACTB
cCenCus := VE4->VE4_CENCUS
cAlmox  := VE4->VE4_ALMPAD
cTesEnt := VE4->VE4_TESENT
cTesSai := VE4->VE4_TESSAI      
cCodFab := VE4->VE4_CODFAB   
cGruIte := VE4->VE4_GRUITE
cFEstCo := IF(VE4->VE4_FESTCO="0","N","S")

FG_SEEK("VE1","VI2->VI2_CODMAR",1,.F.)
cFabric := left(VE1->VE1_DESMAR,20)

DbSelectArea("VI2")
DbSeek( xFilial("VI2") )

If !Empty(FG_TRANSACTION("OFIIA110","VI2",,,.F.))
	DbGoTo(FG_TRANSACTION("OFIIA110","VI2",,,.F.))
EndIf	
                 
ProcRegua( reccount() ) 

Do while !Eof() .And. VI2->VI2_FILIAL == xFilial("VI2")

	nTransaction:=0
	
	Begin Transaction

		do while FG_TRANSACTION("OFIIA110","VI2",++nTransaction,RecNo(),(Eof() .Or. VI2->VI2_FILIAL # xFilial("VI2")),"L") .And. !Eof() .And. VI2->VI2_FILIAL == xFilial("VI2")

		   lAcheiSB1 := FG_SEEK("SB1","cGruIte+VI2->VI2_CODITE",7,.F.)  
		
		   if lAcheiSB1
		      Do while !SB1->(eof()) .AND. SB1->B1_GRUPO+SB1->B1_CODITE == cGruIte+VI2->VI2_CODITE .And. SB1->B1_FILIAL == xFilial("SB1")
		         FG_SEEK("SBM","SB1->B1_GRUPO",1,.F.)
		         if SBM->BM_CODMAR == cCodMar
		            lAcheiSB1 = .T.
		            Exit
		         Endif      
		         SB1->(DBSKIP())  
		         lAcheiSB1 = .F.
		      Enddo
		   Endif
		
		   if !Empty(VI2->VI2_CODDST)
		      FG_SEEK("VE5","VI2->VI2_CODMAR+right(alltrim(VI2->VI2_CODDST),1)",1,.F.)                                 
		      if lAcheiSB1                       
		         DbSelectArea("SB1")   
		         If !RECLOCK("SB1",.F.)
		            Help("  ",1,"REGNLOCK")
		            lRet := .f.
		            DisarmTransaction()
		            Break               
		         EndIf
		                                           
					If !Empty(VI2->VI2_DESITE)
			         SB1->B1_DESC   := VI2->VI2_DESITE
			      EndIf   
		         SB1->B1_GRUDES := right(alltrim(VI2->VI2_CODDST),1)
		         SB1->B1_QE     := VI2->VI2_QTDEMB       
		         SB1->B1_PESO   := VI2->VI2_PESITE        
		     	 SB1->B1_IPI    := VI2->VI2_ALQIPI   
		         MSUNLOCK()
		      Endif
		   Elseif lAcheiSB1 = .T.
		      FG_SEEK("VE5","VI2->VI2_CODMAR+SB1->B1_GRUDES",1,.F.)                                    
		   Else
		      dbselectArea("VI2")
		      dbskip()
		      loop
		   Endif
		   
		   nPrePlu := VI2->VI2_PREPLU
		   nAlqIPI := VI2->VI2_ALQIPI
		     
		   FG_SEEK("VEG","VE5->VE5_FORGAR",1,.F.)
		   nValgar := &(VEG->VEG_FORMUL)
		   
		   FG_SEEK("VEG","VE5->VE5_FORVDA",1,.F.)
		   nVAlVda := &(VEG->VEG_FORMUL)
		   
		   FG_SEEK("VEG","VE5->VE5_FORPRP",1,.F.)
		   nValRep := &(VEG->VEG_FORMUL) 
		   
		   if !lAcheiSB1 .and. !Empty(VI2->VI2_CODDST)
		          
		     	If GetNewPar("MV_ITESEQ","S") == "1" 
					cPecInt := VI2->VI2_CODITE
		     	ElseIf GetNewPar("MV_ITESEQ","S") == "2" 
					cPecInt := cGruIte+VI2->VI2_CODITE
				Else
			      cPecInt := GetSXENum("SB1","B1_COD")
			      ConfirmSX8()
				EndIf
		      
		      aIncSB1 := {}
		      aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
			  aAdd(aIncSB1,{"B1_CODITE"  ,VI2->VI2_CODITE      ,Nil}) // Codigo
			  aAdd(aIncSB1,{"B1_DESC"    ,VI2->VI2_DESITE      ,Nil}) // Descricao
			  aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                  ,Nil}) // Tipo do Produto 
			  aAdd(aIncSB1,{"B1_UM"      ,"PC"                  ,Nil}) // 
			  aAdd(aIncSB1,{"B1_LOCPAD"  ,cAlmox                ,Nil}) // 
			  aAdd(aIncSB1,{"B1_PICM"    ,0                     ,Nil}) // 
			  aAdd(aIncSB1,{"B1_IPI"     ,VI2->VI2_ALQIPI       ,Nil}) // 
			  aAdd(aIncSB1,{"B1_TE"      ,cTesEnt                ,Nil}) // 
			  aAdd(aIncSB1,{"B1_TS"      ,cTesSai                ,Nil}) // 
		      if nValVda > VE5->VE5_ALTVLR 
		   	     aAdd(aIncSB1,{"B1_PRV1"    ,nValVda             ,Nil}) //
		  	  endif   
			  aAdd(aIncSB1,{"B1_CONTA"   ,cCtaCtb                ,Nil}) // 
			  if !empty(cCenCus)
		         aAdd(aIncSB1,{"B1_CC"      ,cCenCus              ,Nil}) //
		      endif   
			  aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                     ,Nil}) //
			  aAdd(aIncSB1,{"B1_FABRIC"  ,cFabric                 ,Nil}) //
		 	  aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                     ,Nil}) //
		 	  aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                     ,Nil}) //
		 	  aAdd(aIncSB1,{"B1_IRRF"    ,"N"                     ,Nil}) //
		 	  aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                     ,Nil}) //
			  aAdd(aIncSB1,{"B1_GRUPO"   ,cGruIte                 ,Nil}) // Grupo 
			  aAdd(aIncSB1,{"B1_ENVOBR"  ,"1"                     ,Nil}) //
		      aAdd(aIncSB1,{"B1_QE    "  ,VI2->VI2_QTDEMB         ,Nil}) //	  
		      aAdd(aIncSB1,{"B1_PESO"    ,VI2->VI2_PESITE         ,Nil}) //
		      aAdd(aIncSB1,{"B1_GRUDES"  ,right(alltrim(VI2->VI2_CODDST),1),Nil}) //
		      aAdd(aIncSB1,{"B1_SITPROD"  ,"N"                     ,Nil}) //      
		
		      aAdd(aIncSB1,{"B1_SEGUN"   ,"PC"                     ,Nil}) //      
		      aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                      ,Nil}) //                  
//		      aAdd(aIncSB1,{"B1_FAMILIA" ,"N"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_APROPRI" ,"D"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_FANTASM" ,"N"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                      ,Nil}) //
		      aAdd(aIncSB1,{"B1_UREV   " ,DDATABASE                ,Nil}) //      
		      aAdd(aIncSB1,{"B1_PERINV"  ,180                      ,Nil}) //
		      aAdd(aIncSB1,{"B1_GRADE"   ,"N"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_PROC"    ,VE4->VE4_CODFOR         ,Nil}) //      
		      aAdd(aIncSB1,{"B1_LOJPROC" ,VE4->VE4_LOJFOR         ,Nil}) //      
		      aAdd(aIncSB1,{"B1_FORAEST" ,cFestCo                  ,Nil}) //            
		      aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                      ,Nil}) //                  
		      aAdd(aIncSB1,{"B1_BALANCA" ,"0"                      ,Nil}) //            
		      aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                      ,Nil}) //                        
		      aAdd(aIncSB1,{"B1_CONV"    ,1                        ,Nil}) //                              
		      aAdd(aIncSB1,{"B1_ORIGEM"  ,"00"                     ,Nil}) //      
		      aAdd(aIncSB1,{"B1_MONO"    ,"S"                      ,Nil}) //      
		      aAdd(aIncSB1,{"B1_DTREFP1" ,dDatabase                ,Nil}) //      
		
			  lMSHelpAuto := .t.
			  lMSErroAuto := .f.
			   
		      MSExecAuto({|x| mata010(x)},aIncSB1) 
		                         
		      if lMSErroAuto = .f.   //deu certo  , se retornar .t. deu erro
		      
		         lAcheiSB1 := .t.
		              
		      Else
		                                                    
		         lRet := .t.
		         DisarmTransaction()
		         Break
		         
		      endif
		      
		   else
		      
		      cPecInt := SB1->B1_COD
		      if ValType(nValVda)=="N" .And. nValVda > VE5->VE5_ALTVLR 
		      
		         dbselectarea("SB1")   
		         
		         If !RECLOCK("SB1",.F.)
		            Help("  ",1,"REGNLOCK")
		            lRet := .f.
		            DisarmTransaction()
		            Break               
		         EndIf
		         
					If !Empty(VI2->VI2_DESITE)
			         SB1->B1_DESC := VI2->VI2_DESITE
			      EndIf   
		     	   SB1->B1_PRV1 := nValVda 
		         MSUNLOCK()
		         
		      endif   
		         
		   endif
		
		   dbselectarea("SB5")         
		   DbSetOrder(1)
		   DbSeek( xFilial("SB5") + cPecInt )
		                                             
		   if lAcheiSB1 = .T. .And. ValType(nValRep)=="N" .And. ValType(nValGar)=="N"
		   
		      If !RecLock("SB5", !Found() )
		         Help("  ",1,"REGNLOCK")
		         lRet := .f.
		         DisarmTransaction()
		         Break               
		      EndIf
		      
		      SB5->B5_FILIAL := xFilial("SB5")
		      SB5->B5_COD    := cPecInt    
		      SB5->B5_PRV2   := nValRep
		      SB5->B5_PRV3   := nValGar
		      SB5->B5_CODCAI := if(!empty(VI2->VI2_CODCAI),strzero(VI2->VI2_CODCAI,6),"")
		      SB5->B5_DTREFP2:= dDataBase
		      SB5->B5_DTREFP3:= dDataBase
		      MsUnLock()
		   endif
		   
		   IncProc(OemtoAnsi(STR0006))   
   
		   dbselectArea("VI2")

			If !RecLock("VI2",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VI2")

		   dbskip()

		EndDo
		
	End Transaction
   
enddo      

If lRet
     
	DbSelectArea("VI2")
	DbCloseArea()
	If ChkFile("VI2",.T.)
		Pack	
		DbCloseArea()
	EndIf
	ChkFile("VI2",.F.)
    DbSelectArea("VI2")
    cIndex  := CriaTrab(nil,.f.)
    cChave  := IndexKey()
    cCond   := 'VI2_CODMAR==cCodMar'
    IndRegua("VI2",cIndex,cChave,,cCond,STR0007) //"Filtrando!!"

    DbSelectArea("VI2")
    nIndex := RetIndex("VI2")+1
    #IFNDEF TOP
      DbSetIndex(cIndex+ordBagExt())
    #ENDIF
    DbSetOrder(nIndex)

//	nIndex := RetIndex("VI2")+1
//	#IFNDEF TOP
//	   dbSetIndex(cIndex+ordBagExt())
//	#ENDIF
//	dbSetOrder(nIndex)
	dbgotop()
	
EndIf

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IA110V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ visualiza os dados dos arquivos                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AxVisual(cAlias,nReg,nOpc,aCampos)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA110V(cAlias,nReg,nOpc)

CPOIA110()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CPOIA0110 ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega os campos no SX3 para serem mostrados na visualizacao  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CPOIA0110()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOIA110()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VI2")
aCampos := {}

do While !eof() .and. x3_arquivo == "VI2"

   if X3USO(x3_usado) .And. cNivel>=x3_nivel       
      aadd(aCampos,x3_campo)
   endif

   dbskip()

Enddo

DbSelectArea("VI2")

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0, 1},;    //Pesquisar
                   { STR0002 ,"IA110V"  , 0, 2},;    //Vizualisar
                   { STR0003 ,"IA110A"  , 0, 3  },;  //Atualizar Preco
                   { STR0004 ,"OFIPA990", 0, 3  }}   //Grupo Descto
Return aRotina
