export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      client_representatives: {
        Row: {
          client_id: string
          user_id: string
        }
        Insert: {
          client_id: string
          user_id: string
        }
        Update: {
          client_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "client_representatives_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "client_representatives_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      clients: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          account_manager_id: string
          id: string
          link: string | null
          name: string
          sales_executive_id: string | null
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          account_manager_id: string
          id?: string
          link?: string | null
          name: string
          sales_executive_id?: string | null
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          account_manager_id?: string
          id?: string
          link?: string | null
          name?: string
          sales_executive_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "clients_account_manager_id_fkey"
            columns: ["account_manager_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "clients_sales_executive_id_fkey"
            columns: ["sales_executive_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      comments: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          author_id: string
          body: string
          entity_id: string
          entity_type: string
          id: string
          visibility: Database["public"]["Enums"]["comment_visibility"]
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          author_id: string
          body: string
          entity_id: string
          entity_type: string
          id?: string
          visibility?: Database["public"]["Enums"]["comment_visibility"]
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          author_id?: string
          body?: string
          entity_id?: string
          entity_type?: string
          id?: string
          visibility?: Database["public"]["Enums"]["comment_visibility"]
        }
        Relationships: [
          {
            foreignKeyName: "comments_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      employees: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          department: string | null
          email: string
          employment_type: Database["public"]["Enums"]["employment_type"]
          first_name: string
          id: string
          is_active: boolean
          job_function_level: string | null
          job_function_name: string | null
          job_function_track: string | null
          job_title: string | null
          last_name: string
          manager_id: string | null
          work_end_date: string | null
          work_start_date: string | null
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          department?: string | null
          email: string
          employment_type?: Database["public"]["Enums"]["employment_type"]
          first_name: string
          id?: string
          is_active?: boolean
          job_function_level?: string | null
          job_function_name?: string | null
          job_function_track?: string | null
          job_title?: string | null
          last_name: string
          manager_id?: string | null
          work_end_date?: string | null
          work_start_date?: string | null
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          department?: string | null
          email?: string
          employment_type?: Database["public"]["Enums"]["employment_type"]
          first_name?: string
          id?: string
          is_active?: boolean
          job_function_level?: string | null
          job_function_name?: string | null
          job_function_track?: string | null
          job_title?: string | null
          last_name?: string
          manager_id?: string | null
          work_end_date?: string | null
          work_start_date?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "employees_manager_id_fkey"
            columns: ["manager_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
        ]
      }
      group_permissions: {
        Row: {
          group_id: string
          permission_id: string
        }
        Insert: {
          group_id: string
          permission_id: string
        }
        Update: {
          group_id?: string
          permission_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_permissions_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "group_permissions_permission_id_fkey"
            columns: ["permission_id"]
            isOneToOne: false
            referencedRelation: "permissions"
            referencedColumns: ["id"]
          },
        ]
      }
      group_subgroups: {
        Row: {
          child_group_id: string
          parent_group_id: string
        }
        Insert: {
          child_group_id: string
          parent_group_id: string
        }
        Update: {
          child_group_id?: string
          parent_group_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_subgroups_child_group_id_fkey"
            columns: ["child_group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "group_subgroups_parent_group_id_fkey"
            columns: ["parent_group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
        ]
      }
      group_users: {
        Row: {
          group_id: string
          user_id: string
        }
        Insert: {
          group_id: string
          user_id: string
        }
        Update: {
          group_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_users_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "group_users_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      groups: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          description: string | null
          id: string
          is_active: boolean
          name: string
          source: Database["public"]["Enums"]["group_source"]
          sync_config: Json | null
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          is_active?: boolean
          name: string
          source?: Database["public"]["Enums"]["group_source"]
          sync_config?: Json | null
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          is_active?: boolean
          name?: string
          source?: Database["public"]["Enums"]["group_source"]
          sync_config?: Json | null
        }
        Relationships: []
      }
      permissions: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          description: string | null
          id: string
          urn: string
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          urn: string
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          urn?: string
        }
        Relationships: []
      }
      role_permissions: {
        Row: {
          permission_id: string
          role_id: string
        }
        Insert: {
          permission_id: string
          role_id: string
        }
        Update: {
          permission_id?: string
          role_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "role_permissions_permission_id_fkey"
            columns: ["permission_id"]
            isOneToOne: false
            referencedRelation: "permissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "role_permissions_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
        ]
      }
      roles: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          description: string | null
          id: string
          name: string
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          name: string
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          description?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          role_id: string
          user_id: string
        }
        Insert: {
          role_id: string
          user_id: string
        }
        Update: {
          role_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_roles_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_roles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          _created_at: string
          _created_by: string
          _deleted: boolean
          _updated_at: string | null
          _updated_by: string | null
          email: string
          employee_id: string | null
          id: string
          is_active: boolean
          name: string
        }
        Insert: {
          _created_at?: string
          _created_by: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          email: string
          employee_id?: string | null
          id: string
          is_active?: boolean
          name: string
        }
        Update: {
          _created_at?: string
          _created_by?: string
          _deleted?: boolean
          _updated_at?: string | null
          _updated_by?: string | null
          email?: string
          employee_id?: string | null
          id?: string
          is_active?: boolean
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "users_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      comment_visibility: "public" | "restricted"
      employment_type: "employee" | "contractor" | "trainee"
      group_source: "manual" | "active_directory" | "ldap" | "scim"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      comment_visibility: ["public", "restricted"],
      employment_type: ["employee", "contractor", "trainee"],
      group_source: ["manual", "active_directory", "ldap", "scim"],
    },
  },
} as const

