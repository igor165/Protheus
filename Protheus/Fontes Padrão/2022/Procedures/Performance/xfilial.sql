Create procedure XFILIAL_##
( 
  @IN_ALIAS        Char(03),
  @IN_FILIALCOR    Char('CT2_FILIAL'),
  @OUT_FILIAL      Char('CT2_FILIAL') OutPut
)
as

/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possíveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
Declare @cModo    Char( 01 )
Declare @cModoUn  Char( 01 )
Declare @cModoEmp Char( 01 )
Declare @iTamFil  Integer
Declare @iTamUn   Integer
Declare @iTamEmp  Integer

begin
  
  Select @OUT_FILIAL = ' '
  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '
  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0
  
  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,
         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP
    From SX2###
   Where X2_CHAVE = @IN_ALIAS
     and D_E_L_E_T_ = ' '
  
  /* --------------------------------------------------------------
      1 - somente FILIAL e de tamanho >= 2
     -------------------------------------------------------------- */
  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2) begin
    If @cModo = 'C' select @OUT_FILIAL = '  '
    else select @OUT_FILIAL = @IN_FILIALCOR
  end else begin
    /* -------------------------------------------------------------- 
       SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL
       -------------------------------------------------------------- */
    If @iTamEmp = 0 begin
      If @cModoUn = 'E' begin
        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )
        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)
      end
    end else begin
      /* -------------------------------------------------------------- 
         SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL
         -------------------------------------------------------------- */
      If @iTamUn > 0 begin
        If @cModoEmp = 'E' begin
          If @cModoUn = 'E' begin
            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )
            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)
          end else begin
            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)
          end
        end
      end else begin
        /* -------------------------------------------------------------- 
            SITUACAO -> 3 EMPRESA e FILIAL
           -------------------------------------------------------------- */
        If @cModoEmp = 'E' begin
          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )
          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)
        end
      end
    end
  end
end