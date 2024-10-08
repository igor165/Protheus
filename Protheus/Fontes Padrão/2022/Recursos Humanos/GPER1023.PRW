#INCLUDE "RWMAKE.CH"        // incluido pelo assistente de conversao do AP5 IDE em 17/04/00
#INCLUDE "REAEST.CH"
#INCLUDE "PROTHEUS.CH"

Function GPER1023()        // incluido pelo assistente de conversao do AP5 IDE em 17/04/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Local aOfusca		:= IIf(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local aFldRel		:= {"RA_NOME"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta豫o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

SetPrvt("CDESC1,CDESC2,CDESC3,CSTRING,AORD,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,CPERG,NTAMANHO,LI")
SetPrvt("NVEZES,AINFO,ADEPEND,LEND,CFILANTE,CTIT")
SetPrvt("WNREL,NORDEM,CFILDE,CFILATE,CMATDE,CMATATE")
SetPrvt("CCCDE,CCCATE,NVIAS,TITULO,CINICIO,CFIM")
SetPrvt("CHAVE,CLCNASC,CCARTO,CNREGCAR,CNUMLIV")
SetPrvt("CE_IE,CE_BAIRRO,CF_NOME,CF_ENDERECO,CF_BAIRRO,CF_CIDADE")
SetPrvt("CF_UF,CF_CEP,CF_CTPS,CF_UFCTPS,CF_SERIE,CF_CIC")
SetPrvt("CF_RG,CF_MAT,CF_FIL,CF_CC,CF_ADMISSA,CF_CGHOR")

/*                                                                 
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � REAEST   � Autor � R.H. - Luciana Silveira         � Data � 24.03.11 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Termo de Realizacao de Estagio                                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � REAEST                                                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � RdMake                                                               낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � FNC            �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Leandro Dr.�19/10/13쿘12RH01-RQ0318  � Unificao da Folha.                       낢� 
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/

cDesc1  := STR0001							//'TERMO DE REALIZA플O DE EST핯IO'
cString := "SRA" 							//-- alias do arquivo principal (Base)
aOrd    := {'Matricula','Centro de Custo'} 	//'Matricula'###'Centro de Custo'
   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Private(Basicas)                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aReturn  := { 'Zebrado',1,'Administracao',2,2,1,'',1 }	//'Zebrado'###'Administra뇙o'
NomeProg := 'REAEST'
aLinha   := {}
nLastKey := 0
cPerg    := 'REAEST'
nTamanho := "M"
   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis Utilizadas na funcao Principal do Programa         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Li       := 0
nVezes   := 0   
aInfo    := {}
lEnd     := .F.
cFilAnte := Replicate("�", FWGETTAMFILIAL)

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "REAEST" , "SRA" , "2" ) + " } " )


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte(cPerg,.F.)
   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis Utilizadas para parametros                         �
//� MV_PAR01        //  FiLial De                                �
//� MV_PAR02        //  FiLial Ate                               �
//� MV_PAR03        //  Matricula De                             �
//� MV_PAR04        //  Matricula Ate                            �
//� MV_PAR05        //  Centro De Custo De                       �
//� MV_PAR06        //  Centro De Custo Ate                      �
//� MV_PAR07        //  N� de Vias                               �
//� MV_PAR08        //  Situacoes                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

cTit := STR0001		//' TERMO DE REALIZA플O DE EST핯IO '
   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
WnRel :='REAEST' 	//-- Nome Default do relatorio em Disco.
WnRel :=SetPrint(cString,WnRel,cPerg,@cTit,,,,.F.,aOrd,,nTamanho,,.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nOrdem  := aReturn[8]

cFilDe	:= If(!Empty(MV_PAR01), MV_PAR01, Space(FWGETTAMFILIAL))
cFilAte	:= If(!Empty(MV_PAR02), MV_PAR02, Replicate("Z", FWGETTAMFILIAL))
cMatDe	:= If(!Empty(MV_PAR03), MV_PAR03, Space(GetSx3Cache("RA_MAT", "X3_TAMANHO")))
cMatAte	:= If(!Empty(MV_PAR04), MV_PAR04, Replicate("Z", GetSx3Cache("RA_MAT", "X3_TAMANHO")) )
cCCDe	:= If(!Empty(MV_PAR05), MV_PAR05, Space(GetSx3Cache("RA_CC", "X3_TAMANHO")))
cCCAte	:= If(!Empty(MV_PAR06), MV_PAR06, Replicate("Z", GetSx3Cache("RA_CC", "X3_TAMANHO")) )
nVias	:= If(!Empty(MV_PAR07), IIf(MV_PAR07 <= 0, 1, MV_PAR07), 1)
cSituacao  := MV_PAR08	 	//Situacoes a Imprimir
cCategoria := "EG" 			//Categorias a Imprimir 

Titulo  := STR0001	//'TERMO DE REALIZA플O DE ESTAGIO'
   
If nLastKey == 27
	Return Nil
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return Nil
EndIf

lEND	:= .F.
WnRel	:= "REAEST"
cSTRING := "SRA"

RptStatus({|lEnd| fReaEst() })// Substituido pelo assistente de conversao do AP5 IDE em 17/04/00 ==>         RptStatus({|lEnd| Execute(fSalFam)},"Ficha de Salario Familia",lEnd)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 17/04/00 ==> 	Function fSalFam
Static Function fReaEst()

Local nX
Local nZ

dbSelectArea('SRA')
dbSetOrder(nOrdem)
SetRegua(RecCount())
dbGotop()

If nOrdem == 1
   dbSetOrder( 1 )
   dbSeek(cFilDe + cMatDe,.T.)
   cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
   cFim     := cFilAte + cMatAte
ElseIf nOrdem == 2
   dbSetOrder( 2 )
   dbSeek(cFilDe + cCcDe + cMatDe,.T.)
   cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
   cFim     := cFilAte + cCcAte + cMatAte
EndIf

//--Setar impressora
@ Li,00 pSay AvalImp(132)

While !Eof()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Incrementa Regua de Processamento.                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IncRegua()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cancela Impres�o ao se pressionar <ALT> + <A>.               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	
 	If lEnd
		@ Prow()+1, 0 PSAY STR0021		//"Cancelado pelo Operador"
		Chave := 1
		Exit
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Processa Quebra de Filial.                                   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If SRA->RA_FILIAL != cFilAnte
		If	!fInfo(@aInfo,SRA->RA_FILIAL)
			dbSelectArea('SRA')
			dbSkip()
			Loop
		EndIf		
		cFilAnte := SRA->RA_FILIAL		
	EndIf	

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Consiste Parametriza눯o do Intervalo de Impress�o.           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If  (SRA->RA_FILIAL < cFilDe) .Or. (SRA->RA_FILIAL > cFilAte) .Or. ;
		(SRA->RA_MAT < cMatDe)    .Or. (SRA->RA_MAT > cMatAte) .Or. ;
		(SRA->RA_CC < cCcDe)      .Or. (SRA->RA_CC > cCCAte) .Or.;
		!( SRA->RA_SITFOLH $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria ).Or. ;
		 SRA->RA_SITFOLH $ "D" .And.  Mesano(SRA->RA_DEMISSA) != Mesano(dDataBase) //Imprime somente os Demitidos do mes Atual.//
		
		dbSelectArea('SRA')
		dbSkip()
		Loop
	EndIf
	
   	/*
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	쿎onsiste Filiais e Acessos                                             �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
	IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
		dbSelectArea("SRA")
   		dbSkip()
   		Loop
	EndIf


	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis utilizadas na impressao.                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cE_Empresa  := Left(aInfo[3],40)
    cE_Endereco := Left(aInfo[4],30)
    cE_Cidade   := Left(aInfo[5],20)
	cE_Uf       := Left(aInfo[6],2)
	cE_Cep      := Transform(Left(aInfo[7],8),'@R #####-###')
    cE_Cgc      := Transform(Left(aInfo[8],14),'@R ##.###.###/####-##')
	cE_Telefone := Left( aInfo[10] + Space( 17 ), 17 )
    cE_Bairro   := Left(aInfo[13],20)
    cF_Nome     := Left(SRA->RA_Nome,30)
	cF_Mat      := Left(SRA->RA_Mat,6)
    cF_admissa  := DtoC(SRA->RA_Admissa)
    cF_demissa  := DtoC(SRA->RA_Demissa)
    cF_Cghor	:= Transform(Sra->Ra_HrsMes,'999') +  space(1) + 'horas/semanais'
    
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Posicionamento das colunas do Termo de Realiza豫o de Est�gio �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   //           1         2         3         4         5         6         7         8         9         0         1         2         3
   // +---------------------------------------------------------------------------------------------------------------------------------+            
   // |Nome da Empresa:                                                                                                                 |            
   // |CNPJ:                                                                                                                            |          
   // |Endere�o:                                                                                                                        |          
   // |Telefone:                                                                                                                        |
   // |Supervisor de Estagio:                                                                                                           |                    
   // +---------------------------------------------------------------------------------------------------------------------------------+           
   
   
   // +---------------------------------------------------------------------------------------------------------------------------------+            
   // |Nome do Estagiario:                                                                                                              |            
   // |Curso:                                                                                                                           |          
   // |Matricula:                                                                                                                       |          
   // +---------------------------------------------------------------------------------------------------------------------------------+           
   //
   //
   // +---------------------------------------------------------------------------------------------------------------------------------+           
   // |* Tarefas realizadas pelo estagi�rio:                                                                                            |            
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // +---------------------------------------------------------------------------------------------------------------------------------+
   //
   //   
   // +---------------------------------------------------------------------------------------------------------------------------------+
   // |* Avalia豫o de Desempenho:                                                                                                       |            
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // |                                                                                                                                 |          
   // +---------------------------------------------------------------------------------------------------------------------------------+
   //
   // 
   // +---------------------------------------------------------------------------------------------------------------------------------+            
   // |Per�odo de Est�gio:              a                                                                                               |            
   // |Carga Hor�ria:         horas/semanais                                                                                            |          
   // +---------------------------------------------------------------------------------------------------------------------------------+             
   // +---------------------------------------------------------------------------------------------------------------------------------+            
   // |Declaro, para fins de comprova豫o junto a(o) Setor de Est�gios da(o) 
   // |que o aluno acima indicado realizou seu Est�gio sob minha responsabilidade.
   // +---------------------------------------------------------------------------------------------------------------------------------+              
       //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
       //� Impressao da Ficha de Salario-Famila                         �
       //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If cPaisLoc == "BRA
		For Nx := 1 to nVias
	       @ Li, 50 PSAY STR0001		//	'TERMO DE REALIZA플O DE EST핯IO'
	       Li := Li+2                                  
	       @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
	       Li := Li+1
	       @ Li, 00 PSAY STR0002 + cE_Empresa + Space(73) + '|' //'Nome da Empresa '
	       Li := Li+1
	       @ Li, 00 PSAY STR0003 + cE_Cgc + Space(106) + '|' //'CNPJ '
	       Li := Li+1
		   @ Li, 00 PSAY STR0004 + cE_Endereco+ space(3)+STR0017 + cE_Bairro + Space(3) + STR0020 + cE_Cep + Space(2) + STR0018 + cE_Cidade + Space(2) + STR0019 + cE_UF + '|'	//'Endereco: '###'  Bairro: '###'CEP: '###'  Cidade: '###'UF: '
	       Li := Li+1
	       @ Li, 00 PSAY STR0005 + cE_Telefone+ space(103) + '|' //Telefone
	       Li := Li+1
	       @ Li, 00 PSAY STR0006 +  space(107) +'|' //Supervisor do Estagio 
	       Li := Li+1
	       @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
			 Li := Li+2 
		   @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		   Li := Li+1 
		   @ Li, 00 PSAY STR0007 + cF_Nome + Space(80) + '|' //'Nome do Estagiario: '
		   Li := Li+1
		   @ Li, 00 PSAY STR0008 + Space(123) + '|' //'Curso '
		   Li := Li+1
		   @ Li, 00 PSAY STR0009 + cF_Mat + Space(113) + '|' //'Matricula: '
		   Li := Li+1 
		   @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
			 Li := Li+2 
		   @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		   Li := Li+1 
		   @ Li, 00 PSAY STR0010 + Space(92) + '|' //'Tarefas realizadas pelo estagi�rio: 
		   Li := Li+1 
	       For Nz:=1 to 15
	       		@ Li, 00 PSAY '|' + Space(130)+ '|'
	        	Li := Li+1
	        Next
	        @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
			Li := Li+2 
			@ Li, 00 PSAY '+' + Replicate('-',130) + '+'
			Li := Li+1 
			@ Li, 00 PSAY STR0011 + Space(103) + '|' //'Avalia豫o de Desempenho: 
		   	Li := Li+1 
	       	For Nz:=1 to 10
	       		@ Li, 00 PSAY '|' + Space(130)+ '|'
	        	Li := Li+1
	        Next
	        @ Li, 00 PSAY '+' + Replicate('-',130) + '+'
			Li := Li+2
			 
			@ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		   	Li := Li+1 
		   	@ Li, 00 PSAY STR0012 +  space(1) + cF_admissa + space(1) + 'a' + space(1) + cF_demissa + Space(87) + '|' //'Periodo de Estagio: 	 		
		   	Li := Li+1
		   	@ Li, 00 PSAY STR0013 +  cF_Cghor + Space(97) + '|' //'Carga Hor�ria: 	 		
		   	Li := Li+1
		   	@ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		   	Li := Li+2 
		   	@ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		 	Li := Li+1           
		 	@ Li, 00 PSAY STR0014 + Space(67) + '|'
		 	Li := Li+1  
		 	@ Li, 00 PSAY STR0015 + Space(55) + '|' 
		 	Li := Li+1  
		 	@ Li, 00 PSAY '+' + Replicate('-',130) + '+'
		 	Li := Li+3   
		 	@ Li, 00 PSAY AllTrim(cE_Cidade) + ',_____ de_____________________de______' 
		 	Li := Li+3
		 	@ Li, 00 PSAY '___________________________________________________'  
		 	Li := Li+1
		 	@ Li, 00 PSAY STR0016
		Next Nx   
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Reinicializa Variaveis.                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   	Li      := 0
	dbSelectArea('SRA')
	dbSkip()	
	
EndDo	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Termino do Relatorio.                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea( 'SRA' )
RetIndex('SRA')
dbSetOrder(1)
   
Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(WnRel)
EndIf
MS_Flush()

Return Nil
