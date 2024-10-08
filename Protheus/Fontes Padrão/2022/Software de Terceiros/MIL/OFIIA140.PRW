// 浜様様様曜様様様様�
// � Versao � 06     �
// 藩様様様擁様様様様�

#INCLUDE "Ofiia140.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIIA140 � Autor �  Renata               � Data � 07/12/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Exportacao dos dados garantia VG6/VG8 p/o arquivo integracao咳�
臼�          � VI6/VIC  SC                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官� 
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function OFIIA140

Private aCampos := {} , Inclui := .f. 
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //"Exportacao dos Dados da Garantia  p/ Fabrica VW //"Exportacao dos Dados da Garantia para Montadora"
Private lAbortPrint := .f.
Private cIndex , cChave , cCond  , nIndex := 0
Private cMarca
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private cTpCust := space(3)

cMarca := GetMark()
        
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

dbSelectArea("VG8")
dbSetOrder(1)

cIndex := CriaTrab(nil,.f.)
cChave  := IndexKey()   //"VO1_FILIAL+VO1_NUMOSV"
cCond   := 'VG8_TRANSM == "N" .and. VG8_EXPGAR=="S" .and. VG8_EXCLUI == " "'
IndRegua("VG8",cIndex,cChave,,cCond,STR0005) //"Aguarde, filtrando registros..."

DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

&& mBrowse( 6, 1,22,75,"VG8")
Markbrow("VG8","VG8_OK",,,,cMarca)

dbSelectArea("VG8")
RetIndex("VG8")
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Vol_EXPVG8()     //Volta o VG8_EXPGAR P/ "S"

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA140V    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � visualiza os dados dos arquivos VG6/VG8                    咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � IA140V(cAlias,nReg,nOpc)                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico - MODELO 3                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA140V(cAlias,nReg,nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk

Private aRotina := { { "" ,"", 0 , 1   },;
                     { "" ,"", 0 , 2   },;    //VIZUALIZAR
                     { "" ,"", 0 , 4   },;   //ALTERAR
                     { "","",  0,  4   }}
Private aCpoEnchoice := {} , aCols := {} , aHeader := {}

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VG8")

While !Eof().and.(x3_arquivo=="VG8")

   if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VG8_TRANSM/VG8_EXCLUI/VG8_CODSER/VG8_SERINT/VG8_EXPGAR])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)

   dbSkip()
   
End

If !(Inclui)
   DbSelectArea("VG8")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

if nOpc == 3   //ALTERAR
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2  //VIZUALIZAR
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5      //EXCLUIR
   nOpcG := 5
endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0

dbSelectArea("SX3")
dbSeek("VG6")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG6")

   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VG6_TRANSM/VG6_EXCLUI/VG6_NOSNUP/VG6_NOSNUS])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      
      &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
      
   Endif
   
   dbSkip()
   
End

aCols:={}
dbSelectArea("VG6")
dbSetOrder(5)
dbSeek(xFilial("VG6")+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)

If nOpc == 3 .Or. !Found()

   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next

Else

   While !eof() .And. M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC ;
                 .And. VG6->VG6_FILIAL == xFilial("VG6")
   
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End

Endif

dbsetorder(1)

If Len(aCols)>0
   //敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
   //� Executa a Modelo 3                                           �
   //青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
   cTitulo       :=STR0001    //"Exclui Garantia"
   cAliasEnchoice:="VG8"
   cAliasGetD    :="VG6"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="FS_TudOk()"   //"FS_OrdGaVw('M->VG6_ORDITE','VG8->VG8_NUMOSV'),FS_GarOk()"
   cFieldOk      :="FG_MEMVAR()"

   If !(Inclui)
      DbSelectArea("VG8")
      DbSetOrder(1)
      dbSeek(xFilial("VG8")+M->VG8_CODMAR+M->VG8_NUMOSV)
   Endif

   _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   //敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
   //� Executar processamento                                       �
   //青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

   If _lRet .And. nOpc # 2

      dbselectArea("VG8")      
      dbseek(xFilial("VG8")+M->VG8_CODMAR+M->VG8_NUMOSV)

   Endif

Endif

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA010E    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � chama a funcao fs_expvg8, feito dessa forma por causa do   咳�
臼�          � termometro                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � IA010E(cAlias,nReg,nOpc)                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA140E(cAlias,nReg,nOpc)

Processa( {|| FS_EXPVG8() },OemToAnsi(STR0006),"",.t. ) //"Aguarde a exportacao de dados"

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_EXPVG8 � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados no VI6/VIC                                  咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_EXPVG8()                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_EXPVG8()
                  
Local lRet := .t.
Local cCGCCPF , cNOMCLI , cENDCLI , cCIDCLI , cESTCLI , cENDPOS , cDDDFON 
Local cRecons , dDtaAnt , nKilant := 0 , cSerExt , cIteExt , nCpo:=0 , nFoundCpo:=0
Private lMsHelpAuto := .t.

dbselectArea("VG8")
dbSeek(xFilial("VG8"))

ProcRegua( reccount() )   

Begin Transaction

   while !eof() .And. VG8->VG8_FILIAL == xFilial("VG8")

      IncProc(OemtoAnsi(STR0007)) //"Gravando arquivos de integracao!!"
      If lAbortPrint
         If MsgYesNo(OemToAnsi(STR0008),OemToAnsi(STR0009)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
            lRet := .f.
            DisarmTransaction()
            Break
         Else
            lAbortPrint := .f.
         EndIf
      EndIf

      If !IsMark("VG8_OK",ThisMark(),ThisInv()) && Se Nao Marcado
         dbskip()
         Loop
      EndIf

      If VG8->VG8_TRANSM = "S"
         dbskip()
         loop
      EndIf

      If VG8->VG8_EXCLUI = "S"
         dbskip()
         loop
      EndIf

      If !RecLock("VG8",.f.)
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break
      EndIf
      VG8->VG8_EXPGAR := "S"
      MsUnlock()

      FG_SEEK("SA1","VG8->VG8_CODCLI+VG8->VG8_LOJA",1,.F.)  //CLIENTE
      cCGCCPF := SA1->A1_CGC
      cNOMCLI := SA1->A1_NOME
      cENDCLI := SA1->A1_END
		If lA1_IBGE
			VAM->(DbSetOrder(1))	
			VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
	      cCIDCLI := VAM->VAM_DESCID
   	   cESTCLI := VAM->VAM_ESTADO
		Else
	      cCIDCLI := SA1->A1_MUN
   	   cESTCLI := SA1->A1_EST
		EndIf
      cENDPOS := SA1->A1_CEP
      cDDDFON := SA1->A1_DDD + left(SA1->A1_TEL,8)

      FG_SEEK("VV1","VG8->VG8_CHAINT",1,.F.)  //VEICULO

      dbselectArea("VE4")                     //FABRICANTE      
      dbsetorder(1)
      dbseek(xFilial("VE4")+VV1->VV1_CODMAR)  //SC

      cRecons := " "

      if VG8->VG8_RECONS = "0"
         cRecons := "N"
      elseif VG8->VG8_RECONS = "1"
         cRecons := "S"
      endif

      dbselectArea("VI6")      
      dbsetorder(1)
      dbseek(xFilial("VI6")+VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC)

      dDtaAnt := ctod("  /  / ")
      nKilant := 0

/*
      dbselectarea("VO1")
      FG_SEEK("VO1","VG8->VG8_CHAINT",4,.f.)
      while !eof() .and. VG8->VG8_CHAINT = VO1->VO1_CHAINT .and. VG8->VG8_NUMOSV # VO1->VO1_NUMOSV .AND. VO1->VO1_FILIAL == XFILIAL("VO1")
         dbskip()
         if VO1->VO1_NUMOSV = VG8->VG8_NUMOSV
           dbskip(-1)
           if VG8->VG8_CHAINT = VO1->VO1_CHAINT
              dDtaAnt := VO1->VO1_DATABE
              nKilAnt := VO1->VO1_KILOME  
              exit
           endif
        endif
      enddo
*/

      dbselectArea("VI6")
      
      If !RecLock("VI6", !Found() )
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break               
      EndIf

      VI6->VI6_FILIAL := xFilial("VI6")

		&& Grava campos relacionado do arquivos VGA/VI6      
		For nCpo:=1 to VI6->(FCount())

			nFoundCpo := VG8->(FieldPos( "VG8"+Substr(VI6->(FieldName(nCpo)),4) ))
			
			If nFoundCpo # 0 .And. ( Valtype(VI6->(FieldGet(nCpo))) == Valtype(VG8->(FieldGet(nFoundCpo))) )
			
				&( "VI6->"+VI6->(FieldName(nCpo)) ) := VG8->(FieldGet(nFoundCpo))
					
			EndIf
								
		Next                                           

      VI6->VI6_CODMAR := VG8->VG8_CODMAR
      VI6->VI6_TIPREG := "GAR"
      VI6->VI6_NUMOSV := VG8->VG8_NUMOSV
      VI6->VI6_ANORRC := VG8->VG8_ANORRC
      VI6->VI6_NUMRRC := VG8->VG8_NUMRRC
      VI6->VI6_CODCON := VE4->VE4_CODCON
      VI6->VI6_TIPREC := VG8->VG8_CODREC
      VI6->VI6_MOTORE := VG8->VG8_MOTORE
      VI6->VI6_PESITE := VV1->VV1_PESBRU
      VI6->VI6_VEIEXP := if(VG8->VG8_VEIEXP="0","N","S")
      VI6->VI6_REMNF1 := VG8->VG8_NF1REM
      VI6->VI6_REMNF2 := VG8->VG8_NF2REM
      VI6->VI6_SERNFI := VG8->VG8_SERNFI
      VI6->VI6_DTANFI := VG8->VG8_DATNFI
      VI6->VI6_CODGAR := VG8->VG8_CODGAR
      VI6->VI6_DTAFIM := VG8->VG8_DATDIS   
      VI6->VI6_PRIREV := VG8->VG8_PRIREV

***
*     A condicao colocada abaixo � apenas emergencial para envio de garantia da
*     Escandin�via, pois como n�o foi importado o hist�rico do ve�culo, e se faz
*     necess�rio informar � f�brica a data do �ltimo reparo, foi aberto um campo
*     no VG8 para o usu�rio informar a data, caso o historico do sistema n�o tenha
***

/*      
      If empty(dDtaAnt)
         VI6->VI6_DTAANT := VG8->VG8_REPANT
      Else
         VI6->VI6_DTAANT := dDtaAnt
      Endif

      VI6->VI6_KILANT := nKilAnt
*/

      VI6->VI6_DTAANT := VG8->VG8_REPANT
      VI6->VI6_KILANT := VG8->VG8_KILANT
      VI6->VI6_KILATU := VG8->VG8_KILGAR
      VI6->VI6_DTAGAR := VG8->VG8_ABEGAR
      VI6->VI6_TESCPO := VG8->VG8_TESCPO
      VI6->VI6_CAMPAN := VG8->VG8_CODCAM
      VI6->VI6_NROCON := VG8->VG8_SERCON
      VI6->VI6_TIPCON := VG8->VG8_TIPCON
      VI6->VI6_PECCAU := VG8->VG8_ITECAU
      VI6->VI6_GRUDEF := VG8->VG8_GRUSER
      VI6->VI6_CODDEF := VG8->VG8_CODDEF
      VI6->VI6_KILPIC := VG8->VG8_KILPIC
      VI6->VI6_KILGUI := VG8->VG8_KILGUI
      VI6->VI6_RECONS := cRecons
      VI6->VI6_CGCCPF := cCGCCPF
      VI6->VI6_NOMCLI := left(cNOMCLI,35)
      VI6->VI6_DDDFON := left(cDDDFON,12)
      VI6->VI6_CODPLU := VG8->VG8_CODPLU
//      VI6->VI6_RECLA1 := subs(VG8->VG8_MOTREC,1,61)
//      VI6->VI6_RECLA2 := subs(VG8->VG8_MOTREC,62)
      VI6->VI6_CHASSI := VV1->VV1_CHASSI
      VI6->VI6_GDWILL := VG8->VG8_GDWILL

      MsUnlock()

      dbselectArea("VG6")      
      dbsetorder(5)
      dbseek(xFilial("VG6")+VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC)

      while !eof() .and. VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC ;
                       .And. VG6->VG6_FILIAL == xFilial("VG6")

         if VG6->VG6_TRANSM = "S"
            dbselectarea("VG6")
            dbskip()
            loop
         endif

         if empty(VG6->VG6_NUMRRC)
            dbselectarea("VG6")
            dbskip()
            loop
         endif
   
         if VG6->VG6_EXCLUI = "S"
            dbselectarea("VG6")
            dbskip()
            loop
         endif

         cSerExt := ""
         cIteExt := ""

         if VG6->VG6_SEREXT = "0"
            cSerExt := "N"
         elseif VG6->VG6_SEREXT ="1"
            cSerExt := "S"
         else
            cSerExt := ""
         endif

         if VG6->VG6_ITEEXT = "0"
            cIteExt := "N"
         elseif VG6->VG6_ITEEXT ="1"
            cIteExt := "S"
         else
            cIteExt := ""
         endif

         dbselectArea("VIC")        

         if !empty(VG6->VG6_CODITE)
            dbsetorder(4)
            dbseek(xFilial("VIC")+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC+VG6->VG6_ORDENS+cIteExt+VG6->VG6_CODITE)
         else   
            dbsetorder(5)
            dbseek(xFilial("VIC")+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC+VG6->VG6_ORDENS+cSerExt+VG6->VG6_CODSER)
         endif
      
         dbselectArea("VIC")
         
         If !RecLock("VIC", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         VIC->VIC_FILIAL := xFilial("VIC")

			&& Grava campos relacionado do arquivos VGA/VI6      
			For nCpo:=1 to VIC->(FCount())
	
				nFoundCpo := VG6->(FieldPos( "VG6"+Substr(VIC->(FieldName(nCpo)),4) ))
				
				If nFoundCpo # 0 .And. ( Valtype(VIC->(FieldGet(nCpo))) == Valtype(VG6->(FieldGet(nFoundCpo))) )
				
					&( "VIC->"+VIC->(FieldName(nCpo)) ) := VG6->(FieldGet(nFoundCpo))
						
				EndIf
									
			Next                                           
                                   
         if VG6->VG6_TPCUST = "1"
            cTpCust := "MOT"
         elseif VG6->VG6_TPCUST = "2"
            cTpCust := "MAT"
         elseif VG6->VG6_TPCUST = "3"         
            cTpCust := "OLL"   
         elseif VG6->VG6_TPCUST = "4"
            cTpCust := "RR "
         elseif VG6->VG6_TPCUST = "5"         
            cTpCust := "TO "   
         elseif VG6->VG6_TPCUST = "9"         
            cTpCust := "MO "   
         else         
	         cTpCust := space(3)
         endif
         
         VIC->VIC_CODMAR := VG6->VG6_CODMAR
         VIC->VIC_NUMOSV := VG6->VG6_NUMOSV
         VIC->VIC_ANORRC := VG6->VG6_ANORRC
         VIC->VIC_NUMRRC := VG6->VG6_NUMRRC
         VIC->VIC_CODSER := VG6->VG6_CODSER
         VIC->VIC_DESSER := VG6->VG6_DESSER
         VIC->VIC_TPOGAR := VG6->VG6_TPOGAR
         VIC->VIC_SERESP := cSerExt
         VIC->VIC_CODITE := VG6->VG6_CODITE
         VIC->VIC_QTDITE := VG6->VG6_QTDITE
         VIC->VIC_VALMAT := if(cSerExt="S",VG6->VG6_VALSER,VG6->VG6_VALITE)
         VIC->VIC_ITEESP := cIteExt
         VIC->VIC_TPCUST := cTpCust
         MsUnlock()

         dbselectArea("VG6")
         
         If !RecLock("VG6",.F.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         VG6->VG6_TRANSM := "S"
         MsUnlock()

         dbskip()

      enddo

      dbselectArea("VG8")
      
      If !RecLock("VG8",.F.)
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break               
      EndIf
      
      VG8->VG8_TRANSM := "S"
      VG8->VG8_DATTRA := dDataBase
      MsUnlock()

      IncProc(OemtoAnsi(STR0007))    //"Gravando arquivos de integracao!!"
      dbskip()

   enddo

End Transaction
   
If !lRet
   MostraErro()
EndIf

//cIndex := CriaTrab(nil,.f.)
//cChave  := IndexKey()   //"VO1_FILIAL+VO1_NUMOSV"
//cCond   := 'VG8_TRANSM=="N".and.VG8_EXPGAR=="S".and.VG8_EXCLUI=" "'
//IndRegua("VG8",cIndex,cChave,,cCond,"Aguarde, filtrando registros...")
  
DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

return
                           
/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �VOL_EXPVG8� Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Volta a Situacao do VG8_EXPGAR p/ "S" caso tenha algum "N" 咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � VOL_EXPVG8()                                               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function Vol_EXPVG8()
                   
Local lRet := .t. 
Private lMsHelpAuto := .t.

Begin Transaction

   DbSelectArea("VG8")
   DbSeek(xFilial("VG8"))

   do while !eof() .And. VG8->VG8_FILIAL == xFilial("VG8")

      if VG8->VG8_EXPGAR = "N"

         If !RecLock("VG8",.F.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         VG8->VG8_EXPGAR := "S"   //OS GARANTIA P/ SER EXPORTADA
         MsUnlock()
 
      endif

      DbSelectArea("VG8")
      dbskip()

   enddo
   
End Transaction

If !lRet 
   MostraErro()
EndIf   

return(lRet)

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �CPOIA140  � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  咳�
臼�          � do VG8                                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � CPOIA140()                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CPOIA140()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VG8")
aCampos := {}

do While !eof() .and. x3_arquivo == "VG8"

   if X3USO(x3_usado) .And. cNivel>=x3_nivel .And. x3_campo $ [VG8_NUMOSV/VG8_SERIEN/VG8_CHASSI/VG8_CODGAR/VG8_DESGAR/VG8_DESMAR/VG8_CODCLI/VG8_NOMCLI/VG8_ABEGAR/VG8_EXPGAR]
      aadd(aCampos,x3_campo)
   endif
   
   dbskip()
   
Enddo

DbSelectArea("VG8")

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui",0, 1},; 	//Pesquisar
                   { STR0002 ,"IA140V", 0 , 2},; 	//Visualizar
                   { STR0003 ,"IA140E", 0 , 3}} 	//Exportar
Return aRotina
