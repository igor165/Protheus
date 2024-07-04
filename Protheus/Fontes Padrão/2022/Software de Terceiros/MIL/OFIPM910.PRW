/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIPM910 ³ Autor ³  Renata               ³ Data ³ 09/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem pedido Unidade Parada/Emergencia                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PECAS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "OFIPM910.ch"                                 
#Include "fileio.ch"                                 
#Include "protheus.ch"                                 
Function OFIPM910

Local cChave, cCond
Local aCamList := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)   //"Fechar Pedido"
Private cMarca , nIndex := 0
Private cDelFunc , lInverte

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VE6")
dbSetOrder(2)
dbgotop()

if !Pergunte("OFIMAR",.t.) 
  Return
endif

Private cCodMar := MV_PAR01

dbSelectArea("VE6")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VE6_INDREG = "0" .and. VE6_CODMAR == "'+cCodmar+'" .and. empty(VE6_CODPED)'
IF VE6->(FieldPos("VE6_SUGCOM")) > 0
	cCond   := 'VE6_INDREG = "0" .and. VE6_CODMAR == "'+cCodmar+'" .and. empty(VE6_CODPED) .AND. empty(VE6_SUGCOM)'
ENDIF
IndRegua("VE6",cIndex,cChave,,cCond,STR0011)

/*
DbSelectArea("VE6")
nIndex := RetIndex("VE6")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)
*/

  

cDelFunc := ".T."
cMarca := GetMark()

Dbselectarea("VE6")
DbSetOrder(1)

aCamList := {{"VE6_OK",   ,"",""                },;       
              {"VE6_DATREG","",OemtoAnsi(STR0008)},;       //"Data"
              {"VE6_CODUSU","",OemToAnsi(STR0009)},;       //"Usuario"
              {"VE6_DESORI","",OemToAnsi(STR0023)},;       //"Descricao"              
              {"VE6_DESPED","",OemToAnsi(STR0023)},;       //"Descricao"
              {"VE6_NUMOSV","",OemToAnsi(STR0012)},;       //"OS"      
              {"VE6_CHAINT","",OemToAnsi(STR0013)},;       //"Chassi"   
              {"VE6_NOMCLI","",OemToAnsi(STR0014)},;       //"Nome Cliente"   
              {"VE6_NOMFAN","",OemToAnsi(STR0015)},;       //"Nome Fantasia"   
              {"VE6_GRUITE","",OemToAnsi(STR0016)},;       //"Grupo"
              {"VE6_CODITE","",OemToAnsi(STR0017)},;       //"Item"
              {"VE6_QTDITE","",OemToAnsi(STR0018)},;       //"Quantidade"
              {"VE6_FORPAG","",OemToAnsi(STR0019)},;       //"Forma Pagto."
              {"VE6_VALPEC","",OemToAnsi(STR0020)}}        //"Valor"

lInverte := .F.

Markbrow("VE6","VE6_OK",,aCamList,,cMarca)

dbSelectArea("VE6")

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
±±³Fun‡…o    ³PM910F    ³ Autor ³Renata                 ³ Data ³ 09/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as pecas marcadas na MARKBROW, chama mata120 p/   ³±±
±±³          ³ gerar o SC7(pedido de compra)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PM910(CLIAS,NREG,NOPC)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PECAS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PM910F(cAlias,nReg,nOpc)
**************************

Processa({|| FS_GRAVPED()}) 

Return

 /*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GRAVPED Autor  ³Renata                 ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que monta o vetor para o MATA120                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GRAVPED()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INTEGRACAO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVPED()
******************

Local cFornec 
Local cLojFor 
Local nVia    
Local cTrans  
Local nPgt48h 
Local cCond   
Local cNum   
Local cTes  
Local nPrRep

Local cChaInt := ""
Local cForPed := ""
Local cNumOsv := ""
Local nCount  := 0
Local cUm     := 0
Local nContP  := 0
Local aCab    := {}
Local aItem   := {}
Local aIte    := {}            
Local aAltSx1 := {}

Private cSugPed := space(6)
Private lNroPed := .f.
Private cCod1
Private cLocal
Private cCodPed 
Private lMSHelpAuto := .T. // para mostrar os erros na tela
Private lMSErroAuto := .F., lMsFinalAuto := .f.

FG_SEEK("VE4","cCodMar",1,.f.)

if VE4->VE4_PEDINI > 0    
   cSugPed := strzero(VE4->VE4_ULTPED + 1,6)
   lNroPed := .t.   
endif             

cLocal := VE4->VE4_ALMPAD
  
aAltSx1  := { {"01",cSugPed,"","","","","","","","","","","","","",""} }         
FG_AltSx1("VPM910","A",aAltSx1)                   

if !Pergunte("VPM910",.t.) 

   FS_TIRAOK()
   Return

endif

cCodPed := if(lNroPed = .t.,strzero(val(MV_PAR01),6),space(6-len(alltrim(MV_PAR01)))+alltrim(MV_PAR01))

cFornec := strzero(val(MV_PAR02),6)
cLojFor := MV_PAR03
nVia    := MV_PAR04
cTrans  := MV_PAR05
nPgt48h := MV_PAR06
cCond   := MV_PAR07

cNumPed := if(lNroPed=.t.,strzero(val(cCodPed),13),space(13-len(alltrim(cCodPed)))+alltrim(cCodPed))

if fg_seek("VEI","cCodMar+cNumPed",2,.F.) = .t.

   AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0025),{OemtoAnsi(STR0005)})    //numero do pedido ja existe

   Return (.f.)

endif

cUm     := 0
nContP  := 0

Begin Transaction

   dbselectarea("VE6")  
   dbgotop()
   DbSeek( xFilial("VE6") )
              
   do while !eof() .And. VE6->VE6_FILIAL == xFilial("VE6")

      if !empty(VE6_OK)  

         if cUm = 0
                          
            cChaint := VE6_CHAINT  
            cForPed := VE6_FORPED  
            cUm     := 1
           cNumOsv := VE6->VE6_NUMOSV
         
         endif
      
         if cForPed # VE6_FORPED .and. cUm > 0  //forma do pedido

&&            AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0021),{OemtoAnsi(STR0005)})   //tipos de pedidos diferem

            FS_TIRAOK()
             
            Help("  ",1,"FPEDDIF")

            DisarmTransaction()
            Break
            
&&            Return     

         endif

         if (cChaint # VE6_CHAINT) .and. (cForPed = VE6_FORPED) .and. (cUm > 0)  //chassi

&&            AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0006),{OemtoAnsi(STR0005)})    //chassis diferem

            FS_TIRAOK()
  
            Help("  ",1,"CHASSIDIF")

            DisarmTransaction()
            Break

&&            Return     

         endif
            
         nContP++
      
      endif
     
      dbskip()
   
   enddo

   if nContP = 0

&&      AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0024),{OemtoAnsi(STR0005)})   //pecas nao foram marcadas

      FS_TIRAOK()
  
      Help("  ",1,"PECNMARC")

      DisarmTransaction()
      Break

&&      Return

   endif

   dbselectarea("VE6")  
   dbgotop()
   DbSeek( xFilial("VE6") )        

   ProcRegua( reccount() ) 

   cNum := CriaVar("C7_NUM") 

   lMSHelpAuto := .T. // para mostrar os erros na tela
   lMSErroAuto := .F.                                                           

   aAdd(aCab,{"C7_NUM"     ,cNum    	          ,Nil}) // Numero do Pedido
   aAdd(aCab,{"C7_EMISSAO" ,dDataBase  		  ,Nil}) // Data de Emissao
   aAdd(aCab,{"C7_FORNECE" ,cFornec    		  ,Nil}) // Fornecedor
   aAdd(aCab,{"C7_LOJA"    ,cLojFor    		  ,Nil}) // Loja do Fornecedor
   aAdd(aCab,{"C7_CONTATO" ,"               "   ,Nil}) // Contato
   aAdd(aCab,{"C7_COND"    ,cCond      		  ,Nil}) // Condicao de pagamento
   aAdd(aCab,{"C7_FILENT"  ,xFilial("VE6")	  ,Nil}) // Filial Entrega

   do while !eof() .And. VE6->VE6_FILIAL == xFilial("VE6")
                    
      if !empty(VE6_OK)
       
         FG_SEEK("SB1","VE6->VE6_GRUITE+VE6->VE6_CODITE",7,.F.) 
      
         cCod1:= SB1->B1_COD        
         cTes := SB1->B1_TE
            
         FG_SEEK("SB5","cCod1",1,.F.) 
         nPrRep := SB5->B5_PRV2

         if nPrRep = 0

&&            AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0027)+VE6->VE6_GRUITE+VE6->VE6_CODITE,{OemtoAnsi(STR0005)})   //NUMEO DO PEDIDO FORA DO INTERVALO

            FS_TIRAOK()
  
            Help("  ",1,"PSPREREPOS")

            DisarmTransaction()
            Break

&&            Return           

         endif
            
         nCount := nCount + 1
                  
//         aAdd(aCab,{"C7_NUM"     ,cNum    		  ,Nil}) // Numero do Pedido
//         aAdd(aCab,{"C7_EMISSAO" ,dDataBase  		  ,Nil}) // Data de Emissao
//         aAdd(aCab,{"C7_FORNECE" ,cFornec    		  ,Nil}) // Fornecedor
//         aAdd(aCab,{"C7_LOJA"    ,cLojFor    		  ,Nil}) // Loja do Fornecedor
//         aAdd(aCab,{"C7_CONTATO" ,"               " ,Nil}) // Contato
//         aAdd(aCab,{"C7_COND"    ,cCond      		  ,Nil}) // Condicao de pagamento
//         aAdd(aCab,{"C7_FILENT"  ,xFilial("VE6")	  ,Nil}) // Filial Entrega
      
         aAdd(aItem,{"C7_ITEM"   ,strzero(nCount,2),Nil}) //Numero do Item
         aAdd(aItem,{"C7_PRODUTO",cCod1             ,Nil}) //Codigo do Produto
         aAdd(aItem,{"C7_QUANT"  ,VE6->VE6_QTDITE  ,Nil}) //Quantidade
         aAdd(aItem,{"C7_PRECO"  ,nPrRep            ,Nil}) //Preco
         aAdd(aItem,{"C7_DATPRF" ,dDataBAse  	      ,Nil}) //Data DE Entrega
         aAdd(aItem,{"C7_UM    " ,SB1->B1_UM 	      ,Nil}) //Data DE Entrega
         aAdd(aItem,{"C7_TES"    ,cTes 	    	  ,Nil}) //Tes
         aAdd(aItem,{"C7_FLUXO"  ,"S"			 	  ,Nil}) //Fluxo de Caixa (S/N)
         aAdd(aItem,{"C7_LOCAL"  ,cLocal        	  ,Nil}) // Almoxarifado
         aAdd(aItem,{"C7_PENDEN" ,VE6->VE6_PEND 	  ,Nil}) // Pendencia    

         aadd(aIte,aclone(aItem))
         aItem := {}              
    
      endif
    
      IncProc(OemtoAnsi(STR0026))   
    
      dbselectArea("VE6")
      dbskip()
   
   enddo   

   MSExecAuto({|x,y| MATA120(1,x,y)},aCab,aIte)

   If lMSErroAuto
      
      DisarmTransaction()
      Break
   
   EndIf
   
   If __lSX8

      ConFirmSX8()    

      dbselectarea("VE6")  
      dbgotop()
      DbSeek( xFilial("VE6") )

      do while !eof() .And. VE6->VE6_FILIAL == xFilial("VE6")

         if !empty(VE6_OK)

            RecLock("VE6",.F.)
            VE6->VE6_CODPED := if(lNroPed=.t.,strzero(val(cCodPed),13),space(13-len(alltrim(cCodPed)))+alltrim(cCodPed))
            VE6->VE6_CODFOR := cFornec 
            VE6->VE6_LOJFOR := cLojFor

         endif   

         dbselectArea("VE6")
         dbskip()

      enddo

      MsUnLock()
      FS_GRAVEI(ccodmar,cnum,ccodped,cforped,nvia,ctrans,cnumosv,cchaint,npgt48h)

   Else 

      RollBackSX8()   

   Endif

   FG_SEEK("VE4","cCodMar",1,.f.)

   if VE4->VE4_PEDINI > 0

      RecLock("VE4",.F.)
      VE4->VE4_ULTPED := val(cCodPed)
      MsUnLock()

   endif

   FS_TIRAOK(ccodmar)
   
End Transaction
lMsHelpAuto := .f. 


If lMsErroAuto
   MostraErro()
EndIf   

Return( !lMsErroAuto )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FSNUMPED  ³ Autor ³Renata                 ³ Data ³ 06/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a numeracao do pedido da montadora                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FSNUMPED()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PECAS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_NUMPED()
****************

if VE4->VE4_PEDINI > 0

   if val(MV_PAR01) < VE4->VE4_PEDINI .or. val(MV_PAR01) > VE4->VE4_PEDFIN              

      AVISO(OemtoAnsi(STR0004),OemtoAnsi(STR0022),{OemtoAnsi(STR0005)})   //NUMEO DO PEDIDO FORA DO INTERVALO

      Return(.f.)

   endif     

endif

Return(.T.)
 
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TIRAOK ³ Autor ³Renata                 ³ Data ³ 06/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga o conteudo do VE6->OK, colocado pela MARKBROW        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_TIRAok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pecas                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                               
Function FS_TIRAOK()
****************  

dbselectarea("VE6") 
dbgotop()
dbsetorder(1)
DbSeek( xFilial("VE6") )

do while !eof() .And. VE6->VE6_FILIAL == xFilial("VE6")

   if !empty(VE6->VE6_OK)

      RecLock("VE6",.F.)
      VE6->VE6_OK := space(2)
      MsUnLock()

   endif   

   dbskip()

enddo

DbSelectArea("VE6")
dbSetOrder(nIndex+1)

dbgotop()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GRAVEI ³ Autor ³Renata                 ³ Data ³ 06/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados no arquivo VEI                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GRAVEI()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pecas                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVEI(ccodmar,cnum,ccodped,cforped,nvia,ctrans,cnumosv,cchaint,npgt48h)
********************************************************************

dbselectarea("VEI")

cPed := if(lNroPed=.t.,strzero(val(cCodPed),13),space(13-len(alltrim(cCodPed)))+alltrim(cCodPed))

lVei := FG_SEEK("VEI","cCodMar+cPed",2,.f.)

RecLock("VEI", !lVei )                     

if nvia = 1 
   cvia := "1"    //rodoviario
elseif nvia = 2  
   cvia := "2"    //ferroviario
elseif nvia = 3
   cvia := "3"    //aereo
elseif nvia = 4
   cvia := "4"    //maritimo
elseif nvia = 5
   cvia := "5"    //fluvial
endif

if npgt48h = 1 
   cpgt48h := "1"  //nao
elseif nvia = 2
   cpgt48h := "2"  //sim
endif

VEI->VEI_FILIAL := xFilial("VEI")
VEI->VEI_CODMAR := cCodMar 
VEI->VEI_NUM    := cNum
VEI->VEI_PEDFAB := cPed
VEI->VEI_TIPPED := cForPed
VEI->VEI_VIATRA := cVia
VEI->VEI_TRANSP := cTrans
VEI->VEI_NUMOSV := cNumosv
VEI->VEI_CHAINT := cChaint
VEI->VEI_PGT48H := cPgt48h
VEI->VEI_DATSC7 := ddatabase
VEI->VEI_HORSC7 := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
MsUnLock()

Return                                    

Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui", 0 , 1},;
                      { STR0003 ,"PM910F", 0 , 4}}  //FECHAR PEDIDO
Return aRotina
